# Requirements

print(getwd())

packages <- c(
  "dplyr", 
  "data.table", 
  "ontologyIndex", 
  "ontologySimilarity", 
  "tidyr",
  "ggplot2",
  "matrixStats",
  "arrow"
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

