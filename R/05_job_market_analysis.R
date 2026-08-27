# ==============================================================================
# TechScape: Job Market & Career Category Analysis (R/05_job_market_analysis.R)
# ==============================================================================
# PROVENANCE NOTICE:
# SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE
# This script develops and tests the analytical and visualization methods for RQ1,
# RQ2, and RQ4. Findings represent development data behavior only.
# ==============================================================================

# Ensure output directories exist
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/findings", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. Ingestion
# ------------------------------------------------------------------------------
cat("\n==============================================================\n")
cat("          MODULE 05: JOB MARKET & CAREER ANALYSIS             \n")
cat("==============================================================\n")
cat("DATASET: `data/processed/jobs_transformed.csv` (SYNTHETIC DEV DATA)\n\n")

jobs <- read.csv("data/processed/jobs_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
n_total <- nrow(jobs)

# ------------------------------------------------------------------------------
# 2. Analysis 1: Annual Job Posting Volume (RQ1)
# ------------------------------------------------------------------------------
cat(">>> [1/4] Analyzing Annual Job Posting Volume...\n")
cat("Question: How is the volume of job postings distributed across calendar years?\n")
cat("Variables: `posting_year`, `job_id`\n")

annual_vol <- as.data.frame(table(jobs$posting_year), stringsAsFactors = FALSE)
names(annual_vol) <- c("Year", "Posting_Count")
annual_vol$Year <- as.integer(annual_vol$Year)
annual_vol$Share_Pct <- round((annual_vol$Posting_Count / n_total) * 100, 2)

# Save Table
write.csv(annual_vol, "outputs/tables/tab_05_annual_volume.csv", row.names = FALSE)

# Generate Plot
png("outputs/figures/fig_05_annual_job_volume.png", width = 1800, height = 1200, res = 200)
par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
bp <- barplot(
  annual_vol$Posting_Count,
  names.arg = annual_vol$Year,
  col = "#1f77b4",
  border = NA,
  main = "Annual Job Posting Volume (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Posting Year",
  ylab = "Number of Advertised Postings",
  ylim = c(0, max(annual_vol$Posting_Count) * 1.2),
  las = 1,
  cex.names = 0.9,
  cex.axis = 0.9,
  cex.lab = 1.0,
  cex.main = 1.2
)
grid(nx = NA, ny = NULL, col = "#e0e0e0", lty = 2)
text(bp, annual_vol$Posting_Count + (max(annual_vol$Posting_Count) * 0.03), 
     labels = annual_vol$Posting_Count, cex = 0.85, font = 2)
dev.off()

# ------------------------------------------------------------------------------
# 3. Analysis 2: Career Category Distribution (RQ2)
# ------------------------------------------------------------------------------
cat(">>> [2/4] Analyzing Career Category Distribution...\n")
cat("Question: What is the relative market share across standardized career tracks?\n")
cat("Variables: `career_category`, `job_id`\n")

career_dist <- as.data.frame(table(jobs$career_category), stringsAsFactors = FALSE)
names(career_dist) <- c("Career_Category", "Posting_Count")
career_dist <- career_dist[order(-career_dist$Posting_Count), ]
career_dist$Share_Pct <- round((career_dist$Posting_Count / n_total) * 100, 2)

# Save Table
write.csv(career_dist, "outputs/tables/tab_05_career_distribution.csv", row.names = FALSE)

# Generate Plot
png("outputs/figures/fig_05_career_category_distribution.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 12, 4, 3), bg = "#fcfcfc")
bp <- barplot(
  rev(career_dist$Posting_Count),
  names.arg = rev(career_dist$Career_Category),
  horiz = TRUE,
  col = "#2ca02c",
  border = NA,
  main = "Career Category Distribution (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Number of Advertised Postings",
  xlim = c(0, max(career_dist$Posting_Count) * 1.2),
  las = 1,
  cex.names = 0.85,
  cex.axis = 0.9,
  cex.lab = 1.0,
  cex.main = 1.2
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
text(rev(career_dist$Posting_Count) + (max(career_dist$Posting_Count) * 0.03), bp, 
     labels = sprintf("%d (%.1f%%)", rev(career_dist$Posting_Count), rev(career_dist$Share_Pct)), 
     cex = 0.8, font = 2, adj = 0)
dev.off()

# ------------------------------------------------------------------------------
# 4. Analysis 3: Career Category Evolution Over Time (RQ2)
# ------------------------------------------------------------------------------
cat(">>> [3/4] Analyzing Category Evolution Over Time...\n")
cat("Question: How does the category distribution evolve across multi-year cohorts?\n")
cat("Variables: `career_category`, `posting_year`\n")

# Aggregate by 3-year periods for stable demonstration
jobs$period_bracket <- ifelse(jobs$posting_year <= 2019, "2016-2019",
                       ifelse(jobs$posting_year <= 2022, "2020-2022", "2023-2026"))

period_cat_tab <- as.data.frame(table(jobs$career_category, jobs$period_bracket), stringsAsFactors = FALSE)
names(period_cat_tab) <- c("Career_Category", "Period", "Count")
write.csv(period_cat_tab, "outputs/tables/tab_05_category_evolution.csv", row.names = FALSE)

# Generate Stacked Barplot
ctab <- table(jobs$career_category, jobs$period_bracket)
prop_ctab <- prop.table(ctab, margin = 2) * 100

png("outputs/figures/fig_05_category_evolution_over_time.png", width = 2200, height = 1400, res = 200)
par(mar = c(5, 5, 4, 10), bg = "#fcfcfc")
cols <- c("#1f77b4", "#aec7e8", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2")
bp <- barplot(
  prop_ctab,
  col = cols,
  border = "#ffffff",
  main = "Career Category Share by Era (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Time Period",
  ylab = "Percentage Share (%)",
  ylim = c(0, 100),
  las = 1,
  cex.names = 1.0,
  cex.axis = 0.9
)
par(xpd = TRUE)
legend(
  x = max(bp) + 0.6, y = 90,
  legend = rownames(prop_ctab),
  fill = cols,
  border = NA,
  bty = "n",
  cex = 0.8,
  title = "Career Category"
)
par(xpd = FALSE)
dev.off()

# ------------------------------------------------------------------------------
# 5. Analysis 4: Entry-Level Accessibility Distribution (RQ4)
# ------------------------------------------------------------------------------
cat(">>> [4/4] Analyzing Entry-Level Distribution by Category...\n")
cat("Question: What proportion of postings are accessible to entry-level candidates?\n")
cat("Variables: `career_category`, `is_entry_level`\n")

entry_tab <- as.data.frame(table(jobs$career_category, jobs$is_entry_level), stringsAsFactors = FALSE)
names(entry_tab) <- c("Career_Category", "Is_Entry_Level", "Count")
entry_wide <- reshape(entry_tab, idvar = "Career_Category", timevar = "Is_Entry_Level", direction = "wide")
names(entry_wide) <- c("Career_Category", "Experienced_Count", "Entry_Level_Count")
entry_wide$Total <- entry_wide$Experienced_Count + entry_wide$Entry_Level_Count
entry_wide$Entry_Level_Pct <- round((entry_wide$Entry_Level_Count / entry_wide$Total) * 100, 2)
entry_wide <- entry_wide[order(-entry_wide$Entry_Level_Pct), ]

write.csv(entry_wide, "outputs/tables/tab_05_entry_level_by_category.csv", row.names = FALSE)

# Generate Plot
png("outputs/figures/fig_05_entry_level_distribution.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 12, 4, 3), bg = "#fcfcfc")
bp <- barplot(
  rev(entry_wide$Entry_Level_Pct),
  names.arg = rev(entry_wide$Career_Category),
  horiz = TRUE,
  col = "#ff7f0e",
  border = NA,
  main = "Entry-Level Job Proportion by Category (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Proportion of Postings Open to Entry-Level (%)",
  xlim = c(0, 100),
  las = 1,
  cex.names = 0.85,
  cex.axis = 0.9
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
text(rev(entry_wide$Entry_Level_Pct) + 2, bp, 
     labels = sprintf("%.1f%% (%d/%d)", rev(entry_wide$Entry_Level_Pct), rev(entry_wide$Entry_Level_Count), rev(entry_wide$Total)), 
     cex = 0.8, font = 2, adj = 0)
dev.off()

# ------------------------------------------------------------------------------
# 6. Generate Findings Markdown Document
# ------------------------------------------------------------------------------
findings_text <- sprintf(
"# Module 05: Job Market & Career Category Analysis Findings

> **DATASET GOVERNANCE NOTICE:**
> **SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE**
> The analytical findings below describe properties of the synthetic development dataset (`jobs_transformed.csv`, n=%d) to verify pipeline execution. They must NOT be cited as empirical claims regarding Sri Lanka.

---

## 1. Volume & Temporal Distribution (RQ1)
- **Total Records Analyzed:** %d synthetic job postings spanning years %d to %d.
- **Annual Intensity:** Annual volume in the synthetic testing dataset ranges from %d to %d postings per year.
- **Output Artifacts:** [tab_05_annual_volume.csv](file:///d:/projects/TechScape/outputs/tables/tab_05_annual_volume.csv), [fig_05_annual_job_volume.png](file:///d:/projects/TechScape/outputs/figures/fig_05_annual_job_volume.png).

---

## 2. Career Category Distribution (RQ2)
- **Dominant Category:** `%s` accounts for the largest share at %.1f%% (%d postings).
- **Secondary Tracks:** `%s` (%.1f%%) and `%s` (%.1f%%).
- **Output Artifacts:** [tab_05_career_distribution.csv](file:///d:/projects/TechScape/outputs/tables/tab_05_career_distribution.csv), [fig_05_career_category_distribution.png](file:///d:/projects/TechScape/outputs/figures/fig_05_career_category_distribution.png).

---

## 3. Entry-Level Accessibility (RQ4)
- **Overall Entry-Level Proportion:** %.1f%% of synthetic positions (%d of %d) require <= 1 year of experience.
- **Highest Entry-Level Share:** `%s` (%.1f%% entry-level).
- **Lowest Entry-Level Share:** `%s` (%.1f%% entry-level).
- **Output Artifacts:** [tab_05_entry_level_by_category.csv](file:///d:/projects/TechScape/outputs/tables/tab_05_entry_level_by_category.csv), [fig_05_entry_level_distribution.png](file:///d:/projects/TechScape/outputs/figures/fig_05_entry_level_distribution.png).
",
  n_total, n_total, min(jobs$posting_year), max(jobs$posting_year),
  min(annual_vol$Posting_Count), max(annual_vol$Posting_Count),
  career_dist$Career_Category[1], career_dist$Share_Pct[1], career_dist$Posting_Count[1],
  career_dist$Career_Category[2], career_dist$Share_Pct[2],
  career_dist$Career_Category[3], career_dist$Share_Pct[3],
  mean(jobs$is_entry_level) * 100, sum(jobs$is_entry_level), n_total,
  entry_wide$Career_Category[1], entry_wide$Entry_Level_Pct[1],
  entry_wide$Career_Category[nrow(entry_wide)], entry_wide$Entry_Level_Pct[nrow(entry_wide)]
)

writeLines(findings_text, "outputs/findings/findings_05_job_market_analysis.md")
cat("✅ Module 05 completed successfully!\n\n")
