# ==============================================================================
# TechScape: Technical Skills Demand Analysis (R/06_skills_analysis.R)
# ==============================================================================
# PROVENANCE NOTICE:
# SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE
# This script develops and tests the analytical and visualization methods for RQ3
# (Skill Demand Evolution & Penetration).
# ==============================================================================

# Ensure output directories exist
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/findings", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. Ingestion
# ------------------------------------------------------------------------------
cat("\n==============================================================\n")
cat("          MODULE 06: TECHNICAL SKILLS DEMAND ANALYSIS         \n")
cat("==============================================================\n")
cat("DATASET: `data/processed/job_skills_transformed.csv` (SYNTHETIC DEV DATA)\n\n")

skills <- read.csv("data/processed/job_skills_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
jobs <- read.csv("data/processed/jobs_transformed.csv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
n_jobs <- nrow(jobs)
n_skills <- nrow(skills)

# ------------------------------------------------------------------------------
# 2. Analysis 1: Overall Skill Frequency & Penetration (RQ3)
# ------------------------------------------------------------------------------
cat(">>> [1/5] Analyzing Overall Skill Frequency & Penetration...\n")
cat("Question: Which technical skills are most frequently required across all postings?\n")
cat("Variables: `skill_name`, `skill_category`, `job_id`\n")

skill_counts <- as.data.frame(table(skills$skill_name), stringsAsFactors = FALSE)
names(skill_counts) <- c("Skill_Name", "Occurrence_Count")
skill_counts <- skill_counts[order(-skill_counts$Occurrence_Count), ]
skill_counts$Penetration_Pct <- round((skill_counts$Occurrence_Count / n_jobs) * 100, 2)

# Add category lookup
cat_lookup <- unique(skills[, c("skill_name", "skill_category")])
skill_counts <- merge(skill_counts, cat_lookup, by.x = "Skill_Name", by.y = "skill_name", all.x = TRUE)
skill_counts <- skill_counts[order(-skill_counts$Occurrence_Count), ]

write.csv(skill_counts, "outputs/tables/tab_06_overall_skills.csv", row.names = FALSE)

# Plot Top 15 Skills
top15 <- head(skill_counts, 15)
png("outputs/figures/fig_06_top_skills_overall.png", width = 2000, height = 1400, res = 200)
par(mar = c(5, 10, 4, 3), bg = "#fcfcfc")
bp <- barplot(
  rev(top15$Penetration_Pct),
  names.arg = rev(top15$Skill_Name),
  horiz = TRUE,
  col = "#3b528b",
  border = NA,
  main = "Top 15 Most Demanded Skills (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Skill Penetration Rate (% of All Jobs)",
  xlim = c(0, max(top15$Penetration_Pct) * 1.25),
  las = 1,
  cex.names = 0.85,
  cex.axis = 0.9
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
text(rev(top15$Penetration_Pct) + 0.8, bp, 
     labels = sprintf("%.1f%% (%d)", rev(top15$Penetration_Pct), rev(top15$Occurrence_Count)), 
     cex = 0.8, font = 2, adj = 0)
dev.off()

# ------------------------------------------------------------------------------
# 3. Analysis 2: Skill Demand by Technical Domain (RQ3)
# ------------------------------------------------------------------------------
cat(">>> [2/5] Analyzing Skill Demand Across Technical Domains...\n")
cat("Question: What are the top skills within Programming Languages, Frameworks, Cloud, and Databases?\n")

# Top Programming Languages
prog_skills <- subset(skills, skill_category == "Programming Language")
prog_counts <- as.data.frame(table(prog_skills$skill_name), stringsAsFactors = FALSE)
names(prog_counts) <- c("Language", "Count")
prog_counts <- prog_counts[order(-prog_counts$Count), ]
prog_counts$Penetration_Pct <- round((prog_counts$Count / n_jobs) * 100, 2)
write.csv(prog_counts, "outputs/tables/tab_06_programming_languages.csv", row.names = FALSE)

# Top Frameworks
frame_skills <- subset(skills, skill_category == "Framework/Library")
frame_counts <- as.data.frame(table(frame_skills$skill_name), stringsAsFactors = FALSE)
names(frame_counts) <- c("Framework", "Count")
frame_counts <- frame_counts[order(-frame_counts$Count), ]
frame_counts$Penetration_Pct <- round((frame_counts$Count / n_jobs) * 100, 2)
write.csv(frame_counts, "outputs/tables/tab_06_frameworks.csv", row.names = FALSE)

# Top Cloud/DevOps
cloud_skills <- subset(skills, skill_category == "Cloud/DevOps")
cloud_counts <- as.data.frame(table(cloud_skills$skill_name), stringsAsFactors = FALSE)
names(cloud_counts) <- c("Cloud_DevOps_Tool", "Count")
cloud_counts <- cloud_counts[order(-cloud_counts$Count), ]
cloud_counts$Penetration_Pct <- round((cloud_counts$Count / n_jobs) * 100, 2)
write.csv(cloud_counts, "outputs/tables/tab_06_cloud_devops.csv", row.names = FALSE)

# Domain Comparison Plot (2x2 Panel)
png("outputs/figures/fig_06_skills_by_domain.png", width = 2400, height = 1600, res = 200)
par(mfrow = c(2, 2), mar = c(4, 8, 3, 2), bg = "#fcfcfc")

# Panel 1: Languages
p1 <- head(prog_counts, 6)
barplot(rev(p1$Count), names.arg = rev(p1$Language), horiz = TRUE, col = "#21908c", border = NA, 
        main = "Top Programming Languages", xlab = "Occurrences", las = 1, cex.names = 0.9)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)

# Panel 2: Frameworks
p2 <- head(frame_counts, 6)
barplot(rev(p2$Count), names.arg = rev(p2$Framework), horiz = TRUE, col = "#440154", border = NA, 
        main = "Top Frameworks / Libraries", xlab = "Occurrences", las = 1, cex.names = 0.9)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)

# Panel 3: Cloud & DevOps
p3 <- head(cloud_counts, 6)
barplot(rev(p3$Count), names.arg = rev(p3$Cloud_DevOps_Tool), horiz = TRUE, col = "#fde725", border = NA, 
        main = "Top Cloud / DevOps Tools", xlab = "Occurrences", las = 1, cex.names = 0.9)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)

# Panel 4: Skill Category Distribution
cat_counts <- as.data.frame(table(skills$skill_category), stringsAsFactors = FALSE)
names(cat_counts) <- c("Category", "Count")
cat_counts <- cat_counts[order(cat_counts$Count), ]
barplot(cat_counts$Count, names.arg = cat_counts$Category, horiz = TRUE, col = "#5dc863", border = NA, 
        main = "Skill Distribution by Category", xlab = "Total Occurrences", las = 1, cex.names = 0.8)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)

mtext("SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE", side = 1, outer = TRUE, line = -1, cex = 0.8, col = "#666666")
dev.off()

# ------------------------------------------------------------------------------
# 4. Analysis 3: Skill Penetration by Career Category (RQ3)
# ------------------------------------------------------------------------------
cat(">>> [3/5] Analyzing Top Skills per Career Category...\n")
cat("Question: What are the primary skill signatures across different career tracks?\n")

top_skills_by_career <- list()
careers <- unique(skills$career_category)

for (car in careers) {
  sub_sk <- subset(skills, career_category == car)
  n_car_jobs <- length(unique(sub_sk$job_id))
  sk_t <- head(sort(table(sub_sk$skill_name), decreasing = TRUE), 5)
  df_t <- data.frame(
    Career_Category = car,
    Skill_Name = names(sk_t),
    Occurrences = as.integer(sk_t),
    Category_Penetration_Pct = round((as.integer(sk_t) / max(1, n_car_jobs)) * 100, 1),
    stringsAsFactors = FALSE
  )
  top_skills_by_career[[car]] <- df_t
}

top_career_skills_df <- do.call(rbind, top_skills_by_career)
write.csv(top_career_skills_df, "outputs/tables/tab_06_skills_by_career.csv", row.names = FALSE)

# ------------------------------------------------------------------------------
# 5. Analysis 4: Skill Requirement Density (Skills Per Job)
# ------------------------------------------------------------------------------
cat(">>> [4/5] Analyzing Skill Density (Average Skills Required Per Job)...\n")
cat("Question: How many distinct skills are expected per job posting across categories?\n")

skills_per_job <- aggregate(skill_name ~ job_id + career_category, data = skills, FUN = length)
names(skills_per_job)[3] <- "skill_count"

mean_skills_by_car <- aggregate(skill_count ~ career_category, data = skills_per_job, FUN = function(x) c(Mean = mean(x), Median = median(x), SD = sd(x)))
mean_skills_df <- data.frame(
  Career_Category = mean_skills_by_car$career_category,
  Mean_Skills = round(mean_skills_by_car$skill_count[, "Mean"], 2),
  Median_Skills = mean_skills_by_car$skill_count[, "Median"],
  SD_Skills = round(mean_skills_by_car$skill_count[, "SD"], 2),
  stringsAsFactors = FALSE
)
mean_skills_df <- mean_skills_df[order(-mean_skills_df$Mean_Skills), ]
write.csv(mean_skills_df, "outputs/tables/tab_06_skill_density_by_career.csv", row.names = FALSE)

# Density Boxplot
png("outputs/figures/fig_06_skill_density_by_career.png", width = 2000, height = 1300, res = 200)
par(mar = c(5, 12, 4, 3), bg = "#fcfcfc")
boxplot(
  skill_count ~ career_category,
  data = skills_per_job,
  horizontal = TRUE,
  col = "#6baed6",
  border = "#2171b5",
  main = "Skill Breadth per Job Posting by Category (Synthetic Development Data)",
  sub = "SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE",
  xlab = "Number of Required Skills per Posting",
  las = 1,
  cex.axis = 0.85
)
grid(nx = NULL, ny = NA, col = "#e0e0e0", lty = 2)
dev.off()

# ------------------------------------------------------------------------------
# 6. Analysis 5: Skill Evolution Across Eras
# ------------------------------------------------------------------------------
cat(">>> [5/5] Analyzing Temporal Skill Evolution...\n")

skills$era <- ifelse(skills$posting_year <= 2019, "2016-2019",
              ifelse(skills$posting_year <= 2022, "2020-2022", "2023-2026"))

era_skill_tab <- as.data.frame(table(skills$skill_name, skills$era), stringsAsFactors = FALSE)
names(era_skill_tab) <- c("Skill_Name", "Era", "Count")
write.csv(era_skill_tab, "outputs/tables/tab_06_skill_evolution_era.csv", row.names = FALSE)

# ------------------------------------------------------------------------------
# 7. Generate Findings Document
# ------------------------------------------------------------------------------
findings_text <- sprintf(
"# Module 06: Technical Skills Demand Analysis Findings

> **DATASET GOVERNANCE NOTICE:**
> **SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE**
> The analytical findings below describe properties of the synthetic development dataset (`job_skills_transformed.csv`, n=%d skills across %d jobs). They must NOT be cited as empirical claims regarding Sri Lanka.

---

## 1. Overall Skill Frequency & Penetration (RQ3)
- **Top Demanded Skill in Testing Asset:** `%s` with %d occurrences (%.1f%% overall penetration).
- **Subsequent Top Skills:** `%s` (%.1f%%) and `%s` (%.1f%%).
- **Output Artifacts:** [tab_06_overall_skills.csv](file:///d:/projects/TechScape/outputs/tables/tab_06_overall_skills.csv), [fig_06_top_skills_overall.png](file:///d:/projects/TechScape/outputs/figures/fig_06_top_skills_overall.png).

---

## 2. Domain-Specific Skill Leaders
- **Programming Languages:** Top 3: `%s` (%d), `%s` (%d), `%s` (%d).
- **Frameworks & Libraries:** Top 3: `%s` (%d), `%s` (%d), `%s` (%d).
- **Cloud & DevOps:** Top 3: `%s` (%d), `%s` (%d), `%s` (%d).
- **Output Artifacts:** [tab_06_programming_languages.csv](file:///d:/projects/TechScape/outputs/tables/tab_06_programming_languages.csv), [tab_06_frameworks.csv](file:///d:/projects/TechScape/outputs/tables/tab_06_frameworks.csv), [tab_06_cloud_devops.csv](file:///d:/projects/TechScape/outputs/tables/tab_06_cloud_devops.csv), [fig_06_skills_by_domain.png](file:///d:/projects/TechScape/outputs/figures/fig_06_skills_by_domain.png).

---

## 3. Skill Density (Breadth per Posting)
- **Average Skills Required:** %.2f skills per posting (Range: %d to %d).
- **Category with Highest Density:** `%s` (Mean: %.2f skills).
- **Output Artifacts:** [tab_06_skill_density_by_career.csv](file:///d:/projects/TechScape/outputs/tables/tab_06_skill_density_by_career.csv), [fig_06_skill_density_by_career.png](file:///d:/projects/TechScape/outputs/figures/fig_06_skill_density_by_career.png).
",
  n_skills, n_jobs,
  skill_counts$Skill_Name[1], skill_counts$Occurrence_Count[1], skill_counts$Penetration_Pct[1],
  skill_counts$Skill_Name[2], skill_counts$Penetration_Pct[2],
  skill_counts$Skill_Name[3], skill_counts$Penetration_Pct[3],
  prog_counts$Language[1], prog_counts$Count[1], prog_counts$Language[2], prog_counts$Count[2], prog_counts$Language[3], prog_counts$Count[3],
  frame_counts$Framework[1], frame_counts$Count[1], frame_counts$Framework[2], frame_counts$Count[2], frame_counts$Framework[3], frame_counts$Count[3],
  cloud_counts$Cloud_DevOps_Tool[1], cloud_counts$Count[1], cloud_counts$Cloud_DevOps_Tool[2], cloud_counts$Count[2], cloud_counts$Cloud_DevOps_Tool[3], cloud_counts$Count[3],
  mean(jobs$skill_count), min(jobs$skill_count), max(jobs$skill_count),
  mean_skills_df$Career_Category[1], mean_skills_df$Mean_Skills[1]
)

writeLines(findings_text, "outputs/findings/findings_06_skills_analysis.md")
cat("✅ Module 06 completed successfully!\n\n")
