"""
Integration Tests for TechScape Relational Persistence Layer (SQLAlchemy 2.0 / SQLite).
Tests schema integrity, SQLite foreign key enforcement, cascading deletes,
idempotent seeding, and indexed relational query patterns.
"""

import pytest
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError

from python.db.models import Job, JobSkill, MacroIndicator, PipelineRun, Skill
from python.db.seed import seed_database
from python.db.session import get_engine, get_session, init_db


@pytest.fixture
def test_db_engine(tmp_path):
    """Provides a fresh isolated SQLite database engine for each test."""
    db_file = tmp_path / "test_techscape.db"
    engine = get_engine(db_path=str(db_file))
    init_db(engine)
    return engine


class TestDatabaseSchemaAndPragmas:
    """Verifies that SQLite enforces foreign key constraints and schema rules."""

    def test_sqlite_foreign_key_pragma_active(self, test_db_engine):
        with get_session(test_db_engine) as session:
            session.execute(select(func.sqlite_compileoption_used("ENABLE_COLUMN_METADATA"))).scalar()
            # Just verify query execution works and PRAGMA foreign_keys is 1
            cursor = session.connection().connection.cursor()
            cursor.execute("PRAGMA foreign_keys;")
            fk_setting = cursor.fetchone()[0]
            cursor.close()
            assert fk_setting == 1

    def test_rejects_orphan_job_skill_invalid_job_id(self, test_db_engine):
        with get_session(test_db_engine) as session:
            skill = Skill(skill_name="Docker", skill_category="DevOps")
            session.add(skill)
            session.flush()

            # Attempt to associate with a non-existent job_id
            orphan_js = JobSkill(job_id="NON_EXISTENT_JOB_999", skill_id=skill.skill_id)
            session.add(orphan_js)

            with pytest.raises(IntegrityError):
                session.flush()
            session.rollback()

    def test_rejects_orphan_job_skill_invalid_skill_id(self, test_db_engine):
        with get_session(test_db_engine) as session:
            job = Job(
                job_id="JOB_TEST_FK",
                source="Test",
                source_url="https://example.com/test",
                collection_date="2026-08-20",
                date_posted="2026-08-15",
                original_title="QA Engineer",
                job_title="QA Engineer",
                career_category="QA & Test Automation",
                seniority_level="Mid",
                company="Test Corp",
                location="Colombo",
                work_mode="Hybrid",
                employment_type="Full-time"
            )
            session.add(job)
            session.flush()

            # Attempt to associate with a non-existent skill_id
            orphan_js = JobSkill(job_id=job.job_id, skill_id=99999)
            session.add(orphan_js)

            with pytest.raises(IntegrityError):
                session.flush()
            session.rollback()

    def test_enforces_unique_job_skill_constraint(self, test_db_engine):
        with get_session(test_db_engine) as session:
            job = Job(
                job_id="JOB_TEST_UQ",
                source="Test",
                source_url="https://example.com/test",
                collection_date="2026-08-20",
                date_posted="2026-08-15",
                original_title="Software Engineer",
                job_title="Software Engineer",
                career_category="Software Engineering",
                seniority_level="Junior",
                company="Test Corp",
                location="Colombo",
                work_mode="Remote",
                employment_type="Full-time"
            )
            skill = Skill(skill_name="Python", skill_category="Programming Language")
            session.add_all([job, skill])
            session.flush()

            js1 = JobSkill(job_id=job.job_id, skill_id=skill.skill_id)
            session.add(js1)
            session.flush()

            # Attempt duplicate pair
            js2 = JobSkill(job_id=job.job_id, skill_id=skill.skill_id)
            session.add(js2)

            with pytest.raises(IntegrityError):
                session.flush()
            session.rollback()


class TestCascadingDeletes:
    """Verifies that deletions cascade across foreign keys."""

    def test_job_delete_cascades_to_job_skills(self, test_db_engine):
        with get_session(test_db_engine) as session:
            job = Job(
                job_id="JOB_CASCADE_01",
                source="Test",
                source_url="https://example.com/test",
                collection_date="2026-08-20",
                date_posted="2026-08-15",
                original_title="DevOps Engineer",
                job_title="DevOps Engineer",
                career_category="Cloud & DevOps",
                seniority_level="Senior",
                company="Test Corp",
                location="Colombo",
                work_mode="Hybrid",
                employment_type="Full-time"
            )
            s1 = Skill(skill_name="AWS", skill_category="Cloud")
            s2 = Skill(skill_name="Terraform", skill_category="DevOps")
            session.add_all([job, s1, s2])
            session.flush()

            js1 = JobSkill(job_id=job.job_id, skill_id=s1.skill_id)
            js2 = JobSkill(job_id=job.job_id, skill_id=s2.skill_id)
            session.add_all([js1, js2])
            session.flush()

            # Verify associations exist
            assert session.scalar(select(func.count(JobSkill.id))) == 2

            # Delete Job
            session.delete(job)
            session.flush()

            # Assert Job is deleted and linked JobSkills are cascaded
            assert session.scalar(select(func.count(Job.job_id))) == 0
            assert session.scalar(select(func.count(JobSkill.id))) == 0

            # But skills themselves remain in taxonomy
            assert session.scalar(select(func.count(Skill.skill_id))) == 2


class TestIdempotentSeeding:
    """Verifies that seeding behaves identically across consecutive invocations."""

    def test_seeding_produces_exact_baseline_counts(self, test_db_engine):
        counts = seed_database(engine=test_db_engine)

        assert counts["jobs_inserted"] == 80
        assert counts["skills_inserted"] == 103
        assert counts["job_skills_inserted"] == 267
        assert counts["macro_inserted"] == 31

        with get_session(test_db_engine) as session:
            job_count = session.scalar(select(func.count(Job.job_id)))
            skill_count = session.scalar(select(func.count(Skill.skill_id)))
            js_count = session.scalar(select(func.count(JobSkill.id)))
            macro_count = session.scalar(select(func.count(MacroIndicator.indicator_id)))

            assert job_count == 80
            assert skill_count == 103
            assert js_count == 267
            assert macro_count == 31

    def test_re_seeding_is_idempotent(self, test_db_engine):
        # First seeding run
        seed_database(engine=test_db_engine)

        # Second seeding run
        second_counts = seed_database(engine=test_db_engine)

        assert second_counts["jobs_inserted"] == 0
        assert second_counts["skills_inserted"] == 0
        assert second_counts["job_skills_inserted"] == 0
        assert second_counts["macro_inserted"] == 0

        # Totals remain strictly constant
        assert second_counts["jobs_total"] == 80
        assert second_counts["skills_total"] == 103
        assert second_counts["job_skills_total"] == 267
        assert second_counts["macro_total"] == 31


class TestRelationalQueriesAndAggregation:
    """Verifies relational queries and joins across entities."""

    def test_relational_joins_skills_by_category(self, test_db_engine):
        seed_database(engine=test_db_engine)

        with get_session(test_db_engine) as session:
            # Query top skills for Software Engineering jobs
            stmt = (
                select(Skill.skill_name, func.count(JobSkill.id).label("demand_count"))
                .join(JobSkill, Skill.skill_id == JobSkill.skill_id)
                .join(Job, Job.job_id == JobSkill.job_id)
                .where(Job.career_category == "Software Engineering")
                .group_by(Skill.skill_name)
                .order_by(func.count(JobSkill.id).desc())
            )
            results = session.execute(stmt).all()
            assert len(results) > 0
            skill_names = [r[0] for r in results]
            # Key skills in empirical Software Engineering roles
            assert any(s in skill_names for s in ["Java", "React", "Python", "SQL"])

    def test_pipeline_run_audit_logging(self, test_db_engine):
        with get_session(test_db_engine) as session:
            run = PipelineRun(
                run_id="RUN_AUDIT_2026",
                source_name="topjobs_feed",
                status="COMPLETED_WITH_QUARANTINE",
                records_read=50,
                records_accepted=48,
                records_quarantined=2,
                records_deduplicated=0,
                duration_seconds=1.45
            )
            session.add(run)
            session.flush()

            saved = session.get(PipelineRun, "RUN_AUDIT_2026")
            assert saved is not None
            assert saved.records_accepted == 48
            assert saved.records_quarantined == 2
