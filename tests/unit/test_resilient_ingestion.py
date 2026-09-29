"""
TechScape: Unit Tests for Resilient Ingestion, DLQ & Manifests
==============================================================
Validates strict Pydantic v2 schemas, zero-placeholder enforcement,
Dead-Letter Queue quarantine serialization, and cryptographic manifest metrics.
"""

import json
import os

import pytest
from pydantic import ValidationError

from python.ingestion.deduplication import DeduplicationEngine, compute_stable_job_fingerprint
from python.ingestion.quarantine import QuarantineEngine, StructuredValidationError
from python.ingestion.schemas import RawJobIngestionSchema, RawSkillIngestionSchema
from python.ingestion.source_adapters import ResilientIngestionPipeline


class TestStrictIngestionSchemas:
    """Tests strict validation constraints and anti-placeholder policies."""

    def test_valid_job_passes_validation(self):
        payload = {
            "job_id": "J_TEST_99",
            "job_title": "Senior Cloud Platform Engineer",
            "company": "Virtusa Sri Lanka",
            "date_posted": "2026-08-15",
            "career_category": "Cloud & DevOps",
            "source": "topjobs",
            "source_url": "https://topjobs.lk/vacancy/12345",
            "work_mode": "Hybrid",
            "salary_min": 350000,
            "salary_max": 500000,
            "currency": "LKR",
            "experience_min": 3.0,
            "experience_max": 6.0
        }
        schema = RawJobIngestionSchema.model_validate(payload)
        self_dict = schema.to_canonical_dict()
        assert self_dict["job_id"] == "J_TEST_99"
        assert self_dict["job_title"] == "Senior Cloud Platform Engineer"
        assert self_dict["currency"] == "LKR"

    def test_rejects_placeholder_job_titles(self):
        for bad_title in ["Unknown Role", "unknown", "N/A", "none", "   "]:
            payload = {
                "job_id": "J_TEST_FAIL",
                "job_title": bad_title,
                "company": "TechCorp",
                "date_posted": "2026-08-15",
                "source": "topjobs",
                "source_url": "https://topjobs.lk/vacancy/123"
            }
            with pytest.raises(ValidationError) as exc:
                RawJobIngestionSchema.model_validate(payload)
            assert "job_title" in str(exc.value)

    def test_rejects_placeholder_company(self):
        for bad_company in ["Confidential", "undisclosed company", ""]:
            payload = {
                "job_id": "J_TEST_FAIL",
                "job_title": "Software Engineer",
                "company": bad_company,
                "date_posted": "2026-08-15",
                "source": "topjobs",
                "source_url": "https://topjobs.lk/vacancy/123"
            }
            with pytest.raises(ValidationError) as exc:
                RawJobIngestionSchema.model_validate(payload)
            assert "company" in str(exc.value)

    def test_rejects_invalid_date_formats(self):
        for bad_date in ["2026/08/01", "yesterday", "01-08-2026", "2026-13-45"]:
            payload = {
                "job_id": "J_TEST_FAIL",
                "job_title": "QA Lead",
                "company": "QualityWorks",
                "date_posted": bad_date,
                "source": "itpro",
                "source_url": "https://itpro.lk/jobs/456"
            }
            with pytest.raises(ValidationError) as exc:
                RawJobIngestionSchema.model_validate(payload)
            assert "date_posted" in str(exc.value)

    def test_rejects_placeholder_and_invalid_urls(self):
        for bad_url in ["https://example.com/json-source", "not-a-url", "ftp://internal/job"]:
            payload = {
                "job_id": "J_TEST_FAIL",
                "job_title": "Data Scientist",
                "company": "DataCorp",
                "date_posted": "2026-08-15",
                "source": "manual",
                "source_url": bad_url
            }
            with pytest.raises(ValidationError) as exc:
                RawJobIngestionSchema.model_validate(payload)
            assert "source_url" in str(exc.value)

    def test_rejects_reversed_salary_bounds(self):
        payload = {
            "job_id": "J_TEST_FAIL",
            "job_title": "DevOps Engineer",
            "company": "Sysco LABS",
            "date_posted": "2026-08-15",
            "source": "topjobs",
            "source_url": "https://topjobs.lk/jobs/789",
            "salary_min": 600000,
            "salary_max": 400000,
            "currency": "LKR"
        }
        with pytest.raises(ValidationError) as exc:
            RawJobIngestionSchema.model_validate(payload)
        assert "salary_max" in str(exc.value)

    def test_rejects_reversed_experience_bounds(self):
        payload = {
            "job_id": "J_TEST_FAIL",
            "job_title": "Senior Frontend Developer",
            "company": "IFS Sri Lanka",
            "date_posted": "2026-08-15",
            "source": "topjobs",
            "source_url": "https://topjobs.lk/jobs/789",
            "experience_min": 5.0,
            "experience_max": 2.0
        }
        with pytest.raises(ValidationError) as exc:
            RawJobIngestionSchema.model_validate(payload)
        assert "experience_max" in str(exc.value)

    def test_valid_skill_schema(self):
        skill = RawSkillIngestionSchema.model_validate({
            "job_id": "J_TEST_01",
            "skill_name": "Kubernetes",
            "skill_category": "Cloud & DevOps"
        })
        assert skill.skill_name == "Kubernetes"
        assert skill.raw_skill_string == "Kubernetes"


class TestDeadLetterQueueQuarantine:
    """Tests the DLQ accumulation, error logging, and JSON serialization."""

    def test_quarantine_accumulator_and_flush(self, tmp_path):
        q_engine = QuarantineEngine(run_id="RUN_TEST_01", source_name="test_feed", quarantine_dir=str(tmp_path))

        errors = [
            StructuredValidationError(field="job_title", error_type="placeholder", message="Title missing"),
            StructuredValidationError(field="date_posted", error_type="format", message="Bad date")
        ]
        q_rec = q_engine.record_failure(raw_payload={"title": "Unknown Role"}, record_index=1, errors=errors)

        assert q_engine.count == 1
        assert q_rec.quarantine_id == "QL-RUN_TEST_01-0001"
        assert len(q_rec.errors) == 2

        filepath = q_engine.flush_to_disk()
        assert filepath is not None
        assert os.path.exists(filepath)

        with open(filepath, "r", encoding="utf-8") as f:
            data = json.load(f)
            assert data["run_id"] == "RUN_TEST_01"
            assert data["quarantine_count"] == 1
            assert len(data["records"]) == 1


class TestDeduplicationEngine:
    """Tests collision-resistant stable key generation and batch deduplication."""

    def test_stable_fingerprint_generation(self):
        rec1 = {
            "job_title": "Senior Java Developer",
            "company": "Virtusa",
            "date_posted": "2026-08-10",
            "location": "Colombo"
        }
        rec2 = {
            "job_title": " senior java developer ",
            "company": "virtusa!",
            "date_posted": "2026-08-10",
            "location": "COLOMBO"
        }
        fp1 = compute_stable_job_fingerprint(rec1)
        fp2 = compute_stable_job_fingerprint(rec2)
        assert fp1 == fp2

    def test_deduplicate_batch(self):
        engine = DeduplicationEngine()
        batch = [
            {"job_id": "J1", "job_title": "DevOps Engineer", "company": "WSO2", "date_posted": "2026-08-10"},
            {"job_id": "J2", "job_title": "QA Lead", "company": "Sysco", "date_posted": "2026-08-10"},
            {"job_id": "J1", "job_title": "DevOps Engineer", "company": "WSO2", "date_posted": "2026-08-10"},  # Dup by ID
            {"job_id": "J3", "job_title": "DevOps Engineer", "company": "WSO2", "date_posted": "2026-08-10"}   # Dup by fingerprint
        ]
        unique, dups = engine.deduplicate_batch(batch)
        assert len(unique) == 2
        assert dups == 2
        assert unique[0]["job_id"] == "J1"
        assert unique[1]["job_id"] == "J2"


class TestResilientPipelineEndToEnd:
    """Tests the full end-to-end resilient ingestion pipeline on mixed data."""

    def test_pipeline_on_dirty_json_feed(self, tmp_path):
        dirty_json = [
            # Valid Record 1
            {
                "job_id": "JSON_VAL_01",
                "job_title": "Lead Software Engineer",
                "company": "IFS Sri Lanka",
                "date_posted": "2026-08-12",
                "career_category": "Software Engineering",
                "source": "topjobs",
                "source_url": "https://topjobs.lk/vacancy/1111",
                "skills": ["Java", "Spring Boot"]
            },
            # Invalid Record (missing required title)
            {
                "job_id": "JSON_MAL_02",
                "job_title": "Unknown Role",
                "company": "SomeCorp",
                "date_posted": "2026-08-12",
                "source": "topjobs",
                "source_url": "https://topjobs.lk/vacancy/2222"
            },
            # Invalid Record (reversed salary)
            {
                "job_id": "JSON_MAL_03",
                "job_title": "Cloud Architect",
                "company": "Virtusa",
                "date_posted": "2026-08-12",
                "source": "topjobs",
                "source_url": "https://topjobs.lk/vacancy/3333",
                "salary_min": 800000,
                "salary_max": 400000,
                "currency": "LKR"
            },
            # Duplicate of Valid Record 1
            {
                "job_id": "JSON_VAL_01",
                "job_title": "Lead Software Engineer",
                "company": "IFS Sri Lanka",
                "date_posted": "2026-08-12",
                "career_category": "Software Engineering",
                "source": "topjobs",
                "source_url": "https://topjobs.lk/vacancy/1111"
            }
        ]

        json_file = tmp_path / "incoming_jobs.json"
        with open(json_file, "w", encoding="utf-8") as f:
            json.dump(dirty_json, f)

        res = ResilientIngestionPipeline.ingest_file(
            filepath=str(json_file),
            source_name="topjobs_feed",
            file_type="json",
            run_id="RUN_DIRTY_TEST",
            quarantine_dir=str(tmp_path / "quarantine"),
            manifest_dir=str(tmp_path / "manifests")
        )

        assert len(res.accepted_jobs) == 1
        assert res.quarantined_count == 2
        assert res.deduplicated_count == 1
        assert res.manifest is not None
        assert res.manifest.records_read == 4
        assert res.manifest.records_accepted == 1
        assert res.manifest.records_quarantined == 2
        assert res.manifest.records_deduplicated == 1
        assert res.manifest.status == "COMPLETED_WITH_QUARANTINE"

        # Check quarantine file exists and has 2 records
        assert res.quarantine_file is not None
        assert os.path.exists(res.quarantine_file)
        with open(res.quarantine_file, "r", encoding="utf-8") as f:
            q_data = json.load(f)
            assert len(q_data["records"]) == 2
