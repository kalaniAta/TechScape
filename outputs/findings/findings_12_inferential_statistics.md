# Module 12: Inferential Statistical Hypothesis Testing Findings

> **DATASET GOVERNANCE NOTICE:**
> **VERIFIED REAL SRI LANKAN IT DATA — EMPIRICAL SAMPLE (n=80 Postings, n=26 Disclosed LKR Salaries)**
> All inferential tests below are conducted on the verified real sample with formal evaluation of sample sizes, non-parametric distributions, and exact p-values.

---

## 1. Summary of Statistical Hypotheses & Results

| Hypothesis / Research Focus | Statistical Test | Test Statistic | df | p-value | Decision (alpha = 0.05) |
|---|---|---|---|---|---|
| **Experience Variation by Career Track** | Kruskal-Wallis Test | Chi-sq = 14.243 | 7 | p = 0.0470 | Statistically Significant (p < 0.05) |
| **Salary Disclosure by Work Mode** | Fisher's Exact Test | Odds Ratio = 0.558 | — | p = 0.3126 | Not Significant (p >= 0.05) |
| **Experience vs. Salary Association** | Pearson Correlation | r = 0.955 (t = 15.79) | 24 | p < 0.0001 | Statistically Significant (p < 0.001) |
| **Skill Density: Entry vs. Experienced** | Wilcoxon Rank-Sum | W = 761.0 | — | p = 0.0880 | Not Significant (p >= 0.05) |

---

## 2. Detailed Methodological Interpretations

### 1. Experience Requirements Across Career Tracks
- **Result:** Kruskal-Wallis rank sum test yielded $\chi^2 = 14.243$, $df = 7$, $p = 0.0470$.
- **Finding:** Significant variation in experience thresholds across career tracks (Chi-sq = 14.243, df = 7, p = 0.0470).

### 2. Experience vs. Disclosed LKR Remuneration
- **Result:** Pearson correlation coefficient $r = 0.955$ (95% CI: [0.901, 0.980], $t = 15.79$, $p < 0.0001$). Spearman rank correlation $\rho = 0.915$ ($p < 0.0001$).
- **Finding:** Demonstrates a very strong, statistically significant positive linear relationship between years of experience and monthly salary among disclosing employers in Sri Lanka.

### 3. Skill Density (Entry-Level vs. Experienced Postings)
- **Result:** Mann-Whitney U test yielded $W = 761.0$, $p = 0.0880$. Entry-level roles average 3.43 skills per job versus 3.69 skills in experienced roles.
- **Finding:** While experienced roles demand slightly higher skill breadth on average, the difference does not reach statistical significance at $\alpha = 0.05$ in the $n = 80$ sample.

---

## 3. Academic Caveats & Statistical Power
- The disclosed salary analysis is bounded by the disclosing sample ($n = 26$), which may carry positive selection bias toward formalized employers.
- Subgroup sample sizes for specialized career tracks (e.g. Cyber Security, UI/UX) are small ($n \le 10$); results should be interpreted as exploratory characteristics rather than universal national laws.

