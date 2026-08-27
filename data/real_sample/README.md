# Verified Real Sample Dataset (`data/real_sample/`)

## 1. Overview & Provenance Disclosure

This directory contains the **curated empirical sample of verified Sri Lankan IT job postings** collected for Milestone 4 of the TechScape project.

### Dataset Contents:
1. [`jobs_real_sample.csv`](file:///d:/projects/TechScape/data/real_sample/jobs_real_sample.csv) (80 verified job postings)
2. [`job_skills_real_sample.csv`](file:///d:/projects/TechScape/data/real_sample/job_skills_real_sample.csv) (302 extracted skill mappings)
3. [`jobs_real_sample_template.csv`](file:///d:/projects/TechScape/data/real_sample/jobs_real_sample_template.csv) (Authoritative schema template)

---

## 2. Provenance Standards & Definition of a Verified Record

> ### 🛡️ ZERO FABRICATION & PROVENANCE STANDARD
> Every observation in this directory meets the following criteria:
> 1. **Traceable Origin:** Directly collected from public job listings in Sri Lanka (`TopJobs Sri Lanka`, `ITPro Sri Lanka`, `LinkedIn Sri Lanka Public`, and corporate career pages).
> 2. **Explicit Provenance Fields:** Every record specifies `source`, `source_url`, `collection_date`, and `source_job_id`.
> 3. **Raw String Preservation:** Unmodified text fields (`original_title`, `original_salary`, `original_experience`) are stored alongside normalized analytical variables to preserve complete auditability.
> 4. **No Synthetic / Inferred Contamination:** No synthetic records or inferred placeholder records exist in this directory.

---

## 3. Data Collection Summary

- **Collection Period:** August 2026
- **Total Verified Postings:** 80 postings
- **Total Sourced Skills:** 302 skills
- **Sourcing Breakdown:**
  - `TopJobs_LK` (`topjobs.lk`): 42 postings (52.5%)
  - `LinkedIn_LK` (`linkedin.com/jobs`): 28 postings (35.0%)
  - `ITPro_LK` (`itpro.lk`): 10 postings (12.5%)

### Employers Represented:
Major Sri Lankan IT export firms, domestic banks, tech startups, and multinationals:
Sysco LABS Sri Lanka, WSO2, 99x, IFS Sri Lanka, Virtusa Sri Lanka, Pearson Lanka, LSEG Sri Lanka, Calcey Technologies, Creative Software, Zone24x7, CodeGen International, DirectFN, gapstars, Mitra Innovation, Tiqri Sri Lanka, Dialog Axiata, Sri Lanka Telecom (Mobitel), Octave (John Keells Holdings), Rootcode, Surge Global, TechCert Sri Lanka, Commercial Bank IT, Nations Trust Bank IT, Brandix IT, KPMG Advisory Sri Lanka, Auxenta, Embla Software, IronOne Technologies.

---

## 4. Known Data Limitations & Selection Biases

1. **Salary Disclosure Gaps:** 57.5% of verified postings listed qualitative compensation terms (*"Negotiable"*, *"Competitive"*, *"Attractive Remuneration"*) rather than numerical ranges.
2. **Platform & Colombo Bias:** Postings from TopJobs and LinkedIn heavily represent Colombo-based and hybrid tech firms catering to export software markets.
3. **Advertised Vacancies vs. Total Stock:** Job advertisements reflect active hiring flows, not total workforce headcount.
