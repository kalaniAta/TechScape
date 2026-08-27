# TechScape: Research Methodology & Analytical Framework

## 1. Methodological Foundation

TechScape employs an **empirical descriptive and exploratory research design** to examine the Sri Lankan IT labour market. The methodology is structured to ensure complete analytical reproducibility, statistical defensibility, and strict provenance auditing.

```text
DATA REQUIREMENTS & TAXONOMIES
              ↓
  INFERRED REFERENCE SCHEMAS
  (Terminology & Normalization Dev Only)
              ↓
  STRUCTURAL SYNTHETIC GENERATOR
  (Deterministic Seed & Pipeline Stress Testing)
              ↓
  R DATA IMPORT & VALIDATION ENGINE
              ↓
  CLEANING & TRANSFORMATION PIPELINE
  (Designed to seamlessly accept Verified Real Data)
              ↓
  DESCRIPTIVE & CO-OCCURRENCE ANALYTICS
              ↓
  [FUTURE] VERIFIED REAL DATA ACQUISITION & MACRO INTEGRATION
              ↓
  SYNTHESIS & VISUALIZATION
```

---

## 2. Dataset Classification & Provenance Governance

Every record and finding in TechScape is explicitly categorized into one of three tiers:

1. **`SYNTHETIC` (`data/synthetic/`):**
   - Synthesized using deterministic pseudorandom generation (`set.seed(42)`).
   - Designed to test field formats, nomenclature, missingness handling, deduplication, and relational joins.
   - **Crucial Rule:** Generated historical trends or category distributions in synthetic datasets are purely testing mechanisms and **must never be cited or interpreted as empirical findings about Sri Lanka's actual labour market**.

2. **`INFERRED REFERENCE` (`data/reference/`):**
   - Manually constructed representative templates based on industry domain knowledge.
   - Used exclusively for schema discovery, title alias compilation, and regex validation.
   - **Crucial Rule:** Zero empirical weight. Must never enter final analytical findings.

3. **`VERIFIED REAL` (`data/real_sample/`):**
   - Reserved strictly for genuine postings with verified, live, auditable provenance (`source`, `source_url`, `collection_date`, `source_job_id`).
   - Sourced with unmodified raw fields (`original_title`, `original_salary`, `original_experience`) preserved alongside analytical variables.
   - Currently **pending ingestion**.

---

## 3. Data Cleaning & Transformation Governance

To preserve data integrity during normalization:
- **Zero Silent Modification:** Raw values are never overwritten in-place; derived clean columns are created in processed tables.
- **Handling of Undisclosed Salaries:** When salary is absent, it is explicitly coded as `NA`, preserving the denominator for disclosure-rate calculations. Undisclosed salaries are never imputed with zero or artificial central tendencies.
- **Handling of Unspecified Experience:** Roles without stated minimum years are preserved as `NA` unless explicit textual cues indicate "Intern / Trainee" (mapped to 0 years).
- **Relational Integrity:** Every record in `job_skills` must resolve to an existing `job_id` in the `jobs` table (enforced via foreign-key validation).

---

## 4. Analytical Metrics & Statistical Methods

### 4.1. Univariate Distributions
- Non-parametric summary statistics (Median, Interquartile Range, 10th and 90th percentiles) are prioritized for compensation and experience variables to mitigate the influence of extreme outliers and high skewness.

### 4.2. Skill Penetration & Co-occurrence
- **Skill Penetration Rate:**
  $$\text{Penetration}(S_i, C_j) = \frac{\text{Postings in Category } C_j \text{ requesting Skill } S_i}{\text{Total Postings in Category } C_j} \times 100$$
- **Skill Co-occurrence:** Evaluated using pairwise contingency matrices to detect technical stacks (e.g., React + Node.js + PostgreSQL vs. Spring Boot + Java + AWS).

### 4.3. Labour Market vs. Vacancy Demand Distinction
- Job advertisement volume measures **flow of advertised employer demand**, not the **total stock of employed professionals**.
- Official labour statistics (DCS LFS unemployment, youth unemployment, LFPR) are analyzed alongside vacancy trends to provide macroeconomic context without conflating vacancy numbers with aggregate employment.
