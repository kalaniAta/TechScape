# TechScape Phase 3: Relational Persistence Layer & ORM Architecture

## 1. Architectural Overview
Phase 3 converts the TechScape data platform from flat, static CSVs into an ACID-compliant, index-optimized relational database powered by **SQLite** and **SQLAlchemy 2.0**. This persistence layer ensures that:

1. Academic empirical data ($n=80$ jobs, 290 skill associations) is stored with relational referential integrity.
2. Foreign key constraints are actively enforced at the SQLite engine level.
3. Complex relational queries (e.g., skill demand by career category, salary distributions across work modes) execute with sub-millisecond B-Tree indexed lookups.
4. Downstream FastAPI endpoints (Phase 4) interact with typed SQLAlchemy 2.0 domain models.

---

## 2. Relational Schema & B-Tree Indexes

### Entity-Relationship Architecture
- **`jobs` table**:
  - Primary Key: `job_id` (VARCHAR(64))
  - Attributes: `date_posted`, `job_title`, `career_category`, `company`, `location`, `work_mode`, `employment_type`, `experience_min`, `experience_max`, `salary_min`, `salary_max`, `currency`, `source`, `source_url`, `collection_date`, `is_synthetic`, `created_at`
  - Indexes: `ix_jobs_career_category`, `ix_jobs_work_mode`, `ix_jobs_category_mode` (compound)
- **`skills` table**:
  - Primary Key: `skill_id` (Integer Autoincrement)
  - Attributes: `skill_name` (Unique, Indexed), `skill_category` (Indexed)
- **`job_skills` table**:
  - Primary Key: `id` (Integer Autoincrement)
  - Foreign Keys:
    - `job_id` $\to$ `jobs.job_id` (`ON DELETE CASCADE`)
    - `skill_id` $\to$ `skills.skill_id` (`ON DELETE CASCADE`)
  - Unique Constraint: `(job_id, skill_id)`
  - Indexes: `ix_job_skills_job_id`, `ix_job_skills_skill_id`
- **`macro_indicators` table**:
  - Primary Key: `id` (Integer Autoincrement)
  - Attributes: `year` (Indexed), `indicator_name` (Indexed), `indicator_value`, `unit`, `source`
- **`pipeline_runs` table**:
  - Primary Key: `run_id` (VARCHAR(64))
  - Attributes: `source_name`, `status`, `records_read`, `records_accepted`, `records_quarantined`, `records_deduplicated`, `quarantine_file`, `manifest_file`, `duration_seconds`, `timestamp`

---

## 3. SQLite Foreign Key Enforcement

In SQLite, foreign key enforcement is disabled by default for backwards compatibility. To guarantee absolute referential integrity, the SQLAlchemy engine explicitly registers a connection listener:

```python
from sqlalchemy import event
from sqlalchemy.engine import Engine

@event.listens_for(Engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()
```

---

## 4. Idempotent Data Seeding

The database seeder (`python/db/seed.py`) is designed for deterministic, repeatable initialization:
- When executed, it checks existing primary and unique keys.
- It atomically populates the baseline frozen dataset ($n=80$).
- Consecutive runs perform an idempotent synchronization without creating duplicates or raising unique constraint errors.
