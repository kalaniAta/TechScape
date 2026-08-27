# TechScape: Data Dictionary & Schema Specification

## 1. Overview

This document specifies the data model, field definitions, data types, normalization mappings, and validation constraints for the TechScape platform.

The data model comprises three core datasets:
1. **`jobs`**: Job advertisement records with raw provenance and normalized analytical attributes.
2. **`job_skills`**: Relational entity table mapping individual technical skills to job postings.
3. **`employment_indicators`**: Macroeconomic labour force indicators from official statistical authorities.

---

## 2. Dataset Schemas

### 2.1. `jobs` Schema

| Column Name | Data Type | Nullable | Description & Allowed Values | Provenance / Example |
|---|---|---|---|---|
| `job_id` | Character / String | No | Unique identifier for the job record within TechScape (`JOB_00001`, `SYN_00001`). | System Generated |
| `source` | Character / String | No | Source platform identifier (`TopJobs_LK`, `LinkedIn_LK`, `Synthetic_Generator`). | Raw Source |
| `source_url` | Character / String | Yes | Direct URL or traceable link to original posting (`NA` for synthetic). | Raw Provenance |
| `source_job_id` | Character / String | Yes | Original identifier assigned by source platform (`TJ-98432`, `LI-3849201`). | Raw Provenance |
| `collection_date` | Date (`YYYY-MM-DD`) | No | Date when the record was collected or generated. | Provenance |
| `date_posted` | Date (`YYYY-MM-DD`) | Yes | Advertised posting date. | Raw/Standardized |
| `original_title` | Character / String | No | Unmodified raw job title string as written in the advertisement. | e.g., `"Senior Full-Stack Software Eng (React/Node)"` |
| `job_title` | Character / String | No | Cleaned title string (trimmed whitespace, standardized casing). | e.g., `"Senior Full-Stack Software Engineer"` |
| `career_category` | Character / String | No | Standardized career classification (see Section 3.1). | e.g., `"Software Engineering"` |
| `seniority_level` | Character / String | Yes | Standardized seniority tier (`Intern`, `Junior`, `Mid`, `Senior`, `Lead`, `Management`, `Unspecified`). | Derived / Standardized |
| `company` | Character / String | Yes | Name of hiring employer (`Unspecified` if confidential/agency). | e.g., `"Sysco LABS Sri Lanka"` |
| `location` | Character / String | Yes | Geographic location or city (`Colombo`, `Kandy`, `Galle`, `Jaffna`, `Islandwide`, `Unspecified`). | e.g., `"Colombo, Sri Lanka"` |
| `work_mode` | Character / String | No | Standardized working model (`On-site`, `Hybrid`, `Remote`, `Unspecified`). | Standardized |
| `employment_type` | Character / String | No | Standardized contract type (`Full-time`, `Part-time`, `Contract`, `Internship`, `Unspecified`). | Standardized |
| `original_experience` | Character / String | Yes | Unmodified raw experience string from advertisement. | e.g., `"3-5 years in React"`, `"Minimum 2 yrs"` |
| `experience_min` | Numeric (Years) | Yes | Parsed minimum required experience in years (e.g. `0`, `1`, `3.5`). | Standardized |
| `experience_max` | Numeric (Years) | Yes | Parsed maximum experience threshold if specified (e.g., `5`). | Standardized |
| `original_salary` | Character / String | Yes | Unmodified raw compensation string. | e.g., `"LKR 250,000 - 350,000"`, `"Competitive"` |
| `salary_min` | Numeric | Yes | Parsed minimum monthly salary amount. `NA` if undisclosed. | Standardized |
| `salary_max` | Numeric | Yes | Parsed maximum monthly salary amount. `NA` if undisclosed. | Standardized |
| `currency` | Character / String | Yes | Currency code (`LKR`, `USD`, `NA`). | Standardized |
| `is_synthetic` | Logical (`TRUE`/`FALSE`) | No | Explicit flag distinguishing development test data from real observations. | Audit Flag |

---

### 2.2. `job_skills` Schema

| Column Name | Data Type | Nullable | Description & Allowed Values | Example |
|---|---|---|---|---|
| `job_id` | Character / String | No | Foreign key referencing `jobs.job_id`. | `"JOB_00001"` |
| `skill_raw` | Character / String | No | Unmodified skill string extracted from advertisement text. | `"react.js"`, `"ReactJS"`, `"AWS Cloud"` |
| `skill_name` | Character / String | No | Normalized canonical skill name (see Section 3.2). | `"React"`, `"AWS"`, `"Python"` |
| `skill_category` | Character / String | No | Classification tier: `Programming Language`, `Framework/Library`, `Database`, `Cloud/DevOps`, `Tool/Methodology`, `Domain/Other`. | `"Framework/Library"` |
| `is_required` | Logical | Yes | `TRUE` if mandatory requirement; `FALSE` if preferred/bonus; `NA` if unspecified. | `TRUE` |

---

### 2.3. `employment_indicators` Schema (Macro Context)

| Column Name | Data Type | Nullable | Description & Allowed Values | Example |
|---|---|---|---|---|
| `indicator_id` | Character / String | No | Unique indicator code (`IND_UNEMP_TOT`, `IND_UNEMP_YOUTH_20_29`). | `"IND_UNEMP_YOUTH_20_29"` |
| `indicator_name` | Character / String | No | Human-readable name of indicator. | `"Youth Unemployment Rate (Ages 20-29)"` |
| `year` | Integer | No | Reporting calendar year (`2016`–`2026`). | `2024` |
| `quarter` | Character / String | Yes | Reporting quarter (`Q1`, `Q2`, `Q3`, `Q4`, `Annual`). | `"Annual"` |
| `population_group` | Character / String | No | Target demographic (`National Total`, `Youth (15-24)`, `Youth (20-29)`, `Female`, `Male`, `ICT Sector`). | `"Youth (20-29)"` |
| `value` | Numeric | No | Indicator numerical value. | `14.8` |
| `unit` | Character / String | No | Unit of measurement (`Percentage (%)`, `LKR Millions`, `Headcount`). | `"Percentage (%)"` |
| `source` | Character / String | No | Official source publication identifier (`DCS_LFS_Annual_2024`, `CBSL_AR_2024`). | `"DCS_LFS_Annual_2024"` |

---

## 3. Standardization & Normalization Taxonomies

### 3.1. Career Categories Lookup

| Standardized Category | Included Roles & Job Title Variants |
|---|---|
| **Software Engineering** | Software Engineer, Full Stack Developer, Frontend Developer, Backend Developer, Mobile App Developer (iOS/Android/Flutter), SE, SSE, Associate SE, Tech Lead |
| **QA & Test Automation** | QA Engineer, Quality Assurance Analyst, Automation Test Engineer, Software Tester, SDET, QA Lead |
| **Cloud & DevOps** | DevOps Engineer, Cloud Engineer, Site Reliability Engineer (SRE), Platform Engineer, SysOps Engineer, Cloud Architect |
| **Data & AI / ML** | Data Analyst, Data Scientist, Data Engineer, Machine Learning Engineer, Business Intelligence (BI) Developer, AI Engineer |
| **Cyber Security** | Security Analyst, SOC Analyst, Cyber Security Engineer, Information Security Specialist, Penetration Tester |
| **UI/UX & Product Design** | UI/UX Designer, Product Designer, Interaction Designer, Visual Designer, UX Researcher |
| **IT Systems & Infrastructure** | System Administrator, Network Engineer, IT Support Specialist, Helpdesk Engineer, Infrastructure Specialist |
| **Management & Business Analysis** | Business Analyst (BA), Technical Project Manager, Scrum Master, Product Owner, Engineering Manager |

---

### 3.2. Canonical Skill Mapping Examples

| Raw Variant (`skill_raw`) | Normalized Canonical Name (`skill_name`) | Skill Category |
|---|---|---|
| `react.js`, `ReactJS`, `React JS`, `react` | `React` | `Framework/Library` |
| `node.js`, `NodeJS`, `node`, `Node js` | `Node.js` | `Framework/Library` |
| `python3`, `Python 3`, `python` | `Python` | `Programming Language` |
| `golang`, `Go Lang`, `go` | `Go` | `Programming Language` |
| `amazon web services`, `aws cloud`, `AWS` | `AWS` | `Cloud/DevOps` |
| `k8s`, `Kubernetes` | `Kubernetes` | `Cloud/DevOps` |
| `postgres`, `PostgreSQL`, `Postgresql` | `PostgreSQL` | `Database` |
| `ms sql`, `SQL Server`, `MSSQL` | `Microsoft SQL Server` | `Database` |
| `ci/cd`, `CI-CD`, `Continuous Integration` | `CI/CD` | `Tool/Methodology` |
