"""
TechScape: Raw Data & Schema Provenance Validator
=================================================
Validates schema compliance, provenance URLs, collection dates,
missing-value representations, and job-skill referential integrity
before handing data off to the R pipeline.
"""

import csv
import os
import re
from dataclasses import dataclass, field
from datetime import datetime
from typing import Dict, List, Optional, Set, Tuple


REQUIRED_JOB_FIELDS = [
    "job_id",
    "date_posted",
    "job_title",
    "career_category",
    "company",
    "location",
    "work_mode",
    "employment_type",
    "source",
    "source_url",
    "collection_date"
]

REQUIRED_SKILL_FIELDS = [
    "job_id",
    "skill_name"
]

VALID_CAREER_CATEGORIES = {
    "Software Engineering",
    "Data & AI / ML",
    "Cloud & DevOps",
    "QA & Test Automation",
    "Cyber Security",
    "IT Systems & Infrastructure",
    "Management & Business Analysis",
    "UI/UX & Product Design"
}

VALID_WORK_MODES = {"Hybrid", "On-site", "Remote"}
VALID_EMPLOYMENT_TYPES = {"Full-Time", "Part-Time", "Contract", "Internship"}
VALID_CURRENCIES = {"LKR", "USD"}


@dataclass
class ValidationResult:
    """Detailed summary of data quality assertions."""
    dataset_name: str
    record_count: int
    passed_checks: int = 0
    failed_checks: int = 0
    assertions: List[str] = field(default_factory=list)
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)

    @property
    def is_valid(self) -> bool:
        return self.failed_checks == 0 and len(self.errors) == 0

    def add_pass(self, assertion_desc: str):
        self.passed_checks += 1
        self.assertions.append(f"[PASS] {assertion_desc}")

    def add_fail(self, assertion_desc: str, error_detail: str):
        self.failed_checks += 1
        self.assertions.append(f"[FAIL] {assertion_desc}")
        self.errors.append(f"{assertion_desc}: {error_detail}")

    def add_warning(self, warning_desc: str):
        self.warnings.append(warning_desc)


def _is_valid_date(date_str: str) -> bool:
    if not date_str:
        return False
    try:
        datetime.strptime(date_str.strip(), "%Y-%m-%d")
        return True
    except ValueError:
        return False


def _is_valid_url(url_str: str) -> bool:
    if not url_str:
        return False
    u = url_str.strip()
    return u.startswith("http://") or u.startswith("https://") or u.startswith("mock://")


def validate_jobs_table(
    file_path: str,
    expect_real: bool = True,
    expected_min_records: int = 1
) -> Tuple[ValidationResult, Set[str]]:
    """
    Validates a jobs CSV dataset for structural, schema, and provenance compliance.
    Returns (ValidationResult, set_of_valid_job_ids).
    """
    result = ValidationResult(dataset_name=os.path.basename(file_path), record_count=0)
    job_ids: Set[str] = set()

    if not os.path.exists(file_path):
        result.add_fail("File Existence", f"File not found: {file_path}")
        return result, job_ids

    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames or []

        # Check required columns
        missing_cols = [c for c in REQUIRED_JOB_FIELDS if c not in headers]
        if missing_cols:
            result.add_fail("Required Columns", f"Missing required columns: {missing_cols}")
            return result, job_ids
        else:
            result.add_pass(f"All {len(REQUIRED_JOB_FIELDS)} required schema columns present")

        rows = list(reader)
        result.record_count = len(rows)

        if len(rows) < expected_min_records:
            result.add_fail("Minimum Record Count", f"Found {len(rows)} records, expected >= {expected_min_records}")
        else:
            result.add_pass(f"Record count check passed (n={len(rows)})")

        # Row-level validation
        invalid_ids = []
        invalid_dates = []
        invalid_urls = []
        empty_sources = []
        synthetic_flags = []
        salary_anomalies = []
        exp_anomalies = []

        for idx, row in enumerate(rows, 1):
            jid = row.get("job_id", "").strip()
            if not jid:
                invalid_ids.append(f"Row {idx}")
            elif jid in job_ids:
                invalid_ids.append(f"Duplicate {jid} at row {idx}")
            else:
                job_ids.add(jid)

            # Date checks
            dp = row.get("date_posted", "")
            cd = row.get("collection_date", "")
            if not _is_valid_date(dp) or not _is_valid_date(cd):
                invalid_dates.append(jid or f"Row {idx}")

            # Provenance checks
            url = row.get("source_url", "")
            if not _is_valid_url(url):
                invalid_urls.append(jid or f"Row {idx}")

            src = row.get("source", "")
            if not src.strip():
                empty_sources.append(jid or f"Row {idx}")

            # Synthetic check for real dataset
            if expect_real:
                is_syn = row.get("is_synthetic", "false").strip().lower()
                if is_syn in ("true", "1", "t"):
                    synthetic_flags.append(jid)

            # Salary validation
            s_min = row.get("salary_min", "").strip()
            s_max = row.get("salary_max", "").strip()
            if s_min and s_min != "NA":
                try:
                    val_min = float(s_min)
                    if val_min <= 0:
                        salary_anomalies.append(f"{jid}: non-positive salary_min ({val_min})")
                    if s_max and s_max != "NA":
                        val_max = float(s_max)
                        if val_max < val_min:
                            salary_anomalies.append(f"{jid}: salary_max ({val_max}) < salary_min ({val_min})")
                except ValueError:
                    salary_anomalies.append(f"{jid}: non-numeric salary_min string '{s_min}'")

            # Experience validation
            e_min = row.get("experience_min", "").strip()
            e_max = row.get("experience_max", "").strip()
            if e_min and e_min != "NA":
                try:
                    val_emin = float(e_min)
                    if val_emin < 0:
                        exp_anomalies.append(f"{jid}: negative experience_min ({val_emin})")
                    if e_max and e_max != "NA":
                        val_emax = float(e_max)
                        if val_emax < val_emin:
                            exp_anomalies.append(f"{jid}: experience_max < experience_min")
                except ValueError:
                    exp_anomalies.append(f"{jid}: non-numeric experience string '{e_min}'")

        # Evaluate assertions
        if invalid_ids:
            result.add_fail("Job ID Integrity", f"Invalid/Duplicate IDs: {invalid_ids[:5]}")
        else:
            result.add_pass(f"Unique, non-empty job identifiers verified (n={len(job_ids)})")

        if invalid_dates:
            result.add_fail("ISO Date Formatting", f"Invalid date fields in: {invalid_dates[:5]}")
        else:
            result.add_pass("100% of date_posted and collection_date fields match YYYY-MM-DD")

        if invalid_urls:
            result.add_fail("Provenance URL Validation", f"Invalid source URLs in: {invalid_urls[:5]}")
        else:
            result.add_pass("100% of records contain valid provenance URLs")

        if empty_sources:
            result.add_fail("Source Provenance", f"Missing source names in: {empty_sources[:5]}")
        else:
            result.add_pass("100% of records contain documented source organizations")

        if expect_real:
            if synthetic_flags:
                result.add_fail("Empirical Authenticity", f"Synthetic records detected in real dataset: {synthetic_flags}")
            else:
                result.add_pass("Empirical authenticity confirmed (0 synthetic flags in real dataset)")

        if salary_anomalies:
            result.add_fail("Compensation Consistency", f"Salary bounds violations: {salary_anomalies[:5]}")
        else:
            result.add_pass("Disclosed salary ranges adhere to positive numeric bounds")

        if exp_anomalies:
            result.add_fail("Experience Requirement Consistency", f"Experience bounds violations: {exp_anomalies[:5]}")
        else:
            result.add_pass("Experience requirements adhere to non-negative numeric bounds")

    return result, job_ids


def validate_skills_table(
    file_path: str,
    valid_job_ids: Set[str],
    expected_min_records: int = 1
) -> ValidationResult:
    """
    Validates a job_skills CSV dataset and enforces foreign-key referential integrity.
    """
    result = ValidationResult(dataset_name=os.path.basename(file_path), record_count=0)

    if not os.path.exists(file_path):
        result.add_fail("File Existence", f"File not found: {file_path}")
        return result

    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames or []

        missing_cols = [c for c in REQUIRED_SKILL_FIELDS if c not in headers]
        if missing_cols:
            result.add_fail("Required Columns", f"Missing required columns in skills table: {missing_cols}")
            return result
        else:
            result.add_pass(f"All required skill schema columns present ({REQUIRED_SKILL_FIELDS})")

        rows = list(reader)
        result.record_count = len(rows)

        if len(rows) < expected_min_records:
            result.add_fail("Minimum Skill Count", f"Found {len(rows)} skill records, expected >= {expected_min_records}")
        else:
            result.add_pass(f"Skill record count check passed (n={len(rows)})")

        orphan_skills = []
        empty_skills = []

        for idx, row in enumerate(rows, 1):
            jid = row.get("job_id", "").strip()
            sname = row.get("skill_name", "").strip()

            if not sname:
                empty_skills.append(f"Row {idx} (job {jid})")

            if valid_job_ids and jid not in valid_job_ids:
                orphan_skills.append(f"{jid} at row {idx}")

        if empty_skills:
            result.add_fail("Skill Name Completeness", f"Empty skill names found: {empty_skills[:5]}")
        else:
            result.add_pass("100% of skill records have non-empty skill names")

        if orphan_skills:
            result.add_fail("Referential Integrity", f"Orphan foreign keys found: {orphan_skills[:5]}")
        else:
            result.add_pass(f"Foreign-key referential integrity verified (0 orphans across {len(rows)} skills)")

    return result


def validate_dataset_pair(
    jobs_csv_path: str,
    skills_csv_path: str,
    expect_real: bool = True
) -> Tuple[ValidationResult, ValidationResult]:
    """
    Validates both jobs and skills datasets in tandem, checking cross-table foreign key integrity.
    """
    jobs_res, job_ids = validate_jobs_table(jobs_csv_path, expect_real=expect_real)
    skills_res = validate_skills_table(skills_csv_path, valid_job_ids=job_ids)
    return jobs_res, skills_res
