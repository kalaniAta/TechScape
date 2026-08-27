# ==============================================================================
# TechScape: Multi-Dimensional Cross Analysis (R/09_cross_analysis.R)
# ==============================================================================
# PROVENANCE NOTICE:
# SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE
# This script develops and tests bivariate and multi-dimensional cross-analysis
# routines (Skills vs. Salary, Skills vs. Experience, Career vs. Experience,
# and Entry-Level Skill Profiles).
# ==============================================================================

# Ensure output directories exist
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/findings", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. Ingestion
# ------------------------------------------------------------------------------
cat("\n==============================================================\n")
cat("          MODULE 09: MULTI-DIMENSIONAL CROSS ANALYSIS         \n")
cat("==============================================================\n")
cat("DATASETS: `jobs_transformed.csv` & `job_skills_transformed.csv` (SYNTHETIC)\n\n")

jobs <- read.csv("data/processed/jobs_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
skills <- read.csv("data/processed/job_skills_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))

# Join jobs salary & experience fields onto skills table avoiding column name collisions
job_salary_attr <- jobs[, c("job_id", "salary_midpoint", "currency", "experience_min")]
sk_merged <- merge(skills, job_salary_attr, by = "job_id", all.x = TRUE)

# ------------------------------------------------------------------------------
# 2. Analysis 1: Top Skills vs. Disclosed LKR Salary
# ------------------------------------------------------------------------------
cat(">>> [1/4] Analyzing Skills vs. Disclosed LKR Salary...\n")
cat("Question: What are the median compensation levels associated with prominent skills?\n")

sk_lkr <- subset(sk_merged, currency == "LKR" & !is.na(salary_midpoint))
top_skills_list <- names(head(sort(table(sk_lkr$skill_name), decreasing = TRUE), 10))

skill_sal_list <- list()
for (sk in top_skills_list) {
  sub_s <- subset(sk_lkr, skill_name == sk)
  skill_sal_list[[sk]] <- data.frame(
    Skill_Name = sk,
    Disclosed_Postings = nrow(sub_s),
    Median_LKR = median(sub_s$salary_midpoint),
    Mean_LKR = round(mean(sub_s$salary_midpoint)),
    stringsAsFactors = FALSE
  )
}
skill_sal_df <- do.call(rbind, skill_sal_list)
skill_sal_df <- skill_sal_df[order(-skill_sal_df$Median_LKR), ]
write.csv(skill_sal_df, "outputs/tables/tab_09_skills_vs_salary.csv", row.names = FALSE)

# Plot Skills vs Salary
png("outputs/figures/fig_09_skills_vs_salary.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 10, 4, 3), bg = "#fcfcfc")
bp <- barplot(
  rev(skill_sal_df$Median_LKR) / 1000,
  names.arg = rev(skill_sal_df$Skill_Name),
  horiz = TRUE,
  col = "#1b9e77",
  border = NA,
  main = "Median Monthly Salary (LKR) by Skill (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Median Monthly Salary (Thousand LKR)",
  las = 1,
  cex.names = 0.85
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
text(rev(skill_sal_df$Median_LKR) / 1000 + 15, bp, 
     labels = sprintf("LKR %sk", format(rev(skill_sal_df$Median_LKR) / 1000, big.mark=",")), 
     cex = 0.8, font = 2, adj = 0)
dev.off()

# ------------------------------------------------------------------------------
# 3. Analysis 2: Skills vs. Required Experience
# ------------------------------------------------------------------------------
cat(">>> [2/4] Analyzing Skills vs. Required Experience...\n")
cat("Question: What average experience threshold is demanded for key technologies?\n")

top_all_skills <- names(head(sort(table(sk_merged$skill_name), decreasing = TRUE), 12))
sk_exp_list <- list()

for (sk in top_all_skills) {
  sub_e <- subset(sk_merged, skill_name == sk)
  sk_exp_list[[sk]] <- data.frame(
    Skill_Name = sk,
    Postings_Count = nrow(sub_e),
    Mean_Exp_Years = round(mean(sub_e$experience_min, na.rm=TRUE), 2),
    Median_Exp_Years = median(sub_e$experience_min, na.rm=TRUE),
    stringsAsFactors = FALSE
  )
}
sk_exp_df <- do.call(rbind, sk_exp_list)
sk_exp_df <- sk_exp_df[order(-sk_exp_df$Mean_Exp_Years), ]
write.csv(sk_exp_df, "outputs/tables/tab_09_skills_vs_experience.csv", row.names = FALSE)

# ------------------------------------------------------------------------------
# 4. Analysis 3: Career Category vs. Experience Band Contingency Matrix
# ------------------------------------------------------------------------------
cat(">>> [3/4] Generating Career Category vs. Experience Contingency Matrix...\n")

car_exp_ctab <- table(jobs$career_category, jobs$experience_band)
car_exp_df <- as.data.frame.matrix(car_exp_ctab)
car_exp_df$Career_Category <- rownames(car_exp_df)
car_exp_df <- car_exp_df[, c("Career_Category", setdiff(names(car_exp_df), "Career_Category"))]
write.csv(car_exp_df, "outputs/tables/tab_09_career_vs_experience_matrix.csv", row.names = FALSE)

# ------------------------------------------------------------------------------
# 5. Analysis 4: Entry-Level vs. Senior Skill Requirements
# ------------------------------------------------------------------------------
cat(">>> [4/4] Comparing Skill Profiles: Entry-Level vs. Experienced Postings...\n")
cat("Question: Which technical skills are disproportionately demanded in entry-level roles?\n")

entry_skills <- subset(sk_merged, is_entry_level == TRUE)
exp_skills <- subset(sk_merged, is_entry_level == FALSE)

n_entry_jobs <- sum(jobs$is_entry_level)
n_exp_jobs <- sum(!jobs$is_entry_level)

entry_sk_t <- as.data.frame(table(entry_skills$skill_name), stringsAsFactors = FALSE)
names(entry_sk_t) <- c("Skill_Name", "Entry_Count")
entry_sk_t$Entry_Penetration_Pct <- round((entry_sk_t$Entry_Count / n_entry_jobs) * 100, 1)

exp_sk_t <- as.data.frame(table(exp_skills$skill_name), stringsAsFactors = FALSE)
names(exp_sk_t) <- c("Skill_Name", "Exp_Count")
exp_sk_t$Exp_Penetration_Pct <- round((exp_sk_t$Exp_Count / n_exp_jobs) * 100, 1)

comp_sk <- merge(entry_sk_t, exp_sk_t, by = "Skill_Name", all = TRUE)
comp_sk[is.na(comp_sk)] <- 0
comp_sk$Total_Occurrences <- comp_sk$Entry_Count + comp_sk$Exp_Count
comp_sk <- comp_sk[order(-comp_sk$Total_Occurrences), ]
write.csv(comp_sk, "outputs/tables/tab_09_entry_vs_experienced_skills.csv", row.names = FALSE)

# Dual Barplot for Top 8 Entry-Level Skills
top_entry <- head(comp_sk[order(-comp_sk$Entry_Penetration_Pct), ], 8)
png("outputs/figures/fig_09_entry_vs_experienced_skills.png", width = 2200, height = 1400, res = 200)
par(mar = c(5, 10, 4, 3), bg = "#fcfcfc")

entry_mat <- rbind(top_entry$Entry_Penetration_Pct, top_entry$Exp_Penetration_Pct)
colnames(entry_mat) <- top_entry$Skill_Name

bp <- barplot(
  entry_mat,
  beside = TRUE,
  col = c("#3182bd", "#9ecae1"),
  border = NA,
  main = "Skill Penetration: Entry-Level vs. Experienced Roles (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Penetration Rate (% of Jobs in Group)",
  ylab = "",
  horiz = TRUE,
  las = 1,
  cex.names = 0.85
)
legend("bottomright", legend = c("Entry-Level (<=1 yr)", "Experienced (>1 yr)"), 
       fill = c("#3182bd", "#9ecae1"), border = NA, bty = "n")
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
dev.off()

# ------------------------------------------------------------------------------
# 6. Generate Findings Document
# ------------------------------------------------------------------------------
findings_text <- sprintf(
"# Module 09: Multi-Dimensional Cross Analysis Findings

> **DATASET GOVERNANCE NOTICE:**
> **SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE**
> The analytical findings below describe properties of the synthetic development dataset (`jobs_transformed.csv`, n=%d). They must NOT be cited as empirical claims regarding Sri Lanka.

---

## 1. Skill Compensation Associations (LKR)
- **Top Compensated Skill in Testing Set:** `%s` (Median: LKR %s).
- **Secondary Compensated Skills:** `%s` (LKR %s), `%s` (LKR %s).
- **Output Artifacts:** [tab_09_skills_vs_salary.csv](file:///d:/projects/TechScape/outputs/tables/tab_09_skills_vs_salary.csv), [fig_09_skills_vs_salary.png](file:///d:/projects/TechScape/outputs/figures/fig_09_skills_vs_salary.png).

---

## 2. Skill Experience Requirements
- **Highest Mean Experience Skill:** `%s` (Mean: %.2f years).
- **Lowest Mean Experience Skill (Accessible):** `%s` (Mean: %.2f years).
- **Output Artifacts:** [tab_09_skills_vs_experience.csv](file:///d:/projects/TechScape/outputs/tables/tab_09_skills_vs_experience.csv).

---

## 3. Entry-Level Skill Profiles
- **Top Requested Skills for Entry-Level Candidates:**
  1. `%s` (%.1f%% penetration in entry roles)
  2. `%s` (%.1f%% penetration in entry roles)
  3. `%s` (%.1f%% penetration in entry roles)
- **Output Artifacts:** [tab_09_entry_vs_experienced_skills.csv](file:///d:/projects/TechScape/outputs/tables/tab_09_entry_vs_experienced_skills.csv), [fig_09_entry_vs_experienced_skills.png](file:///d:/projects/TechScape/outputs/figures/fig_09_entry_vs_experienced_skills.png).
",
  nrow(jobs),
  skill_sal_df$Skill_Name[1], format(skill_sal_df$Median_LKR[1], big.mark=","),
  skill_sal_df$Skill_Name[2], format(skill_sal_df$Median_LKR[2], big.mark=","),
  skill_sal_df$Skill_Name[3], format(skill_sal_df$Median_LKR[3], big.mark=","),
  sk_exp_df$Skill_Name[1], sk_exp_df$Mean_Exp_Years[1],
  sk_exp_df$Skill_Name[nrow(sk_exp_df)], sk_exp_df$Mean_Exp_Years[nrow(sk_exp_df)],
  top_entry$Skill_Name[1], top_entry$Entry_Penetration_Pct[1],
  top_entry$Skill_Name[2], top_entry$Entry_Penetration_Pct[2],
  top_entry$Skill_Name[3], top_entry$Entry_Penetration_Pct[3]
)

writeLines(findings_text, "outputs/findings/findings_09_cross_analysis.md")
cat("✅ Module 09 completed successfully!\n\n")
