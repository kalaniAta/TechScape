# ==============================================================================
# TechScape: Testthat Suite Runner (tests/testthat.R)
# ==============================================================================
# Invokes testthat on the tests/testthat directory and exits with standard
# non-zero return code if any test fails, making it fully CI-compatible.
# ==============================================================================

if (!requireNamespace("testthat", quietly = TRUE)) {
  cat(">>> Package 'testthat' is not installed. Running legacy test suite...\n")
  source("tests/data_quality/test_real_and_inferential.R")
} else {
  cat(">>> Running TechScape Testthat Test Suite...\n")
  res <- testthat::test_dir("tests/testthat", reporter = "summary")
  df_res <- as.data.frame(res)
  failed <- sum(df_res$failed) + sum(df_res$error)
  if (failed > 0) {
    cat(sprintf("\n❌ Testthat encountered %d failure(s).\n", failed))
    quit(status = 1)
  } else {
    cat("\n✅ All Testthat data quality tests passed successfully!\n")
    quit(status = 0)
  }
}
