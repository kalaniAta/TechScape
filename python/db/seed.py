"""
TechScape Relational Database Seeder.
Idempotently loads baseline empirical data (n=80 jobs, 290 skill associations,
macroeconomic indicators) into SQLite via SQLAlchemy 2.0.
"""

import csv
import os
from typing import Any, Dict, Optional

from sqlalchemy import select
from sqlalchemy.engine import Engine

from python.db.models import Job, JobSkill, MacroIndicator, Skill
from python.db.session import get_engine, get_session, init_db

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DEFAULT_JOBS_CSV = os.path.join(PROJECT_ROOT, "data", "real_sample", "jobs_real_sample.csv")
DEFAULT_SKILLS_CSV = os.path.join(PROJECT_ROOT, "data", "real_sample", "job_skills_real_sample.csv")
DEFAULT_MACRO_CSV = os.path.join(PROJECT_ROOT, "data", "processed", "macro_labour_indicators.csv")


def _clean_float(val: Any) -> Optional[float]:
    """Parses numeric string to float, treating NA/null/empty as None."""
    if val is None:
        return None
    val_str = str(val).strip()
    if not val_str or val_str.upper() in ("NA", "NULL", "NONE"):
        return None
    try:
        return float(val_str)
    except ValueError:
        return None


def _clean_str(val: Any) -> Optional[str]:
    """Parses optional string, treating NA/null/empty as None."""
    if val is None:
        return None
    val_str = str(val).strip()
    if not val_str or val_str.upper() in ("NA", "NULL", "NONE"):
        return None
    return val_str


def _clean_bool(val: Any) -> bool:
    """Parses string/bool to boolean."""
    if isinstance(val, bool):
        return val
    return str(val).strip().lower() in ("true", "1", "yes")


def seed_database(
    engine: Optional[Engine] = None,
    jobs_csv: Optional[str] = None,
    skills_csv: Optional[str] = None,
    macro_csv: Optional[str] = None
) -> Dict[str, int]:
    """
    Idempotently populates the database with baseline empirical records.
    Returns counts of inserted records.
    """
    eng = engine or get_engine()
    init_db(eng)

    jobs_path = jobs_csv or DEFAULT_JOBS_CSV
    skills_path = skills_csv or DEFAULT_SKILLS_CSV
    macro_path = macro_csv or DEFAULT_MACRO_CSV

    counts = {
        "jobs_inserted": 0,
        "skills_inserted": 0,
        "job_skills_inserted": 0,
        "macro_inserted": 0,
        "jobs_total": 0,
        "skills_total": 0,
        "job_skills_total": 0,
        "macro_total": 0
    }

    with get_session(eng) as session:
        # 1. Seed Skills Taxonomy
        if os.path.exists(skills_path):
            existing_skills = {
                s.skill_name: s.skill_id
                for s in session.scalars(select(Skill)).all()
            }

            with open(skills_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    s_name = row["skill_name"].strip()
                    s_cat = row.get("skill_category", "General").strip()

                    if s_name not in existing_skills:
                        new_skill = Skill(skill_name=s_name, skill_category=s_cat)
                        session.add(new_skill)
                        session.flush()
                        existing_skills[s_name] = new_skill.skill_id
                        counts["skills_inserted"] += 1

            counts["skills_total"] = len(existing_skills)

        # 2. Seed Jobs Dataset
        if os.path.exists(jobs_path):
            existing_job_ids = set(session.scalars(select(Job.job_id)).all())

            with open(jobs_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    jid = row["job_id"].strip()
                    if jid not in existing_job_ids:
                        job = Job(
                            job_id=jid,
                            source=row.get("source", "Empirical Baseline").strip(),
                            source_url=row.get("source_url", "").strip(),
                            collection_date=row.get("collection_date", "").strip(),
                            source_job_id=_clean_str(row.get("source_job_id")),
                            date_posted=row.get("date_posted", "").strip(),
                            original_title=row.get("original_title", row.get("job_title", "")).strip(),
                            job_title=row.get("job_title", "").strip(),
                            career_category=row.get("career_category", "Other IT").strip(),
                            seniority_level=row.get("seniority_level", "Mid").strip(),
                            company=row.get("company", "Confidential").strip(),
                            location=row.get("location", "Sri Lanka").strip(),
                            work_mode=row.get("work_mode", "On-site").strip(),
                            employment_type=row.get("employment_type", "Full-time").strip(),
                            original_experience=_clean_str(row.get("original_experience")),
                            experience_min=_clean_float(row.get("experience_min")),
                            experience_max=_clean_float(row.get("experience_max")),
                            original_salary=_clean_str(row.get("original_salary")),
                            salary_min=_clean_float(row.get("salary_min")),
                            salary_max=_clean_float(row.get("salary_max")),
                            currency=_clean_str(row.get("currency")),
                            is_synthetic=_clean_bool(row.get("is_synthetic", False))
                        )
                        session.add(job)
                        existing_job_ids.add(jid)
                        counts["jobs_inserted"] += 1

            counts["jobs_total"] = len(existing_job_ids)

        # 3. Seed Job-Skill Associations
        if os.path.exists(skills_path):
            existing_pairs = set(
                session.execute(select(JobSkill.job_id, JobSkill.skill_id)).all()
            )
            # Reload skills mapping in case new ones were flushed
            skill_map = {
                s.skill_name: s.skill_id
                for s in session.scalars(select(Skill)).all()
            }

            with open(skills_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    jid = row["job_id"].strip()
                    s_name = row["skill_name"].strip()
                    s_id = skill_map.get(s_name)

                    if s_id and (jid, s_id) not in existing_pairs:
                        js = JobSkill(
                            job_id=jid,
                            skill_id=s_id,
                            skill_raw=_clean_str(row.get("skill_raw")),
                            is_required=_clean_bool(row.get("is_required", True))
                        )
                        session.add(js)
                        existing_pairs.add((jid, s_id))
                        counts["job_skills_inserted"] += 1

            counts["job_skills_total"] = len(existing_pairs)

        # 4. Seed Macroeconomic Indicators
        if os.path.exists(macro_path):
            existing_macro_ids = set(session.scalars(select(MacroIndicator.indicator_id)).all())

            with open(macro_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    mid = row["indicator_id"].strip()
                    if mid not in existing_macro_ids:
                        macro = MacroIndicator(
                            indicator_id=mid,
                            indicator_name=row.get("indicator_name", "").strip(),
                            year=int(row.get("year", 2026)),
                            quarter=_clean_str(row.get("quarter")),
                            population_group=_clean_str(row.get("population_group")),
                            value=float(row.get("value", 0.0)),
                            unit=_clean_str(row.get("unit")),
                            source=_clean_str(row.get("source"))
                        )
                        session.add(macro)
                        existing_macro_ids.add(mid)
                        counts["macro_inserted"] += 1

            counts["macro_total"] = len(existing_macro_ids)

    return counts


if __name__ == "__main__":
    print("=" * 64)
    print("  TECHSCAPE RELATIONAL DATABASE SEEDER (SQLITE / SQLALCHEMY 2.0) ")
    print("=" * 64)
    res = seed_database()
    print(f"[SEEDED] Jobs:             {res['jobs_inserted']} inserted (Total in DB: {res['jobs_total']})")
    print(f"[SEEDED] Skills Taxonomy:  {res['skills_inserted']} inserted (Total in DB: {res['skills_total']})")
    print(f"[SEEDED] Job-Skill Pairs:  {res['job_skills_inserted']} inserted (Total in DB: {res['job_skills_total']})")
    print(f"[SEEDED] Macro Indicators: {res['macro_inserted']} inserted (Total in DB: {res['macro_total']})")
    print("=" * 64)
    print(">>> Database seeding completed successfully. <<<")
