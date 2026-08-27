# IT Labour Market Analytics & Industry Evolution Analysis
## Implementation Plan

**Purpose:** Implementation specification for the Antigravity development agent.

---

## 1. Purpose of This Document

This document is the implementation blueprint for developing the **IT Labour Market Analytics and Industry Evolution Analysis** project from the beginning.

It is intended to be given to an AI/software development agent (Antigravity) as the working specification. The agent should follow the phases in order, maintain the stated scope, and avoid implementing future-scope features prematurely.

---

## 2. Project Objective

Build a data-analysis system that studies the evolution of the **Sri Lankan IT labour market** using historical and current job-market, industry, and labour statistics.

The system should help IT students understand how the following have changed:

- Job opportunities
- Career categories
- Skills
- Salaries
- Experience requirements
- Employment conditions
- Broader labour-market conditions

The system is an **analytical and visualization platform, not a prediction engine**.

### Primary objective

Provide descriptive and exploratory analysis of the IT labour market.

### Primary audience

IT students and undergraduates.

### Initial data strategy

Use a **real-data-informed synthetic development dataset** rather than purely imagined synthetic data.

The recommended sequence is:

1. Define the initial data schema.
2. Collect a small real sample to understand actual job-advertisement structure.
3. Use the observed structure to design the synthetic development dataset.
4. Build and test the R pipeline primarily against the synthetic dataset.
5. Run the same pipeline against the real sample.
6. Refine the schema, cleaning rules, and analysis based on real-data behavior.
7. Use real data and official statistics for final real-world findings.

Synthetic data is therefore a **development/testing asset**, not evidence of actual labour-market trends.

### Data acquisition

A large automated scraping engine is **not required for Version 1**.

Manual collection of a small real sample is preferred initially because the project's primary objective is labour-market analysis rather than scraping-engine development.

Automated source-specific scraping can be added later as an independent data-ingestion layer if time permits.

### Future machine learning/prediction

Explicitly out of scope for the current implementation.

The system should not make future predictions or automatically recommend careers to students. Any future prediction module must be developed as a separate scope extension after the descriptive-analysis phase.

---

# 3. Scope and Non-Goals

| In Scope | Out of Scope |
|---|---|
| Historical job-market analysis | Future job-demand prediction |
| Current job-market analysis | Individual career recommendation |
| Skill-demand analysis | Individual employability prediction |
| Career/category evolution | Universal automated scraping engine |
| Salary analysis | Large-scale production data acquisition in Version 1 |
| Experience requirements | AI/ML forecasting in the current version |
| Employment/unemployment indicators from appropriate sources | Unsupported labour-market claims |
| Interactive visualization/dashboard | Treating synthetic data as real-world evidence |
| Small real-data validation sample | Presenting a small sample as a complete labour-market census |

---

# 4. Core Research Questions

1. How has the volume and distribution of IT job opportunities changed over time?
2. Which IT career categories have increased or decreased in observed demand?
3. How have employer skill requirements changed over time?
4. How accessible are current advertised jobs to entry-level candidates?
5. How have experience requirements changed across time and career categories?
6. How have advertised salaries changed across time, careers, and experience levels?
7. What do official employment and unemployment indicators show about the broader labour context?
8. What evidence of industry evolution and adaptability can be observed from changes in employer requirements?

---

# 5. High-Level Architecture

Implement the system around the following conceptual pipeline:

```text
DATA REQUIREMENTS
     ↓
SMALL REAL SAMPLE
     ↓
DATA MODEL / SCHEMA
     ↓
REAL-DATA-INFORMED SYNTHETIC DATA
     ↓
R DATA PIPELINE
     ↓
REAL SAMPLE VALIDATION
     ↓
REFINED ANALYSIS
     ↓
VISUALIZATIONS
     ↓
DASHBOARD
     ↓
STUDENT INSIGHTS

Official labour/industry statistics ─────→ Labour-market context

Optional future scraping ────────────────→ Data ingestion layer
```

Keep data acquisition, preparation, analysis, and presentation as separate layers.

The analysis layer must work from standardized datasets and should **not depend directly on a scraper**.

---

# 6. Recommended Technology Stack

| Technology | Purpose |
|---|---|
| R | Primary language for data cleaning, transformation, exploratory analysis, statistics, and visualization |
| RStudio | Primary development environment |
| tidyverse | Core data manipulation and transformation |
| ggplot2 | Static analytical visualizations |
| stringr | Text normalization, especially job titles and skills |
| lubridate | Date parsing and time-based analysis |
| tidyr | Reshaping and structured data handling |
| Shiny | Interactive dashboard in a later phase |
| CSV/Parquet | Initial portable datasets |
| Git/GitHub | Version control and reproducibility |

---

# 7. Project Repository Structure

```text
IT-Labour-Market-Analytics/
├── README.md
├── docs/
│   ├── project-specification.md
│   ├── research-questions.md
│   ├── data-source-register.md
│   ├── data-dictionary.md
│   ├── methodology.md
│   └── implementation-plan.md
├── data/
│   ├── raw/
│   ├── synthetic/
│   ├── real_sample/
│   └── processed/
├── R/
│   ├── 01_import.R
│   ├── 02_validate.R
│   ├── 03_clean.R
│   ├── 04_transform.R
│   ├── 05_job_market_analysis.R
│   ├── 06_skill_analysis.R
│   ├── 07_salary_analysis.R
│   ├── 08_experience_analysis.R
│   ├── 09_employment_analysis.R
│   └── 10_visualizations.R
├── dashboard/
│   ├── app.R
│   └── modules/
├── outputs/
│   ├── figures/
│   ├── tables/
│   └── findings/
└── tests/
    └── data_quality/
```

---

# 8. Implementation Phases

## Phase 0 — Project Initialization

### Tasks

- Create the repository and directory structure.
- Create `README.md` with project purpose, scope, current status, and setup instructions.
- Create the project specification and research-question documents.
- Initialize Git and make the first baseline commit.
- Do **not** implement scraping, prediction, or dashboard functionality yet.

### Exit Criterion

Project scope and repository structure are fixed.

---

## Phase 1 — Data Source and Data Requirements

### Tasks

- Create a data-source register documenting intended sources, available periods, fields, reliability, and analytical use.
- Identify realistic sources for job advertisements, industry information, and official labour statistics.
- Collect a **small real sample** of job advertisements manually before finalizing the synthetic data generator.
- Use the real sample to identify actual field formats, job-title variants, skill terminology, salary representations, experience descriptions, locations, and missing fields.
- Create the data dictionary based on both project requirements and observations from the real sample.
- Separate job-advertisement data from official employment/unemployment data.
- Record provenance and collection dates for every real dataset.
- Document clearly that synthetic data is for development/testing and must not be used as evidence of real market trends.

### Exit Criterion

Required fields and source strategy are documented, and a small real sample has been inspected sufficiently to inform the data model.

---

## Phase 2 — Data Model and Analytical Design

### Tasks

- Implement the `jobs` table and `job_skills` table.
- Define standardized career categories and skill categories using both project requirements and the observed real sample.
- Define allowed values for work mode, employment type, and experience level.
- Define missing-value conventions.
- Define normalization rules for job titles, skills, salary, dates, and locations.
- Design the synthetic data generator around the finalized schema.
- Create:
  - System Context Diagram
  - Data Flow Diagram
  - Data Pipeline Diagram
  - ER Diagram
  - Analytical Architecture Diagram

### Exit Criterion

Both real and synthetic job records can be represented by the same standardized schema.

---

## Phase 3 — Real-Data-Informed Synthetic Dataset

### Purpose

Create a large development dataset that is structurally realistic enough to exercise the analytical pipeline, while making no claim that it represents the actual Sri Lankan IT labour market.

### Tasks

- Use the previously collected real sample to inform the structure and terminology of the synthetic dataset.
- Generate an initial synthetic dataset covering approximately 2016–2026.
- Generate plausible relationships between career, skills, experience, salary, and time.
- Do **not** intentionally encode the project's expected conclusions into the synthetic data.
- Intentionally include controlled data-quality issues:
  - Missing values
  - Duplicate records
  - Inconsistent capitalization
  - Alternate skill names
  - Alternate job-title names
  - Different salary representations
- Use deterministic random seeds where possible.
- Keep the synthetic-data generator separate from the analysis scripts.
- Clearly label all synthetic data as synthetic.
- Never use synthetic observations as evidence for real-world findings.

### Exit Criterion

A sufficiently large, documented synthetic development dataset exists and can be regenerated and loaded into R.

---

## Phase 4 — R Data Pipeline

### Tasks

- Build import and validation scripts.
- Profile the synthetic development dataset.
- Implement cleaning and normalization rules.
- Create processed analysis-ready datasets.
- Make the pipeline reproducible from raw input to processed output.
- Add basic data-quality checks.
- Keep the pipeline independent of any particular scraping implementation.
- Ensure the same processing pipeline can later accept real job data following the standardized schema.

### Exit Criterion

The synthetic dataset can be processed from raw to analysis-ready with a repeatable command sequence, and the pipeline is not coupled to a scraper.

---

## Phase 5 — Core Analysis

### Tasks

Develop and test the analytical methods using the synthetic development dataset:

- Job volume over time
- Career-category distribution and change
- Entry-level opportunities
- Experience requirements
- Skill frequencies
- Skill evolution
- Salary distributions
- Salary by career
- Salary by experience
- Relationships between skills and career categories

Then run the same analytical methods against the real sample.

Compare the synthetic and real results to identify:

- Unrealistic synthetic assumptions
- Missing categories
- Unexpected terminology
- Missing fields
- Cleaning problems
- Analysis measures that do not transfer well to real data

Document findings without making unsupported causal claims.

### Important rule

Synthetic-data results are **development/test results**, not final claims about the Sri Lankan IT labour market.

### Exit Criterion

The core analysis works on both synthetic and real sample data, and differences between the two are documented.

---

## Phase 6 — Visualization

### Tasks

Create clear, presentation-quality charts with consistent labels and units.

Develop visualizations first using the synthetic development dataset to verify that the visual pipeline works, then refine them using real data.

Potential visualization types:

- Time-series charts
- Bar charts
- Distributions
- Heatmaps
- Career-skill comparisons
- Skill evolution charts
- Salary comparisons
- Experience comparisons

Store reusable plotting functions where useful.

Separate exploratory plots from final presentation plots.

Every final visualization must clearly indicate its data source where necessary.

Do not use a synthetic-data chart as evidence of a real-world trend.

### Exit Criterion

A coherent visual story can be produced from the validated analysis dataset.

---

## Phase 7 — Real Sample Data Validation

### Purpose

Validate and refine the analytical system using a small amount of actual data without requiring a large scraping engine.

### Tasks

- Maintain a manually curated real sample of approximately 100–300 job advertisements initially, if practical.
- Store raw real data separately from synthetic data.
- Record source, collection date, and relevant provenance for every record.
- Run the same processing pipeline against the real sample.
- Compare real-data structure with synthetic assumptions.
- Identify:
  - Missing fields
  - Salary disclosure problems
  - Duplicate/reposted jobs
  - Unexpected job titles
  - Skill terminology
  - Experience formats
  - Location variations
  - Selection bias
- Update normalization rules, categories, and the data dictionary as required.
- Re-run the analysis after refinement.
- Treat the sample as a sample, not as a census of the Sri Lankan IT labour market.

### Exit Criterion

The analytical pipeline works on real sample data and its limitations are explicitly documented.

---

## Phase 8 — Official Labour/Industry Data Integration

### Tasks

- Add appropriate official employment/unemployment and industry datasets.
- Use official or authoritative statistics for unemployment and employment rather than attempting to infer unemployment directly from job advertisements.
- Keep job-advertisement demand measures conceptually separate from labour-force measures.
- Document differences in definitions, periods, populations, sampling, and methodologies between sources.
- Identify whether each metric represents:
  - Employer demand
  - Advertised vacancies
  - Employment
  - Unemployment
  - Labour-force participation
  - Industry size/workforce
- Create only comparisons that are statistically and conceptually defensible.
- Do not imply that job-advertisement volume directly equals employment or unemployment.

### Exit Criterion

Broader labour-market context can be shown without conflating incompatible measures.

---

## Phase 9 — Dashboard

Only begin this phase after the analytical dataset, real-data validation, and final metrics stabilize.

The dashboard should prioritize validated real-data findings and clearly distinguish any development/demo data.

### Tasks

Implement an R Shiny dashboard with sections such as:

- Industry Evolution
- Job Market
- Career Paths
- Skills
- Salary
- Experience
- Employment

Provide filters such as:

- Year
- Career
- Skill
- Experience level
- Location

where supported by the data.

Include methodology/source notes in the interface.

Avoid presenting recommendations as system-generated decisions.

### Exit Criterion

A user can interactively explore the major findings.

---

## Phase 10 — Documentation and Final Evaluation

### Tasks

- Finalize the methodology and analysis report.
- Document:
  - Data limitations
  - Synthetic-data limitations
  - Sampling limitations
  - Missing data
  - Source coverage
- Verify that every final chart can be traced to a documented dataset and analysis script.
- Re-run the full pipeline from a clean environment.
- Finalize README and project setup instructions.
- Prepare final conclusions and future-work sections.

### Exit Criterion

The project is reproducible, documented, and ready for academic evaluation.

---

# 9. Initial Data Model

## Jobs Dataset

Minimum fields:

```text
job_id
date_posted
job_title
career_category
company
location
work_mode
employment_type
experience_min
experience_max
salary_min
salary_max
currency
source
```

## Job Skills Dataset

```text
job_id
skill_id
skill_name
```

## Employment/Labour Dataset

Keep employment and unemployment indicators in a separate dataset.

Suggested fields:

```text
indicator
year / period
population_definition
value
unit
source
```

---

# 10. Synthetic Data Rules

Synthetic data is a **development and testing mechanism**, not final evidence.

The following rules must be followed:

1. Synthetic data must imitate the structure of real data.
2. Synthetic data must never be presented as real observations.
3. Use deterministic seeds where possible so the dataset can be regenerated.
4. Model plausible relationships between:
   - Year
   - Career
   - Skill
   - Experience
   - Salary
5. Do not encode the desired conclusion into the data.
6. Add controlled missingness and inconsistent representations to test cleaning.
7. Keep the generator separate from the analysis scripts.
8. Record all assumptions used to generate the dataset.

---

# 11. Data Cleaning and Normalization Requirements

The pipeline should:

- Normalize whitespace and capitalization.
- Normalize equivalent skill names.
- Normalize job-title variants into documented career categories.
- Parse and standardize dates.
- Convert salary strings into numeric values only when defensible.
- Preserve missing/unknown values instead of silently replacing them with zero.
- Detect and document duplicate records.
- Keep original raw values when a standardized value is created.
- Never overwrite raw data.

Example:

```text
Python
python
Python 3
Python3
     ↓
Python
```

Example:

```text
Software Engineer
Software Developer
SE
Application Developer
     ↓
Software Engineering
```

---

# 12. Analysis Output Requirements

| Area | Required Outputs |
|---|---|
| Job Market | Job advertisements by year, career, location, and work mode where available |
| Career Evolution | Changes in career-category distribution over time |
| Skills | Top skills, skill trends, career-skill relationships, and skill combinations |
| Entry-Level | Entry-level share and characteristics of advertised entry-level opportunities |
| Experience | Experience distributions and changes by career |
| Salary | Salary distributions and comparisons by career and experience where reliable |
| Employment Context | Official employment/unemployment indicators with source definitions |
| Industry Evolution | Historical-to-current comparison synthesizing the preceding analyses |

---

# 13. Quality and Reproducibility Rules for Antigravity

The development agent must follow these rules:

1. **Do not fabricate real-world findings, source statistics, or historical job counts.**
2. Do not silently invent missing data.
3. Keep raw, processed, and synthetic datasets separate.
4. Every derived metric must be traceable to a script and input dataset.
5. Prefer small, testable R scripts over one large script.
6. Use meaningful file names.
7. Comment non-obvious transformations.
8. When changing the schema, update the data dictionary and affected scripts.
9. When changing a cleaning rule, document the reason and possible effect on findings.
10. Do not build prediction functionality unless explicitly requested as a future phase.
11. Do not build a large scraping system unless explicitly requested after the analytical pipeline is complete.
12. Do not make causal claims from descriptive data unless a suitable methodology supports them.

---

# 14. Definition of Done for Version 1

Version 1 is complete when:

- [ ] Project repository and documentation structure exist.
- [ ] Research questions and scope are finalized.
- [ ] Data dictionary and schemas are finalized.
- [ ] Synthetic dataset is generated and documented.
- [ ] R can import and validate the dataset.
- [ ] R can clean and transform the dataset reproducibly.
- [ ] Core job analysis is implemented.
- [ ] Career analysis is implemented.
- [ ] Skill analysis is implemented.
- [ ] Salary analysis is implemented where appropriate.
- [ ] Experience analysis is implemented.
- [ ] Core visualizations are implemented.
- [ ] Findings are documented.
- [ ] Synthetic assumptions are distinguished from observations.
- [ ] A small real sample has been processed to validate the pipeline.
- [ ] Limitations are documented.
- [ ] No prediction functionality is included in Version 1.

---

# 15. Recommended First Tasks for Antigravity

When this document is provided to Antigravity, the agent should execute **only the following initial sequence**:

### Step 1 — Create the repository

Create the repository structure defined in Section 7.

### Step 2 — Create README

Create `README.md` containing:

- Project name
- Project purpose
- Problem statement
- Scope
- Current development phase
- Basic setup instructions

### Step 3 — Create project documentation

Create:

```text
docs/
├── project-specification.md
├── research-questions.md
├── data-source-register.md
├── data-dictionary.md
└── implementation-plan.md
```

Populate the first four documents using this implementation plan.

### Step 4 — Initialize R

Create the R project/environment and verify that R can execute a basic script.

### Step 5 — Collect a small real sample

Before generating the large synthetic development dataset, collect a small manually curated real sample.

Initially aim for approximately 50–100 records for schema discovery. Expand later if practical.

Record source and collection date.

### Step 6 — Create the synthetic-data generator

Use observations from the real sample to inform the generator.

Keep the generator separate from the analysis scripts.

### Step 7 — Generate a small development dataset

Initially generate only a few hundred records.

Do not immediately generate thousands of records.

### Step 8 — Create the first validation scripts

Create:

```text
R/
├── 01_import.R
└── 02_validate.R
```

Demonstrate that:

- The dataset loads.
- Required columns exist.
- Data types are reasonable.
- Basic quality checks run successfully.

### Step 9 — Stop at this milestone

At this point, Antigravity should report:

- Files created
- Current repository structure
- Assumptions made
- Real-sample observations
- Synthetic-data design and assumptions
- Validation results
- Problems/blockers

**Do not proceed to large-scale scraping, prediction, or dashboard implementation at this point.**

---

# 16. Important Implementation Principle

> **The project should be developed from the analytical questions outward, not from the technology inward.**

The agent should not begin by building a scraper, database, API, or dashboard simply because those components are technically interesting.

First establish:

1. What questions must be answered?
2. What data is required?
3. How should the data be represented?
4. How should the data be cleaned?
5. What analysis is required?
6. What visualizations communicate the results?

Technology should support those requirements.

---

# 17. Future Extensions

Potential future work includes:

- Automated collection from selected public job sources, subject to terms of service and ethical/legal constraints.
- Natural-language processing for job-title and skill extraction.
- Larger historical datasets.
- More advanced statistical analysis.
- Forecasting and predictive modelling.
- Personalized student career exploration.
- Additional industry and education datasets.

These are **future extensions** and must not be implemented as part of the first analytical version unless the project scope is formally changed.

---

# 18. Final Concept

The project should ultimately function as:

```text
Historical + Current Data
          ↓
     Data Preparation
          ↓
        R Analysis
          ↓
     Visual Evidence
          ↓
  Industry Understanding
          ↓
    Student Awareness
```

The system does **not** tell students what career to choose or predict their future.

Its purpose is to give students a clearer understanding of:

- Where the IT industry has been
- Where it currently stands
- How employer requirements have changed
- What skills are currently visible in the market
- How job opportunities and salaries have changed
- How experience requirements have evolved

The student's future decision remains the student's own decision.
