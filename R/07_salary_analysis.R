# ==============================================================================
# TechScape: Compensation & Salary Analysis (R/07_salary_analysis.R)
# ==============================================================================
# PROVENANCE NOTICE:
# SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE
# This script develops and tests the analytical and visualization methods for RQ6
# (Compensation Dynamics, Transparency & Disclosed Ranges).
#
# RULE: Disclosed LKR and USD observations are strictly separated. Undisclosed
# salaries are never imputed with zero or artificial central tendencies.
# ==============================================================================

# Ensure output directories exist
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/findings", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. Ingestion
# ------------------------------------------------------------------------------
cat("\n==============================================================\n")
cat("          MODULE 07: SALARY & COMPENSATION ANALYSIS           \n")
cat("==============================================================\n")
cat("DATASET: `data/processed/jobs_transformed.csv` (SYNTHETIC DEV DATA)\n\n")

jobs <- read.csv("data/processed/jobs_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
n_total <- nrow(jobs)

# ------------------------------------------------------------------------------
# 2. Analysis 1: Salary Disclosure Transparency (RQ6)
# ------------------------------------------------------------------------------
cat(">>> [1/5] Analyzing Salary Disclosure Transparency...\n")
cat("Question: What proportion of IT job postings disclose numerical compensation?\n")
cat("Variables: `salary_disclosed`, `career_category`, `work_mode`\n")

disclosure_by_car <- aggregate(salary_disclosed ~ career_category, data = jobs, FUN = function(x) c(Total = length(x), Disclosed = sum(x), Rate_Pct = round(mean(x) * 100, 1)))
disclosure_df <- data.frame(
  Career_Category = disclosure_by_car$career_category,
  Total_Postings = disclosure_by_car$salary_disclosed[, "Total"],
  Disclosed_Postings = disclosure_by_car$salary_disclosed[, "Disclosed"],
  Disclosure_Rate_Pct = disclosure_by_car$salary_disclosed[, "Rate_Pct"],
  stringsAsFactors = FALSE
)
disclosure_df <- disclosure_df[order(-disclosure_df$Disclosure_Rate_Pct), ]
write.csv(disclosure_df, "outputs/tables/tab_07_salary_disclosure_by_category.csv", row.names = FALSE)

# Disclosure Rate Plot
png("outputs/figures/fig_07_salary_disclosure_rate.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 12, 4, 3), bg = "#fcfcfc")
bp <- barplot(
  rev(disclosure_df$Disclosure_Rate_Pct),
  names.arg = rev(disclosure_df$Career_Category),
  horiz = TRUE,
  col = "#e7298a",
  border = NA,
  main = "Salary Disclosure Rate by Career Category (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Proportion Disclosing Numeric Salary (%)",
  xlim = c(0, 100),
  las = 1,
  cex.names = 0.85
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
text(rev(disclosure_df$Disclosure_Rate_Pct) + 2, bp, 
     labels = sprintf("%.1f%% (%d/%d)", rev(disclosure_df$Disclosure_Rate_Pct), 
                      rev(disclosure_df$Disclosed_Postings), rev(disclosure_df$Total_Postings)), 
     cex = 0.8, font = 2, adj = 0)
dev.off()

# ------------------------------------------------------------------------------
# 3. Analysis 2: Disclosed LKR Salary Distributions & Percentiles (RQ6)
# ------------------------------------------------------------------------------
cat(">>> [2/5] Analyzing Disclosed LKR Salary Distribution...\n")

jobs_lkr <- subset(jobs, currency == "LKR" & !is.na(salary_midpoint))
n_lkr <- nrow(jobs_lkr)

lkr_stats <- data.frame(
  Metric = c("Count", "Mean", "StdDev", "Min", "P25 (Q1)", "Median (P50)", "P75 (Q3)", "Max", "IQR"),
  Value_LKR = c(
    n_lkr,
    round(mean(jobs_lkr$salary_midpoint)),
    round(sd(jobs_lkr$salary_midpoint)),
    min(jobs_lkr$salary_midpoint),
    quantile(jobs_lkr$salary_midpoint, 0.25),
    median(jobs_lkr$salary_midpoint),
    quantile(jobs_lkr$salary_midpoint, 0.75),
    max(jobs_lkr$salary_midpoint),
    IQR(jobs_lkr$salary_midpoint)
  ),
  stringsAsFactors = FALSE
)
write.csv(lkr_stats, "outputs/tables/tab_07_lkr_salary_summary_statistics.csv", row.names = FALSE)

# LKR Salary Distribution Histogram & Density
png("outputs/figures/fig_07_lkr_salary_distribution.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
hist(
  jobs_lkr$salary_midpoint / 1000,
  breaks = 12,
  col = "#7570b3",
  border = "#ffffff",
  main = "Disclosed Monthly Salary Distribution - LKR (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Monthly Salary Midpoint (Thousand LKR)",
  ylab = "Frequency",
  las = 1
)
grid(nx = NA, ny = NULL, col = "#e0e0e0", lty = 2)
abline(v = median(jobs_lkr$salary_midpoint) / 1000, col = "#d95f02", lwd = 3, lty = 2)
legend("topright", legend = sprintf("Median: LKR %sk", format(median(jobs_lkr$salary_midpoint) / 1000, big.mark=",")), 
       col = "#d95f02", lty = 2, lwd = 3, bty = "n")
dev.off()

# ------------------------------------------------------------------------------
# 4. Analysis 3: Disclosed USD Salary Distributions (RQ6)
# ------------------------------------------------------------------------------
cat(">>> [3/5] Analyzing Disclosed USD Salary Distribution...\n")

jobs_usd <- subset(jobs, currency == "USD" & !is.na(salary_midpoint))
n_usd <- nrow(jobs_usd)

if (n_usd > 0) {
  usd_stats <- data.frame(
    Metric = c("Count", "Mean", "StdDev", "Min", "P25 (Q1)", "Median (P50)", "P75 (Q3)", "Max"),
    Value_USD = c(
      n_usd,
      round(mean(jobs_usd$salary_midpoint)),
      round(sd(jobs_usd$salary_midpoint)),
      min(jobs_usd$salary_midpoint),
      quantile(jobs_usd$salary_midpoint, 0.25),
      median(jobs_usd$salary_midpoint),
      quantile(jobs_usd$salary_midpoint, 0.75),
      max(jobs_usd$salary_midpoint)
    ),
    stringsAsFactors = FALSE
  )
  write.csv(usd_stats, "outputs/tables/tab_07_usd_salary_summary_statistics.csv", row.names = FALSE)
}

# ------------------------------------------------------------------------------
# 5. Analysis 4: Salary by Seniority & Experience Band (RQ6)
# ------------------------------------------------------------------------------
cat(">>> [4/5] Analyzing LKR Salary by Seniority and Experience Band...\n")

sal_by_seniority <- aggregate(salary_midpoint ~ seniority_level, data = jobs_lkr, 
                              FUN = function(x) c(Count = length(x), Median = median(x), Mean = mean(x), IQR = IQR(x)))
sal_sen_df <- data.frame(
  Seniority_Level = sal_by_seniority$seniority_level,
  Disclosed_Count = sal_by_seniority$salary_midpoint[, "Count"],
  Median_LKR = round(sal_by_seniority$salary_midpoint[, "Median"]),
  Mean_LKR = round(sal_by_seniority$salary_midpoint[, "Mean"]),
  IQR_LKR = round(sal_by_seniority$salary_midpoint[, "IQR"]),
  stringsAsFactors = FALSE
)
write.csv(sal_sen_df, "outputs/tables/tab_07_salary_by_seniority.csv", row.names = FALSE)

# Boxplot of LKR Salary by Seniority
png("outputs/figures/fig_07_salary_by_seniority.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 8, 4, 3), bg = "#fcfcfc")
boxplot(
  salary_midpoint / 1000 ~ seniority_level,
  data = jobs_lkr,
  col = "#66a61e",
  border = "#1b9e77",
  main = "Disclosed LKR Monthly Salary by Seniority (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  ylab = "Monthly Salary Midpoint (Thousand LKR)",
  xlab = "Seniority Tier",
  las = 1
)
grid(nx = NA, ny = NULL, col = "#e0e0e0", lty = 2)
dev.off()

# ------------------------------------------------------------------------------
# 6. Analysis 5: Categorical Salary Band Distribution
# ------------------------------------------------------------------------------
cat(">>> [5/5] Analyzing Categorical Salary Bands...\n")

lkr_band_tab <- as.data.frame(table(jobs_lkr$salary_band_lkr), stringsAsFactors = FALSE)
names(lkr_band_tab) <- c("Salary_Band_LKR", "Count")
lkr_band_tab$Share_Pct <- round((lkr_band_tab$Count / n_lkr) * 100, 1)
write.csv(lkr_band_tab, "outputs/tables/tab_07_salary_bands_lkr.csv", row.names = FALSE)

# ------------------------------------------------------------------------------
# 7. Generate Findings Document
# ------------------------------------------------------------------------------
findings_text <- sprintf(
"# Module 07: Compensation & Salary Analysis Findings

> **DATASET GOVERNANCE NOTICE:**
> **SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE**
> The analytical findings below describe properties of the synthetic development dataset (`jobs_transformed.csv`, n=%d). They must NOT be cited as empirical claims regarding Sri Lanka.

---

## 1. Salary Disclosure Transparency (RQ6)
- **Overall Disclosure Rate:** %.1f%% (%d of %d postings disclosed numeric compensation).
- **Undisclosed Proportion:** %.1f%% (%d postings) listed qualitative terms (*Negotiable*, *Market Standard*).
- **Category with Highest Disclosure:** `%s` (%.1f%% disclosed).
- **Output Artifacts:** [tab_07_salary_disclosure_by_category.csv](file:///d:/projects/TechScape/outputs/tables/tab_07_salary_disclosure_by_category.csv), [fig_07_salary_disclosure_rate.png](file:///d:/projects/TechScape/outputs/figures/fig_07_salary_disclosure_rate.png).

---

## 2. Disclosed Compensation Benchmarks (LKR)
- **LKR Disclosed Count:** %d observations.
- **Median Monthly Midpoint:** LKR %s (IQR: LKR %s).
- **Mean Monthly Midpoint:** LKR %s (StdDev: LKR %s).
- **Range:** LKR %s to LKR %s.
- **Output Artifacts:** [tab_07_lkr_salary_summary_statistics.csv](file:///d:/projects/TechScape/outputs/tables/tab_07_lkr_salary_summary_statistics.csv), [fig_07_lkr_salary_distribution.png](file:///d:/projects/TechScape/outputs/figures/fig_07_lkr_salary_distribution.png).

---

## 3. Disclosed USD-Pegged Packages
- **USD Disclosed Count:** %d observations.
- **Median Monthly Midpoint:** USD $%s.
- **Output Artifacts:** [tab_07_usd_salary_summary_statistics.csv](file:///d:/projects/TechScape/outputs/tables/tab_07_usd_salary_summary_statistics.csv).

---

## 4. Seniority Progression
- **Entry / Intern Median (LKR):** LKR %s.
- **Senior / Lead Median (LKR):** LKR %s.
- **Output Artifacts:** [tab_07_salary_by_seniority.csv](file:///d:/projects/TechScape/outputs/tables/tab_07_salary_by_seniority.csv), [fig_07_salary_by_seniority.png](file:///d:/projects/TechScape/outputs/figures/fig_07_salary_by_seniority.png).
",
  n_total,
  mean(jobs$salary_disclosed) * 100, sum(jobs$salary_disclosed), n_total,
  100 - mean(jobs$salary_disclosed) * 100, sum(!jobs$salary_disclosed),
  disclosure_df$Career_Category[1], disclosure_df$Disclosure_Rate_Pct[1],
  n_lkr, format(median(jobs_lkr$salary_midpoint), big.mark=","), format(IQR(jobs_lkr$salary_midpoint), big.mark=","),
  format(round(mean(jobs_lkr$salary_midpoint)), big.mark=","), format(round(sd(jobs_lkr$salary_midpoint)), big.mark=","),
  format(min(jobs_lkr$salary_midpoint), big.mark=","), format(max(jobs_lkr$salary_midpoint), big.mark=","),
  n_usd, ifelse(n_usd > 0, format(median(jobs_usd$salary_midpoint), big.mark=","), "N/A"),
  format(median(subset(jobs_lkr, seniority_level %in% c("Intern", "Junior"))$salary_midpoint), big.mark=","),
  format(median(subset(jobs_lkr, seniority_level %in% c("Senior", "Lead"))$salary_midpoint), big.mark=",")
)

writeLines(findings_text, "outputs/findings/findings_07_salary_analysis.md")
cat("✅ Module 07 completed successfully!\n\n")
