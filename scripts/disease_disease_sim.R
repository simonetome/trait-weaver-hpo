library(matrixStats)
library(data.table)
library(ontologyIndex)
library(arrow)

# For disease-disease similarity matrix
Rcpp::sourceCpp("r/disease_sim.cpp")

#
# Load data 
#

args <- commandArgs(trailingOnly = TRUE)
out_dir <- args[[1]]

print("Loading data...")

data(hpo)
hp_terms <- names(hpo$name)

term_term_mat <- readRDS(paste0(out_dir,"/term_term_mat.RDS"))

hpo_annotations <- fread("data/phenotype.hpoa", skip=4)
hpo_annotations <- hpo_annotations[hpo_annotations$hpo_id %in% hp_terms,]

print("...data loaded")

# Diseases

diseases <- unique(hpo_annotations$database_id)
sprintf("Numb of diseases: %d",length(diseases))

#' The function returns annotated phenotype terms for the disease.
#' @param disease disease id
#' @return Returns a vector of HP:XXXX terms for 'disease' 
get_annotations <- function(disease){
    hpo_annotations$hpo_id[hpo_annotations$database_id == disease]
}


# named list disease -> set of hp_annotations
disease_pheno_map <- setNames(
  lapply(diseases, get_annotations),
  diseases
)


# Build data
# Cpp requires numeric indexes

sprintf("Building data for d-d similarity")

# term ids = hp_terms
term_ids <- row.names(term_term_mat)         
# named list term -> idx 
term_index <- setNames(seq_along(term_ids), term_ids)

# list DiseaseID -> HP pheno indexes
pheno_idx_list <- lapply(disease_pheno_map[diseases], function(annotated_hp) {
  idx <- unname(term_index[annotated_hp])
})


sprintf("D-d calculation...")
sim_matrix_cpp <- disease_similarity_matrix_cpp(pheno_idx_list, term_term_mat)
rownames(sim_matrix_cpp) <- diseases
colnames(sim_matrix_cpp) <- diseases


sprintf("D-d calculated")
print(dim(sim_matrix_cpp))


# saveRDS(sim_matrix_cpp,"output/disease_disease_sim.RDS")

# Dump all data for Github-release

#

dd_df <- as.data.frame(sim_matrix_cpp)
write_feather(dd_df, paste0(out_dir,"/disease_disease_sim.feather"))


tt_df <- as.data.frame(term_term_mat)
write_feather(tt_df, paste0(out_dir,"/term_term_sim.feather"))






