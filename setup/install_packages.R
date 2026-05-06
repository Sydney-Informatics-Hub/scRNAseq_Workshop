#!/usr/bin/env Rscript
# R package installation for workshop dependencies

# Change library directory to ${HOME}/.library so root is not needed
.libPaths("~/.library")

# Install BiocManager first, may prevent conflicting dependencies if
# CRAN packages are installed first
install.packages(c("BiocManager", "BiocManager"))

bioc_pkgs <- c(
  "SingleR",
  "celldex",
  "BiocGenerics",
  "DelayedArray",
  "DelayedMatrixStats",
  "limma",
  "S4Vectors",
  "SingleCellExperiment",
  "SummarizedExperiment",
  "edgeR"
)

BiocManager::install(bioc_pkgs)

# Install CRAN packges
cran_pkgs <- c(
  "Seurat",
  "dplyr",
  "remotes",
  "R.utils",
  "harmony",
  "hdf5r",
  "clustree",
  "RColorBrewer",
  "tidyverse",
  "pander"
)

install.packages(cran_pkgs)

# Lastly github pkgs
remotes::install_github("immunogenomics/presto@1.0.0")

# Validate installation

cat("========== Installation validation ==========\n")
cat("Target library:", user_lib, "\n\n")

expected_pkgs <- c("BiocManager", "BiocGenerics", bioc_pkgs, cran_pkgs)

check_package <- function(pkg, lib) {
  installed <- dir.exists(file.path(lib, pkg))
  loadable  <- FALSE
  version   <- NA_character_
  message   <- NULL

  if (installed) {
    loadable <- suppressWarnings(
      requireNamespace(pkg, quietly = TRUE, lib.loc = lib)
    )
    if (loadable) {
      version <- tryCatch(
        as.character(packageVersion(pkg, lib.loc = lib)),
        error = function(e) NA_character_
      )
    } else {
      message <- "installed but fails to load"
    }
  } else {
    message <- "not installed"
  }

  list(
    package   = pkg,
    installed = installed,
    loadable  = loadable,
    version   = version,
    status    = if (installed && loadable) "OK" else message
  )
}

results <- lapply(expected_pkgs, check_package, lib = user_lib)

# Print results table
cat(sprintf("%-35s %-10s %s\n", "Package", "Version", "Status"))
cat(strrep("-", 60), "\n")
for (r in results) {
  cat(sprintf(
    "%-35s %-10s %s\n",
    r$package,
    if (is.na(r$version)) "-" else r$version,
    r$status
  ))
}

cat("\n")

failed <- Filter(function(r) !identical(r$status, "OK"), results)

if (length(failed) == 0) {
  cat("All", length(expected_pkgs), "packages installed and loadable.\n")
} else {
  cat(sprintf("FAILED: %d package(s) did not pass validation:\n", length(failed)))
  for (r in failed) {
    cat(sprintf("  - %s: %s\n", r$package, r$status))
  }
  quit(status = 1)
}
