# ==============================================================================
# TechScape: Automated R Dependency Installer (R/install_dependencies.R)
# ==============================================================================
# Non-interactively installs any missing packages required for testing and
# dashboard payload verification. The core analytical pipeline relies on Base R.
# ==============================================================================

options(repos = c(CRAN = "https://cloud.r-project.org"))

required_packages <- c(
  "testthat",
  "jsonlite"
)

cat(">>> Checking R environment dependencies...\n")

missing_pkgs <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

if (length(missing_pkgs) > 0) {
  cat(sprintf(">>> Installing missing packages: %s\n", paste(missing_pkgs, collapse = ", ")))
  install.packages(missing_pkgs, dependencies = TRUE, quiet = FALSE)
} else {
  cat(">>> All required R packages are already installed.\n")
}

cat(">>> R environment dependency verification complete.\n")
