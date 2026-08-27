# TechScape: Core Research Questions

This document articulates the eight core research questions guiding the analytical design of TechScape, detailing the analytical objective, required metrics, and relevant dimensions for each question.

---

## Research Question 1 (RQ1): Volume & Temporal Trends
> **How has the volume and distribution of IT job opportunities changed over time?**

- **Objective:** Quantify temporal variations in advertised job opportunities across quarters and years.
- **Key Metrics:** Total job postings per period, year-over-year (YoY) growth rates, monthly posting intensity.
- **Dimensions:** Posting year, posting quarter, source domain, work mode (On-site, Hybrid, Remote).
- **Caveat:** Advertised vacancy volume reflects *employer hiring activity*, not total employment stock.

---

## Research Question 2 (RQ2): Career Category Dynamics
> **Which IT career categories have increased or decreased in observed demand?**

- **Objective:** Track the structural composition of the Sri Lankan IT workforce demand.
- **Key Metrics:** Percentage share of postings by standardized career category (e.g., Software Engineering, QA & Test Automation, Cloud & DevOps, Data & AI, Cyber Security, Business Analysis / PM, IT Support & Infrastructure).
- **Dimensions:** Career category, seniority level, posting period.

---

## Research Question 3 (RQ3): Skill Demand Evolution
> **How have employer skill requirements changed over time across technologies and categories?**

- **Objective:** Identify dominant programming languages, frameworks, databases, cloud platforms, and engineering methodologies.
- **Key Metrics:** Skill occurrence frequency, relative skill penetration (% of jobs in category demanding skill), co-occurrence networks of complementary skills.
- **Dimensions:** Skill category (Language, Framework, Database, Cloud/DevOps, Tool/Methodology), career category, time period.

---

## Research Question 4 (RQ4): Entry-Level Accessibility
> **How accessible are advertised IT jobs to entry-level candidates and fresh graduates?**

- **Objective:** Measure the proportion and characteristics of opportunities open to candidates with 0–1 years of experience.
- **Key Metrics:** Entry-level share (% of total postings with min experience <= 1 year), internship/trainee proportion, top skills demanded specifically in entry-level openings.
- **Dimensions:** Career category, work mode, educational prerequisites.

---

## Research Question 5 (RQ5): Experience Requirements
> **How have experience requirements shifted across different career tracks?**

- **Objective:** Profile the distribution of required years of experience across career categories and seniority levels.
- **Key Metrics:** Mean, median, interquartile range (IQR) of `experience_min` and `experience_max`; proportion of junior (0–2 yrs), mid-level (3–5 yrs), senior (5–8 yrs), and lead/principal (8+ yrs) roles.
- **Dimensions:** Career category, seniority tier, posting period.

---

## Research Question 6 (RQ6): Compensation Dynamics & Transparency
> **How have advertised salaries changed across time, career categories, and experience levels?**

- **Objective:** Examine disclosed compensation ranges, currency conventions, and disclosure transparency.
- **Key Metrics:** Salary disclosure rate (% of postings providing numeric salary), median `salary_min` and `salary_max`, interquartile spread by category and experience, currency breakdown (LKR vs. USD-pegged).
- **Dimensions:** Career category, experience band, currency, posting year.

---

## Research Question 7 (RQ7): Macroeconomic Labour Market Context
> **What do official employment and unemployment indicators reveal about the broader labour context?**

- **Objective:** Contextualize IT vacancy trends within official Sri Lankan labour statistics.
- **Key Metrics:** Overall national unemployment rate, youth unemployment rate (ages 15–24 / 20–29), female labour force participation rate, ICT industry workforce size estimates from official reports.
- **Dimensions:** Year, demographic group, economic sector.
- **Principle:** Sourced strictly from official Department of Census & Statistics (DCS) and Central Bank of Sri Lanka (CBSL) statistical bulletins.

---

## Research Question 8 (RQ8): Industry Evolution & Technological Adaptability
> **What evidence of industry evolution and technological transitions can be observed from employer requirements?**

- **Objective:** Synthesize findings across skills, categories, work modes, and compensation to evaluate how the Sri Lankan IT ecosystem has adapted to global technological paradigms (e.g., cloud migration, remote work adoption, AI/data integration).
- **Key Metrics:** Shift in work-mode distribution (On-site vs. Hybrid vs. Remote), emergence of specialized cloud/AI roles vs. generalist roles, multi-skill breadth per posting.
