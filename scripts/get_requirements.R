# Requirements

print(getwd())

options(repos = c(CRAN = "https://cloud.r-project.org"))

packages <- c(
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

