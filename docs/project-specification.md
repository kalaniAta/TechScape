# TechScape: Project Specification

## 1. Executive Summary

**TechScape** is an empirical analytical platform focused on the **Sri Lankan Information Technology (IT) labour market**. The project systematically investigates the historical and contemporary evolution of IT career tracks, technical skill demands, compensation patterns, entry-level accessibility, and employment conditions within Sri Lanka.

The platform is designed to provide undergraduate students, academics, and industry stakeholders with descriptive and exploratory insights grounded in data, bridging the information gap between university education and market reality.

---

## 2. Target Audience & Use Cases

### Primary Audience: IT Undergraduates and Students
- **Educational Alignment:** Identifying which technical skills, toolchains, and paradigms are genuinely sought by industry employers.
- **Entry-Level Awareness:** Understanding realistic experience thresholds, internship-to-associate expectations, and accessible career tracks.
- **Market Landscape Comprehension:** Gaining clarity on the relative distribution of job roles beyond conventional software engineering (e.g., DevOps, QA, Data Science, Cyber Security, Business Analysis).

### Secondary Audience: Academic Educators & Labour Analysts
- Evaluating curriculum relevance against empirical market demands.
- Analyzing macro employment trends and industry evolution in the Sri Lankan knowledge-services sector.

---

## 3. In-Scope vs. Out-of-Scope (Boundaries)

To ensure methodological rigour and credibility, the boundaries of Version 1 are defined as follows:

| In Scope | Out of Scope |
|---|---|
| Historical and current descriptive analysis of advertised IT jobs | Machine learning predictive forecasting of future job counts |
| Empirical analysis of required and preferred technical skills | Automated recommendation systems suggesting specific careers to individuals |
| Experience requirement distributions across career paths | Employability scoring or algorithmic screening of student profiles |
| Advertised salary distribution and disclosure rate analysis | Large-scale automated web scraping engine in Version 1 |
| Macroeconomic employment/unemployment indicators (DCS/CBSL) | Asserting that job posting volume directly equals total employment |
| Interactive analytical exploration dashboard (R Shiny) | Causal economic assertions unsupported by econometric design |
| Curated real-world sample dataset with traceable provenance | Presenting synthetic development datasets as real market findings |
| Structurally realistic synthetic dataset for pipeline testing | Fabrication, extrapolation, or reconstruction of unsourced real records |

---

## 4. Architectural Principles

1. **Analytical-First Architecture:** The pipeline is constructed around the core analytical questions rather than being driven by ingestion tools or UI frameworks.
2. **Separation of Layers:**
   ```text
   DATA ACQUISITION (Python / Curated Sources)
          ↓
   RAW DATA (Traceable Provenance & Original Unedited Strings)
          ↓
   VALIDATION ENGINE (Schema, Missingness, Integrity)
          ↓
   CLEANING & TRANSFORMATION (Normalization Rules & Dictionaries)
          ↓
   STATISTICAL ANALYSIS & MODELING (R Analytical Scripts)
          ↓
   PRESENTATION LAYER (Static ggplot2 & Interactive Shiny Dashboard)
   ```
3. **Traceability & Provenance:** Every real record must maintain full auditability from the original advertisement down to the normalized analytical metric.
4. **Reproducibility:** All data ingestions, transformations, metrics, tables, and figures must be 100% reproducible through deterministic Python pre-flight validation and R analytical scripts.
