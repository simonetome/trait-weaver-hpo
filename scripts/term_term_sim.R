
# Libraries

library(dplyr)
library(tidyr)
library(data.table)
library(ontologySimilarity)
library(ontologyIndex)
library(ggplot2)


# Load data
args <- commandArgs(trailingOnly = TRUE)
out_dir <- args[[1]]

## Ontology

data(hpo)

hp_terms <- names(hpo$name)
sprintf("Number of terms: %d", length(hp_terms))

hpo_annotations <- fread("data/phenotype.hpoa", skip=4)
head(hpo_annotations)


diseases <- unique(hpo_annotations$database_id)
sprintf("Number of diseases: %d", length(diseases))


# filter annotations for only annotations where Hp-term is in the ontology 

hpo_annotations <- hpo_annotations[hpo_annotations$hpo_id %in% hp_terms,]


# Propagate annotations

sprintf("Propagating annotations")

df_propagated <- hpo_annotations %>%
  rowwise() %>%
  mutate(hpo_id = list(c(hpo_id, get_ancestors(hpo, hpo_id)))) %>% 
  unnest(hpo_id) %>%
  distinct(hpo_id, database_id)


sprintf("Annotations propagated")

# Calc information contents


N <- length(unique(df_propagated$database_id))

# calculate normalized information content
df_propagated %>% 
  group_by(hpo_id) %>%
  summarise(
    IC = -log(n()/N),
    IC_norm = -log(n()/N)/log(N)
  ) -> information_contents_df 


# convert to named list 

information_contents <- setNames(
  information_contents_df$IC,
  information_contents_df$hpo_id
)


structural_ic <- descendants_IC(hpo)
#structural_ic_norm <- structural_ic/max(structural_ic)

sprintf("Calculating t-t sim")
term_term_mat <- get_term_sim_mat(
  hpo,
  structural_ic, #information_contents, I'm not using this no more, it gives super-hubs (e.g. microcephaly has 300 neighbors)
  method="lin"
)
sprintf("Finished t-t sim")


saveRDS(term_term_mat, paste0(out_dir,"/term_term_mat.RDS"))
sprintf("Dumped")



























