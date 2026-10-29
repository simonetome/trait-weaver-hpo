#!/bin/bash
# Run from BASE_DIR (trait-weaver-hpo):
#   bash scripts/run.sh
# Override the output dir with:  OUT_DIR=/some/path bash scripts/run.sh

# Re-exec under bash if launched with sh/dash
if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -euo pipefail

OUT_DIR="${1:-/home/ubuntu/Data/hpo}"
ENV_NAME="trait-weaver-hpo"
ENV_FILE="environment.yml"

mkdir -p "$OUT_DIR"

# Prefer mamba if available (much faster solver)
if command -v mamba >/dev/null 2>&1; then CONDA=mamba; else CONDA=conda; fi

# Create the env only if it doesn't exist yet
if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    echo ">> Creating conda env '$ENV_NAME'"
    $CONDA env create -n "$ENV_NAME" -f "$ENV_FILE"
fi

# Isolate R from the user's setup:
#  --vanilla      -> skips ~/.Rprofile, ./.Rprofile, Rprofile.site, ~/.Renviron, saved workspaces
#  R_LIBS*        -> prevents user/site libraries from leaking into .libPaths()
unset R_LIBS R_LIBS_SITE R_PROFILE R_PROFILE_USER R_ENVIRON R_ENVIRON_USER
export R_LIBS_USER=/nonexistent   # R drops non-existent dirs from .libPaths()

RUN="conda run -n $ENV_NAME --no-capture-output"
RSCRIPT="$RUN Rscript --vanilla"

$RSCRIPT -e 'stopifnot(Rcpp::evalCpp("1 + 1") == 2)'
$RSCRIPT scripts/get_requirements.R
$RSCRIPT scripts/term_term_sim.R "$OUT_DIR"
$RSCRIPT scripts/disease_disease_sim.R "$OUT_DIR"