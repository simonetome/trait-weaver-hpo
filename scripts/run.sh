#!/bin/bash 

# run this script from the BASE_DIR (trait-weaver-hpo)

# >trait-weaver-hpo/ sh scripts/run.ss

# MODIFY THIS TO OUTPUT DIRECTORY
OUT_DIR=/home/ubuntu/Data/hpo

mkdir -p $OUT_DIR

Rscript scripts/get_requirements.R && \
Rscript scripts/term_term_sim.R $OUT_DIR && \
Rscript scripts/disease_disease_sim.R $OUT_DIR







