# ==============================================================================
# TechScape: Complete Empirical & Statistical Metrics Recalculation Audit
# (tests/data_quality/audit_recalculate_metrics.R)
# ==============================================================================
# Purpose: Recalculates every single reported number and statistic directly
# from the active real dataset files to verify 100% mathematical precision.
# ==============================================================================

jobs_raw <- read.csv("data/real_sample/jobs_real_sample.csv", stringsAsFactors = FALSE)
skills_raw <- read.csv("data/real_sample/job_skills_real_sample.csv", stringsAsFactors = FALSE)
jobs_trans <- read.csv("data/processed/jobs_real_transformed.csv", stringsAsFactors = FALSE)
skills_trans <- read.csv("data/processed/job_skills_real_transformed.csv", stringsAsFactors = FALSE)
macro <- read.csv("data/processed/macro_labour_indicators.csv", stringsAsFactors = FALSE)

cat("\n==============================================================\n")
cat("          TECHSCAPE DIRECT METRIC AUDIT & RECALCULATION       \n")
cat("==============================================================\n\n")

# 1. Dataset Dimensions & Basic Counts
n_jobs <- nrow(jobs_trans)
n_skills <- nrow(skills_trans)
n_employers <- length(unique(jobs_trans$company))

cat(sprintf("1. DATASET DIMENSIONS:\n"))
cat(sprintf("   - Total Verified Real Jobs: %d\n", n_jobs))
cat(sprintf("   - Total Transformed Skills: %d\n", n_skills))
cat(sprintf("   - Unique Employers: %d\n\n", n_employers))

# 2. Career Category Breakdown
cat(sprintf("2. CAREER CATEGORY BREAKDOWN (n=%d):\n", n_jobs))
car_tab <- as.data.frame(table(jobs_trans$career_category), stringsAsFactors = FALSE)
names(car_tab) <- c("Category", "Count")
car_tab$Pct <- round((car_tab$Count / n_jobs) * 100, 2)
car_tab <- car_tab[order(-car_tab$Count), ]
for(i in 1:nrow(car_tab)) {
  cat(sprintf("   - %s: %d (%.2f%%)\n", car_tab$Category[i], car_tab$Count[i], car_tab$Pct[i]))
}

# 3. Entry-Level Accessibility
entry_count <- sum(jobs_trans$is_entry_level)
entry_pct <- round((entry_count / n_jobs) * 100, 2)
cat(sprintf("\n3. ENTRY-LEVEL ACCESSIBILITY:\n"))
cat(sprintf("   - Entry-Level Postings (<=1 yr / intern / junior): %d of %d (%.2f%%)\n", entry_count, n_jobs, entry_pct))

# 4. Salary Transparency & Non-Disclosure
sal_disclosed_count <- sum(jobs_trans$salary_disclosed)
sal_undisclosed_count <- sum(!jobs_trans$salary_disclosed)
sal_disclosed_pct <- round((sal_disclosed_count / n_jobs) * 100, 2)
sal_undisclosed_pct <- round((sal_undisclosed_count / n_jobs) * 100, 2)

cat(sprintf("\n4. COMPENSATION TRANSPARENCY:\n"))
cat(sprintf("   - Disclosed Postings: %d (%.2f%%)\n", sal_disclosed_count, sal_disclosed_pct))
cat(sprintf("   - Undisclosed Postings (NA / Qualitative): %d (%.2f%%)\n", sal_undisclosed_count, sal_undisclosed_pct))

# 5. Currency Breakdown
lkr_total <- sum(jobs_trans$currency == "LKR", na.rm=TRUE)
usd_total <- sum(jobs_trans$currency == "USD", na.rm=TRUE)
lkr_disclosed <- subset(jobs_trans, currency == "LKR" & !is.na(salary_midpoint))
usd_disclosed <- subset(jobs_trans, currency == "USD" & !is.na(salary_midpoint))

cat(sprintf("\n5. CURRENCY DISTRIBUTION:\n"))
cat(sprintf("   - LKR Disclosed Postings: %d\n", nrow(lkr_disclosed)))
cat(sprintf("   - USD Disclosed Postings: %d (%.2f%% of all disclosed postings)\n", nrow(usd_disclosed), (nrow(usd_disclosed)/sal_disclosed_count)*100))
cat(sprintf("   - LKR Median Midpoint: LKR %s\n", format(median(lkr_disclosed$salary_midpoint), big.mark=",")))
cat(sprintf("   - LKR Mean Midpoint: LKR %s (SD: LKR %s)\n", format(round(mean(lkr_disclosed$salary_midpoint)), big.mark=","), format(round(sd(lkr_disclosed$salary_midpoint)), big.mark=",")))
cat(sprintf("   - LKR IQR: LKR %s (Q1: LKR %s, Q3: LKR %s)\n", format(IQR(lkr_disclosed$salary_midpoint), big.mark=","), format(quantile(lkr_disclosed$salary_midpoint, 0.25), big.mark=","), format(quantile(lkr_disclosed$salary_midpoint, 0.75), big.mark=",")))
cat(sprintf("   - LKR Min - Max: LKR %s to LKR %s\n", format(min(lkr_disclosed$salary_midpoint), big.mark=","), format(max(lkr_disclosed$salary_midpoint), big.mark=",")))
cat(sprintf("   - USD Median Midpoint: USD $%s (Range: $%s - $%s)\n", format(median(usd_disclosed$salary_midpoint), big.mark=","), format(min(usd_disclosed$salary_midpoint), big.mark=","), format(max(usd_disclosed$salary_midpoint), big.mark=",")))

# 6. Experience Metrics
cat(sprintf("\n6. EXPERIENCE DISTRIBUTION:\n"))
cat(sprintf("   - Mean Experience Required: %.2f years\n", mean(jobs_trans$experience_min, na.rm=TRUE)))
cat(sprintf("   - Median Experience Required: %.2f years (IQR: %.2f years)\n", median(jobs_trans$experience_min, na.rm=TRUE), IQR(jobs_trans$experience_min, na.rm=TRUE)))
cat(sprintf("   - Min - Max Experience Required: %d to %d years\n", min(jobs_trans$experience_min, na.rm=TRUE), max(jobs_trans$experience_min, na.rm=TRUE)))

# 7. Top Skills
sk_counts <- as.data.frame(table(skills_trans$skill_name), stringsAsFactors = FALSE)
names(sk_counts) <- c("Skill", "Count")
sk_counts$Penetration <- round((sk_counts$Count / n_jobs) * 100, 2)
sk_counts <- sk_counts[order(-sk_counts$Count), ]

cat(sprintf("\n7. TOP 10 TECHNICAL SKILLS DEMAND:\n"))
for(i in 1:min(10, nrow(sk_counts))) {
  cat(sprintf("   %2d. %-15s: %2d occurrences (%.2f%% penetration)\n", i, sk_counts$Skill[i], sk_counts$Count[i], sk_counts$Penetration[i]))
}

# 8. Work Mode
wm_tab <- as.data.frame(table(jobs_trans$work_mode), stringsAsFactors = FALSE)
names(wm_tab) <- c("Mode", "Count")
wm_tab$Pct <- round((wm_tab$Count / n_jobs) * 100, 2)
wm_tab <- wm_tab[order(-wm_tab$Count), ]
cat(sprintf("\n8. WORK MODE BREAKDOWN:\n"))
for(i in 1:nrow(wm_tab)) {
  cat(sprintf("   - %-10s: %2d (%.2f%%)\n", wm_tab$Mode[i], wm_tab$Count[i], wm_tab$Pct[i]))
}

# 9. Statistical Tests Verification
cat(sprintf("\n9. EXACT INFERENTIAL STATISTICAL TESTS:\n"))

# Kruskal-Wallis
kw <- kruskal.test(experience_min ~ career_category, data = jobs_trans)
cat(sprintf("   A. Kruskal-Wallis Test (Experience by Career):\n"))
cat(sprintf("      - Chi-sq = %.5f, df = %d, p = %.6f (Significant: %s)\n", kw$statistic, kw$parameter, kw$p.value, kw$p.value < 0.05))

# Pairwise Wilcoxon Post-Hoc Test with Holm adjustment
pw_wilcox <- pairwise.wilcox.test(jobs_trans$experience_min, jobs_trans$career_category, p.adjust.method = "holm")
cat(sprintf("      - Post-Hoc Pairwise Wilcoxon (Holm adjusted) p-value matrix computed.\n"))

# Fisher's Exact Test
jobs_trans$work_mode_bin <- ifelse(jobs_trans$work_mode == "On-site", "On-site", "Flexible")
ctab <- table(jobs_trans$work_mode_bin, jobs_trans$salary_disclosed)
fisher <- fisher.test(ctab)
cat(sprintf("\n   B. Fisher's Exact Test (Salary Disclosure by Work Mode):\n"))
cat(sprintf("      - Odds Ratio = %.5f, p = %.6f (Significant: %s)\n", fisher$estimate, fisher$p.value, fisher$p.value < 0.05))
cat(sprintf("      - Flexible disclosure: %d/%d (%.2f%%) vs On-site disclosure: %d/%d (%.2f%%)\n",
            ctab["Flexible", "TRUE"], sum(ctab["Flexible", ]), (ctab["Flexible", "TRUE"]/sum(ctab["Flexible", ]))*100,
            ctab["On-site", "TRUE"], sum(ctab["On-site", ]), (ctab["On-site", "TRUE"]/sum(ctab["On-site", ]))*100))

# Pearson & Spearman Correlation
cor_p <- cor.test(lkr_disclosed$experience_min, lkr_disclosed$salary_midpoint, method = "pearson")
cor_s <- cor.test(lkr_disclosed$experience_min, lkr_disclosed$salary_midpoint, method = "spearman", exact = FALSE)
cat(sprintf("\n   C. Experience vs. Disclosed LKR Salary Correlation (n=%d):\n", nrow(lkr_disclosed)))
cat(sprintf("      - Pearson r = %.5f (t = %.5f, df = %d, p = %.8f, 95%% CI: [%.5f, %.5f])\n",
            cor_p$estimate, cor_p$statistic, cor_p$parameter, cor_p$p.value, cor_p$conf.int[1], cor_p$conf.int[2]))
cat(sprintf("      - Spearman rho = %.5f (p = %.8f)\n", cor_s$estimate, cor_s$p.value))

# Wilcoxon Rank-Sum Test
wilcox <- wilcox.test(skill_count ~ is_entry_level, data = jobs_trans)
entry_mean_sk <- mean(subset(jobs_trans, is_entry_level == TRUE)$skill_count)
exp_mean_sk <- mean(subset(jobs_trans, is_entry_level == FALSE)$skill_count)
cat(sprintf("\n   D. Skill Breadth by Seniority (Wilcoxon Rank-Sum Test):\n"))
cat(sprintf("      - W = %.2f, p = %.6f (Significant: %s)\n", wilcox$statistic, wilcox$p.value, wilcox$p.value < 0.05))
cat(sprintf("      - Entry-Level Mean Skills: %.3f vs Experienced Mean Skills: %.3f\n\n", entry_mean_sk, exp_mean_sk))

cat("==============================================================\n")
cat("✅ AUDIT RECALCULATION COMPLETE!\n")
cat("==============================================================\n")
