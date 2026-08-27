# TechScape: Final Academic Synthesis & Labour Market Report

> **DISSERTATION & ACADEMIC SUBMISSION SPECIFICATION**
> **Dataset Provenance:** Derived from **80 verified Sri Lankan IT job postings** across 39 tech employers collected in August 2026, alongside official macroeconomic datasets from the **Department of Census & Statistics (DCS)** and **Central Bank of Sri Lanka (CBSL)**.
> **Epistemic Principle:** Explicit separation of observed empirical evidence, inferential statistical test decisions, academic interpretations, undergraduate guidance, and methodological limitations.

---

## 1. Observed Empirical Findings (Direct Data Observations)

### 1.1. Career Track Demand Composition (RQ2)
- **Dominant Track:** Software Engineering accounts for **25.00%** (20 of 80 postings) of advertised vacancies.
- **Specialized Engineering Tracks:** Data & AI / ML represents **13.75%** (11 postings), Cloud & DevOps represents **12.50%** (10 postings), QA & Test Automation represents **11.25%** (9 postings), Cyber Security represents **10.00%** (8 postings), and IT Systems / Infrastructure represents **10.00%** (8 postings).
- **Management & Design:** Management & Business Analysis represents **8.75%** (7 postings) and UI/UX & Product Design represents **8.75%** (7 postings).

### 1.2. Technical Skills Penetration Rates (RQ3)
- **Top Demanded Technical Skills (n=80):**
  1. `Python`: 9 occurrences (11.25% penetration)
  2. `Kubernetes`: 8 occurrences (10.00% penetration)
  3. `Figma`: 7 occurrences (8.75% penetration)
  4. `Linux`: 7 occurrences (8.75% penetration)
  5. `PostgreSQL`: 7 occurrences (8.75% penetration)
  6. `SQL`: 7 occurrences (8.75% penetration)
  7. `Java`: 6 occurrences (7.50% penetration)
  8. `React`: 6 occurrences (7.50% penetration)
  9. `TypeScript`: 6 occurrences (7.50% penetration)
  10. `JIRA`: 6 occurrences (7.50% penetration)

### 1.3. Compensation & Currency Characteristics (RQ6)
- **Salary Transparency:** 43.75% of postings (35 of 80) disclosed numeric compensation; 56.25% (45 of 80) used qualitative negotiation terms.
- **LKR Disclosed Midpoints (n=26):** Median monthly salary was **LKR 330,000** (Mean: LKR 317,404; IQR: LKR 310,000; Range: LKR 40,000 to LKR 850,000).
- **USD-Pegged Contracts (n=9):** Comprised **25.71%** of all disclosed postings with a median monthly package of **USD $1,600** (Range: USD $1,100 to $2,500/month).

### 1.4. Experience Requirements & Accessibility (RQ4, RQ5)
- **Overall Spread:** Mean required experience is **3.12 years**; median is **3.00 years** (IQR: 4.00 years; range: 0 to 8 years).
- **Entry-Level Opportunities:** **26.25%** of postings (21 of 80) are accessible to candidates with $\le 1$ year of experience or intern/trainee seniority.

### 1.5. Work Mode Distribution & Industry Flexibility (RQ8)
- **Hybrid Arrangements:** **65.00%** of postings (52 of 80).
- **On-Site Requirements:** **26.25%** of postings (21 of 80), primarily in banking operations, network security, and infrastructure support.
- **Remote-First Postings:** **8.75%** of postings (7 of 80), exclusively in export software engineering and design.

---

## 2. Statistical Findings (Inferential Hypothesis Testing)

| Research Hypothesis | Statistical Test | Test Statistic | df | p-value | Academic Decision ($\alpha = 0.05$) |
|---|---|---|---|---|---|
| **$H_1$: Experience thresholds differ across career tracks** | Kruskal-Wallis Rank Sum | $\chi^2 = 14.243$ | 7 | $p = 0.0470$ | **Statistically Significant ($p < 0.05$):** Rejects null; significant distributional variation in experience exists between roles. |
| **$H_2$: Salary disclosure rate is associated with work mode** | Fisher's Exact Test | Odds Ratio = 0.558 | — | $p = 0.3126$ | **Not Significant ($p \ge 0.05$):** Fails to reject null; disclosure rates do not differ significantly between flexible and on-site roles. |
| **$H_3$: Experience is positively correlated with LKR salary** | Pearson Correlation | $r = 0.955$ ($t = 15.79$) | 24 | $p < 0.00001$ | **Statistically Significant ($p < 0.001$):** Very strong positive linear relationship (95% CI: $[0.901, 0.980]$). Spearman $\rho = 0.915$. |
| **$H_4$: Skill breadth differs between entry-level & senior roles** | Wilcoxon Rank-Sum | $W = 761.0$ | — | $p = 0.0880$ | **Not Significant ($p \ge 0.05$):** Experienced roles average 3.70 skills vs 3.43 in entry-level, but difference is not statistically significant at $\alpha = 0.05$. |

---

## 3. Academic Interpretations

1. **Enterprise Custom Software Anchoring:** Software engineering remains the volume anchor of Sri Lankan tech recruitment, but specialized disciplines (Cloud, Data, Security, QA) collectively represent **57.50%** of hiring demand, indicating a maturing, highly diversified industry.
2. **Dual-Currency Labor Market Dynamics:** The high prevalence of USD-denominated contracts (25.71% of disclosed salaries) demonstrates how Sri Lankan tech export firms insulate specialized talent against domestic currency fluctuations.
3. **Macroeconomic Decoupling:** Central Bank statistics show ICT service export earnings grew by **+54.3%** between 2019 ($985M) and 2025 ($1,520M), exhibiting resilience even during national macroeconomic crisis periods when youth unemployment reached 17.2% (DCS LFS).

---

## 4. Student Career Guidance (Evidence-Backed Insights)

1. **Master Core Language Fundamentals:** High demand for Java, Python, and TypeScript underscores the value of mastering object-oriented design and algorithm fundamentals before pursuing specialized libraries.
2. **Integrate Containerization Early:** Kubernetes and Docker appear in over 20% of engineering vacancies. Undergraduates should deploy personal coursework projects using Docker containers and GitHub Actions CI/CD.
3. **Leverage Structured Internships:** The entry-level starting salary tier (LKR 110,000–160,000 for associates; LKR 40,000–50,000 for interns) serves as the primary stepping stone to higher-earning senior tiers where pay scales exceed LKR 500,000/month.

---

## 5. Methodological Limitations

- **Cross-Sectional Scope:** Sourced from an empirical sample of $n = 80$ postings in August 2026; results must be treated as sample characteristics rather than a complete national census.
- **Salary Non-Disclosure Selection:** 56.25% of postings omitted numerical pay figures; compensation statistics reflect only disclosing organizations.
- **Observational Constraint:** Statistical correlations ($r = 0.955$) represent descriptive associations and must not be interpreted as causal determinants.
