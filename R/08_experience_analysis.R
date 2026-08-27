# ==============================================================================
# TechScape: Experience Requirements & Accessibility (R/08_experience_analysis.R)
# ==============================================================================
# PROVENANCE NOTICE:
# SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE
# This script develops and tests the analytical and visualization methods for RQ5
# (Experience Requirements) and RQ4 (Entry-Level Accessibility).
# ==============================================================================

# Ensure output directories exist
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/findings", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. Ingestion
# ------------------------------------------------------------------------------
cat("\n==============================================================\n")
cat("       MODULE 08: EXPERIENCE REQUIREMENTS & ACCESSIBILITY     \n")
cat("==============================================================\n")
cat("DATASET: `data/processed/jobs_transformed.csv` (SYNTHETIC DEV DATA)\n\n")

jobs <- read.csv("data/processed/jobs_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
n_total <- nrow(jobs)

# ------------------------------------------------------------------------------
# 2. Analysis 1: Overall Experience Requirement Distribution (RQ5)
# ------------------------------------------------------------------------------
cat(">>> [1/4] Analyzing Experience Threshold Distributions...\n")
cat("Question: What are the central tendencies and spread of minimum required experience?\n")

exp_stats <- data.frame(
  Metric = c("Total_Postings", "Mean_Exp_Min", "Median_Exp_Min", "IQR_Exp_Min", "Min_Exp", "Max_Exp", "Zero_Exp_Pct"),
  Value = c(
    n_total,
    round(mean(jobs$experience_min, na.rm=TRUE), 2),
    median(jobs$experience_min, na.rm=TRUE),
    IQR(jobs$experience_min, na.rm=TRUE),
    min(jobs$experience_min, na.rm=TRUE),
    max(jobs$experience_min, na.rm=TRUE),
    round(mean(jobs$experience_min == 0, na.rm=TRUE) * 100, 1)
  ),
  stringsAsFactors = FALSE
)
write.csv(exp_stats, "outputs/tables/tab_08_experience_summary_statistics.csv", row.names = FALSE)

# Experience Distribution Histogram
png("outputs/figures/fig_08_experience_min_distribution.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
hist(
  jobs$experience_min,
  breaks = seq(-0.5, max(jobs$experience_min, na.rm=TRUE) + 0.5, by = 1),
  col = "#4575b4",
  border = "#ffffff",
  main = "Minimum Experience Requirement Distribution (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Minimum Required Experience (Years)",
  ylab = "Number of Job Postings",
  las = 1
)
grid(nx = NA, ny = NULL, col = "#e0e0e0", lty = 2)
abline(v = median(jobs$experience_min, na.rm=TRUE), col = "#d73027", lwd = 3, lty = 2)
legend("topright", legend = sprintf("Median: %d Years", median(jobs$experience_min, na.rm=TRUE)), 
       col = "#d73027", lty = 2, lwd = 3, bty = "n")
dev.off()

# ------------------------------------------------------------------------------
# 3. Analysis 2: Experience Requirements by Career Category (RQ5)
# ------------------------------------------------------------------------------
cat(">>> [2/4] Analyzing Experience by Career Category...\n")

exp_by_car <- aggregate(experience_min ~ career_category, data = jobs, 
                        FUN = function(x) c(Mean = mean(x), Median = median(x), IQR = IQR(x)))
exp_car_df <- data.frame(
  Career_Category = exp_by_car$career_category,
  Mean_Exp_Years = round(exp_by_car$experience_min[, "Mean"], 2),
  Median_Exp_Years = exp_by_car$experience_min[, "Median"],
  IQR_Exp_Years = round(exp_by_car$experience_min[, "IQR"], 2),
  stringsAsFactors = FALSE
)
exp_car_df <- exp_car_df[order(-exp_car_df$Mean_Exp_Years), ]
write.csv(exp_car_df, "outputs/tables/tab_08_experience_by_career.csv", row.names = FALSE)

# Boxplot by Career Category
png("outputs/figures/fig_08_experience_by_career.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 12, 4, 3), bg = "#fcfcfc")
boxplot(
  experience_min ~ career_category,
  data = jobs,
  horizontal = TRUE,
  col = "#91bfdb",
  border = "#4575b4",
  main = "Experience Requirements by Career Track (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Minimum Required Experience (Years)",
  las = 1,
  cex.axis = 0.85
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
dev.off()

# ------------------------------------------------------------------------------
# 4. Analysis 3: Experience Trends Over Time (RQ5)
# ------------------------------------------------------------------------------
cat(">>> [3/4] Analyzing Experience Trends Over Time...\n")

exp_time <- aggregate(experience_min ~ posting_year, data = jobs, FUN = mean)
names(exp_time) <- c("Year", "Mean_Exp_Required")
exp_time$Mean_Exp_Required <- round(exp_time$Mean_Exp_Required, 2)
write.csv(exp_time, "outputs/tables/tab_08_experience_over_time.csv", row.names = FALSE)

# Time Series Plot
png("outputs/figures/fig_08_experience_over_time.png", width = 1800, height = 1200, res = 200)
par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
plot(
  exp_time$Year, exp_time$Mean_Exp_Required,
  type = "b", pch = 19, lwd = 3, col = "#2166ac",
  main = "Mean Required Experience Over Time (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Posting Year",
  ylab = "Mean Minimum Experience (Years)",
  ylim = c(0, max(exp_time$Mean_Exp_Required) * 1.3),
  las = 1
)
grid(nx = NULL, ny = NULL, col = "#e0e0e0", lty = 2)
dev.off()

# ------------------------------------------------------------------------------
# 5. Analysis 4: Experience vs. Salary Relationship
# ------------------------------------------------------------------------------
cat(">>> [4/4] Analyzing Relationship Between Experience and Salary...\n")

jobs_lkr <- subset(jobs, currency == "LKR" & !is.na(salary_midpoint))

if (nrow(jobs_lkr) > 5) {
  # Correlation
  exp_sal_cor <- round(cor(jobs_lkr$experience_min, jobs_lkr$salary_midpoint, use = "complete.obs"), 3)
  
  png("outputs/figures/fig_08_experience_vs_salary_lkr.png", width = 2000, height = 1300, res = 200)
  par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
  plot(
    jobs_lkr$experience_min, jobs_lkr$salary_midpoint / 1000,
    pch = 19, col = "#7b1fa288", cex = 1.3,
    main = sprintf("Experience vs. Monthly Salary (LKR) [r = %.2f] (Synthetic Dev Data)", exp_sal_cor),
    sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
    xlab = "Minimum Required Experience (Years)",
    ylab = "Monthly Salary Midpoint (Thousand LKR)",
    las = 1
  )
  grid(nx = NULL, ny = NULL, col = "#e0e0e0", lty = 2)
  # Add trendline
  abline(lm(salary_midpoint / 1000 ~ experience_min, data = jobs_lkr), col = "#d95f02", lwd = 2)
  dev.off()
}

# ------------------------------------------------------------------------------
# 6. Generate Findings Document
# ------------------------------------------------------------------------------
findings_text <- sprintf(
"# Module 08: Experience Requirements & Accessibility Findings

> **DATASET GOVERNANCE NOTICE:**
> **SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE**
> The analytical findings below describe properties of the synthetic development dataset (`jobs_transformed.csv`, n=%d). They must NOT be cited as empirical claims regarding Sri Lanka.

---

## 1. Overall Experience Thresholds (RQ5)
- **Mean Minimum Experience:** %.2f years.
- **Median Minimum Experience:** %d years (IQR: %d years).
- **Zero Experience (Intern/Trainee) Share:** %.1f%% (%d postings).
- **Output Artifacts:** [tab_08_experience_summary_statistics.csv](file:///d:/projects/TechScape/outputs/tables/tab_08_experience_summary_statistics.csv), [fig_08_experience_min_distribution.png](file:///d:/projects/TechScape/outputs/figures/fig_08_experience_min_distribution.png).

---

## 2. Category-Level Experience Demands
- **Highest Mean Experience:** `%s` (Mean: %.2f years).
- **Lowest Mean Experience:** `%s` (Mean: %.2f years).
- **Output Artifacts:** [tab_08_experience_by_career.csv](file:///d:/projects/TechScape/outputs/tables/tab_08_experience_by_career.csv), [fig_08_experience_by_career.png](file:///d:/projects/TechScape/outputs/figures/fig_08_experience_by_career.png).

---

## 3. Experience vs. Compensation Correlation
- **Pearson Correlation (Experience vs LKR Salary):** r = %.2f.
- **Output Artifacts:** [fig_08_experience_vs_salary_lkr.png](file:///d:/projects/TechScape/outputs/figures/fig_08_experience_vs_salary_lkr.png).
",
  n_total,
  mean(jobs$experience_min, na.rm=TRUE),
  median(jobs$experience_min, na.rm=TRUE),
  IQR(jobs$experience_min, na.rm=TRUE),
  mean(jobs$experience_min == 0, na.rm=TRUE) * 100,
  sum(jobs$experience_min == 0, na.rm=TRUE),
  exp_car_df$Career_Category[1], exp_car_df$Mean_Exp_Years[1],
  exp_car_df$Career_Category[nrow(exp_car_df)], exp_car_df$Mean_Exp_Years[nrow(exp_car_df)],
  ifelse(exists("exp_sal_cor"), exp_sal_cor, 0)
)

writeLines(findings_text, "outputs/findings/findings_08_experience_analysis.md")
cat("✅ Module 08 completed successfully!\n\n")
