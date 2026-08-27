"""
TechScape: Heterogeneous Source Adapters
========================================
Converts diverse input formats (JSON feeds, TSV dumps, heterogeneous CSV exports)
into TechScape's standardized schema without altering frozen empirical datasets.
"""

import csv
import json
import os
from dataclasses import asdict, dataclass
from typing import Any, Dict, List, Optional, Tuple


@dataclass
class StandardJobRecord:
    """Canonical schema representing a raw job record prior to R normalization."""
    job_id: str
    date_posted: str
    job_title: str
    career_category: str
    company: str
    location: str
    work_mode: str
    employment_type: str
    experience_min: Optional[float]
    experience_max: Optional[float]
    salary_min: Optional[float]
    salary_max: Optional[float]
    currency: Optional[str]
    source: str
    source_url: str
    collection_date: str
    is_synthetic: bool = False
    original_title: Optional[str] = None
    original_salary: Optional[str] = None
    original_experience: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        if d["original_title"] is None:
            d["original_title"] = d["job_title"]
        return d


class JSONSourceAdapter:
    """Adapts arbitrary JSON job vacancy dumps into StandardJobRecord instances."""

    @staticmethod
    def parse_file(json_file_path: str) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        """
        Parses a JSON file containing job listings and associated skills.
        Returns a tuple of (jobs_list, skills_list).
        """
        with open(json_file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        if isinstance(data, dict) and "jobs" in data:
            raw_jobs = data["jobs"]
        elif isinstance(data, list):
            raw_jobs = data
        else:
            raise ValueError(f"Unrecognized JSON structure in {json_file_path}")

        jobs = []
        skills = []

        for idx, item in enumerate(raw_jobs, 1):
            job_id = item.get("job_id") or item.get("id") or f"JSON_IMP_{idx:05d}"
            job_rec = StandardJobRecord(
                job_id=job_id,
                date_posted=item.get("date_posted") or item.get("posted_date") or "2026-08-01",
                job_title=item.get("job_title") or item.get("title") or "Unknown Role",
                career_category=item.get("career_category") or item.get("category") or "Software Engineering",
                company=item.get("company") or item.get("employer") or "Confidential",
                location=item.get("location") or "Colombo, Sri Lanka",
                work_mode=item.get("work_mode") or "Hybrid",
                employment_type=item.get("employment_type") or "Full-Time",
                experience_min=float(item["experience_min"]) if item.get("experience_min") is not None else None,
                experience_max=float(item["experience_max"]) if item.get("experience_max") is not None else None,
                salary_min=float(item["salary_min"]) if item.get("salary_min") is not None else None,
                salary_max=float(item["salary_max"]) if item.get("salary_max") is not None else None,
                currency=item.get("currency"),
                source=item.get("source") or "JSON Ingestion",
                source_url=item.get("source_url") or "https://example.com/json-source",
                collection_date=item.get("collection_date") or "2026-08-01",
                is_synthetic=item.get("is_synthetic", False),
                original_title=item.get("original_title") or item.get("title"),
                original_salary=str(item.get("original_salary")) if item.get("original_salary") is not None else None,
                original_experience=str(item.get("original_experience")) if item.get("original_experience") is not None else None
            )
            jobs.append(job_rec.to_dict())

            # Extract associated skills if present
            raw_skills = item.get("skills") or item.get("skill_list") or []
            for s in raw_skills:
                if isinstance(s, str):
                    skills.append({
                        "job_id": job_id,
                        "raw_skill_string": s,
                        "skill_name": s,
                        "skill_category": "General",
                        "is_mandatory": True
                    })
                elif isinstance(s, dict):
                    skills.append({
                        "job_id": job_id,
                        "raw_skill_string": s.get("raw_skill_string") or s.get("name", ""),
                        "skill_name": s.get("skill_name") or s.get("name", ""),
                        "skill_category": s.get("skill_category") or s.get("category", "General"),
                        "is_mandatory": s.get("is_mandatory", True)
                    })

        return jobs, skills


class TSVSourceAdapter:
    """Adapts Tab-Separated Values (TSV) dumps into StandardJobRecord instances."""

    @staticmethod
    def parse_file(tsv_file_path: str) -> List[Dict[str, Any]]:
        jobs = []
        with open(tsv_file_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for idx, row in enumerate(reader, 1):
                job_id = row.get("job_id") or f"TSV_IMP_{idx:05d}"
                exp_min = float(row["experience_min"]) if row.get("experience_min") and row["experience_min"].strip() else None
                exp_max = float(row["experience_max"]) if row.get("experience_max") and row["experience_max"].strip() else None
                sal_min = float(row["salary_min"]) if row.get("salary_min") and row["salary_min"].strip() else None
                sal_max = float(row["salary_max"]) if row.get("salary_max") and row["salary_max"].strip() else None

                job_rec = StandardJobRecord(
                    job_id=job_id,
                    date_posted=row.get("date_posted", "2026-08-01"),
                    job_title=row.get("job_title", "Unknown Role"),
                    career_category=row.get("career_category", "Software Engineering"),
                    company=row.get("company", "Confidential"),
                    location=row.get("location", "Colombo"),
                    work_mode=row.get("work_mode", "Hybrid"),
                    employment_type=row.get("employment_type", "Full-Time"),
                    experience_min=exp_min,
                    experience_max=exp_max,
                    salary_min=sal_min,
                    salary_max=sal_max,
                    currency=row.get("currency") or None,
                    source=row.get("source", "TSV Ingestion"),
                    source_url=row.get("source_url", "https://example.com/tsv-source"),
                    collection_date=row.get("collection_date", "2026-08-01"),
                    is_synthetic=row.get("is_synthetic", "false").lower() in ("true", "1")
                )
                jobs.append(job_rec.to_dict())
        return jobs


class CSVSourceAdapter:
    """Adapts external CSV files with alternative column naming conventions."""

    DEFAULT_COLUMN_MAPPING = {
        "title": "job_title",
        "position": "job_title",
        "role": "job_title",
        "posted_date": "date_posted",
        "date": "date_posted",
        "category": "career_category",
        "track": "career_category",
        "employer": "company",
        "organization": "company",
        "city": "location",
        "mode": "work_mode",
        "type": "employment_type",
        "min_exp": "experience_min",
        "max_exp": "experience_max",
        "min_salary": "salary_min",
        "max_salary": "salary_max",
        "curr": "currency",
        "url": "source_url",
        "link": "source_url"
    }

    @classmethod
    def parse_file(
        cls,
        csv_file_path: str,
        column_mapping: Optional[Dict[str, str]] = None
    ) -> List[Dict[str, Any]]:
        mapping = dict(cls.DEFAULT_COLUMN_MAPPING)
        if column_mapping:
            mapping.update(column_mapping)

        jobs = []
        with open(csv_file_path, "r", encoding="utf-8", errors="replace") as f:
            reader = csv.DictReader(f)
            for idx, raw_row in enumerate(reader, 1):
                # Remap column names
                row = {}
                for k, v in raw_row.items():
                    if k is not None:
                        clean_k = k.strip().lower()
                        mapped_k = mapping.get(clean_k, clean_k)
                        row[mapped_k] = v.strip() if isinstance(v, str) else v

                job_id = row.get("job_id") or f"CSV_IMP_{idx:05d}"
                exp_min = float(row["experience_min"]) if row.get("experience_min") and row["experience_min"].strip() else None
                exp_max = float(row["experience_max"]) if row.get("experience_max") and row["experience_max"].strip() else None
                sal_min = float(row["salary_min"]) if row.get("salary_min") and row["salary_min"].strip() else None
                sal_max = float(row["salary_max"]) if row.get("salary_max") and row["salary_max"].strip() else None

                job_rec = StandardJobRecord(
                    job_id=job_id,
                    date_posted=row.get("date_posted", "2026-08-01"),
                    job_title=row.get("job_title", "Unknown Role"),
                    career_category=row.get("career_category", "Software Engineering"),
                    company=row.get("company", "Confidential"),
                    location=row.get("location", "Colombo"),
                    work_mode=row.get("work_mode", "Hybrid"),
                    employment_type=row.get("employment_type", "Full-Time"),
                    experience_min=exp_min,
                    experience_max=exp_max,
                    salary_min=sal_min,
                    salary_max=sal_max,
                    currency=row.get("currency") or None,
                    source=row.get("source", "CSV Ingestion"),
                    source_url=row.get("source_url", "https://example.com/csv-source"),
                    collection_date=row.get("collection_date", "2026-08-01"),
                    is_synthetic=str(row.get("is_synthetic", "false")).lower() in ("true", "1")
                )
                jobs.append(job_rec.to_dict())
        return jobs


class MacroSeriesAdapter:
    """Converts wide macroeconomic tables into long-format indicator records."""

    @staticmethod
    def wide_to_long_indicators(
        records: List[Dict[str, Any]],
        year_columns: List[str],
        indicator_name_col: str = "indicator",
        unit_col: str = "unit",
        source_col: str = "source"
    ) -> List[Dict[str, Any]]:
        long_records = []
        for row in records:
            ind_name = row.get(indicator_name_col, "Unknown Indicator")
            unit = row.get(unit_col, "")
            source = row.get(source_col, "Official Bulletin")

            for y in year_columns:
                val = row.get(y)
                if val is not None and str(val).strip() != "":
                    try:
                        numeric_val = float(str(val).replace(",", ""))
                        long_records.append({
                            "indicator": ind_name,
                            "year": int(y),
                            "value": numeric_val,
                            "unit": unit,
                            "source": source
                        })
                    except ValueError:
                        continue
        return long_records
