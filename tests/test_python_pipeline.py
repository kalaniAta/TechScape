"""
TechScape: Python Pipeline & Ingestion Layer Unit Test Suite
============================================================
Comprehensive tests for text hygiene, heterogeneous source adapters,
API fetchers, provenance schema validation, and pipeline orchestration.
"""

import os
import sys
import tempfile
import unittest

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from python.ingestion.api_fetcher import (
    BaseJobAPIFetcher,
    MockJobAPIFetcher,
    PublicMacroAPIFetcher,
    serialize_to_csv
)
from python.ingestion.source_adapters import (
    CSVSourceAdapter,
    JSONSourceAdapter,
    MacroSeriesAdapter,
    StandardJobRecord,
    TSVSourceAdapter
)
from python.preprocessing.raw_validator import (
    validate_dataset_pair,
    validate_jobs_table,
    validate_skills_table
)
from python.preprocessing.text_hygiene import (
    check_file_encoding,
    sanitize_string,
    verify_directory_encodings
)
from python.runner import find_rscript_executable


class TestTextHygiene(unittest.TestCase):
    """Tests for encoding verification and raw text sanitation."""

    def test_sanitize_string_entities(self):
        raw = "Senior Software Engineer &amp; Tech Lead   (Java &lt;17&gt;)"
        cleaned = sanitize_string(raw)
        self.assertEqual(cleaned, "Senior Software Engineer & Tech Lead (Java <17>)")

    def test_sanitize_string_control_chars(self):
        raw = "Data Scientist\x00\x07 with PyTorch\r\nand Python"
        cleaned = sanitize_string(raw)
        self.assertNotIn("\x00", cleaned)
        self.assertNotIn("\x07", cleaned)
        self.assertIn("Data Scientist", cleaned)
        self.assertIn("with PyTorch", cleaned)

    def test_check_file_encoding_valid_utf8(self):
        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as f:
            f.write("job_id,job_title\nJOB_01,Software Engineer\n")
            temp_name = f.name

        try:
            report = check_file_encoding(temp_name)
            self.assertTrue(report.is_valid_utf8)
            self.assertFalse(report.has_bom)
            self.assertFalse(report.has_null_bytes)
            self.assertTrue(report.is_healthy)
        finally:
            os.remove(temp_name)

    def test_check_file_encoding_detects_bom(self):
        with tempfile.NamedTemporaryFile("wb", delete=False) as f:
            f.write(b"\xef\xbb\xbfjob_id,title\n1,Developer\n")
            temp_name = f.name

        try:
            report = check_file_encoding(temp_name)
            self.assertTrue(report.has_bom)
            self.assertIn("Contains UTF-8 Byte Order Mark (BOM)", report.issues_found)
        finally:
            os.remove(temp_name)


class TestSourceAdapters(unittest.TestCase):
    """Tests for multi-format ingestion adapters."""

    def test_json_adapter(self):
        json_content = """[
            {
                "id": "J_TEST_01",
                "title": "Cloud Architect",
                "category": "Cloud & DevOps",
                "employer": "Lanka Cloud Systems",
                "experience_min": 5.0,
                "salary_min": 500000.0,
                "currency": "LKR",
                "skills": ["AWS", "Terraform"]
            }
        ]"""
        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as f:
            f.write(json_content)
            temp_name = f.name

        try:
            jobs, skills = JSONSourceAdapter.parse_file(temp_name)
            self.assertEqual(len(jobs), 1)
            self.assertEqual(jobs[0]["job_id"], "J_TEST_01")
            self.assertEqual(jobs[0]["job_title"], "Cloud Architect")
            self.assertEqual(jobs[0]["career_category"], "Cloud & DevOps")
            self.assertEqual(len(skills), 2)
            self.assertEqual(skills[0]["skill_name"], "AWS")
        finally:
            os.remove(temp_name)

    def test_csv_adapter_remapping(self):
        csv_content = "position,employer,min_exp,curr\nQA Lead,TestCorp,4,LKR\n"
        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as f:
            f.write(csv_content)
            temp_name = f.name

        try:
            jobs = CSVSourceAdapter.parse_file(temp_name)
            self.assertEqual(len(jobs), 1)
            self.assertEqual(jobs[0]["job_title"], "QA Lead")
            self.assertEqual(jobs[0]["company"], "TestCorp")
            self.assertEqual(jobs[0]["experience_min"], 4.0)
            self.assertEqual(jobs[0]["currency"], "LKR")
        finally:
            os.remove(temp_name)

    def test_macro_adapter_wide_to_long(self):
        wide_data = [
            {"indicator": "Overall Unemployment", "unit": "%", "source": "DCS", "2020": "5.2", "2021": "5.4"}
        ]
        long_data = MacroSeriesAdapter.wide_to_long_indicators(wide_data, year_columns=["2020", "2021"])
        self.assertEqual(len(long_data), 2)
        self.assertEqual(long_data[0]["year"], 2020)
        self.assertEqual(long_data[0]["value"], 5.2)
        self.assertEqual(long_data[1]["year"], 2021)
        self.assertEqual(long_data[1]["value"], 5.4)


class TestAPIFetcher(unittest.TestCase):
    """Tests for modular API fetcher and mock ingestion interface."""

    def test_mock_job_api_fetcher(self):
        fetcher = MockJobAPIFetcher()
        self.assertTrue(fetcher.health_check())

        all_vacancies = fetcher.fetch_vacancies(limit=10)
        self.assertGreaterEqual(len(all_vacancies), 2)

        cloud_jobs = fetcher.fetch_vacancies(query="Cloud", limit=10)
        self.assertEqual(len(cloud_jobs), 1)
        self.assertEqual(cloud_jobs[0]["job_id"], "API_MOCK_001")

        single = fetcher.fetch_by_id("API_MOCK_002")
        self.assertIsNotNone(single)
        self.assertEqual(single["job_title"], "Junior Data Analyst")

    def test_public_macro_api_fetcher(self):
        fetcher = PublicMacroAPIFetcher()
        series = fetcher.fetch_macro_series("ICT_EXPORTS_USD_MN")
        self.assertEqual(len(series), 5)
        self.assertEqual(series[0]["year"], 2021)
        self.assertEqual(series[0]["value"], 1150.0)

    def test_serialize_prevent_overwrite(self):
        with tempfile.NamedTemporaryFile("w", delete=False) as f:
            f.write("existing\n")
            temp_name = f.name

        try:
            with self.assertRaises(FileExistsError):
                serialize_to_csv([{"a": 1}], temp_name, prevent_overwrite=True)
        finally:
            os.remove(temp_name)


class TestRawValidator(unittest.TestCase):
    """Tests for provenance, schema, and referential integrity validator."""

    def test_validate_real_dataset_in_repo(self):
        real_jobs = os.path.join(PROJECT_ROOT, "data", "real_sample", "jobs_real_sample.csv")
        real_skills = os.path.join(PROJECT_ROOT, "data", "real_sample", "job_skills_real_sample.csv")

        self.assertTrue(os.path.exists(real_jobs), "Real jobs dataset must exist")
        self.assertTrue(os.path.exists(real_skills), "Real skills dataset must exist")

        jobs_res, skills_res = validate_dataset_pair(real_jobs, real_skills, expect_real=True)

        self.assertTrue(jobs_res.is_valid, f"Jobs validation errors: {jobs_res.errors}")
        self.assertTrue(skills_res.is_valid, f"Skills validation errors: {skills_res.errors}")
        self.assertEqual(jobs_res.record_count, 80, "Real sample must contain exactly 80 jobs")
        self.assertGreaterEqual(skills_res.record_count, 290, "Real sample must contain at least 290 skills")

    def test_validator_catches_orphan_foreign_keys(self):
        jobs_content = "job_id,date_posted,job_title,career_category,company,location,work_mode,employment_type,source,source_url,collection_date\nJOB_1,2026-08-01,Dev,Software Engineering,Comp,Col,Hybrid,Full-Time,Source,http://url,2026-08-01\n"
        skills_content = "job_id,skill_name\nJOB_1,Java\nJOB_MISSING,Python\n"

        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as jf:
            jf.write(jobs_content)
            j_name = jf.name

        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as sf:
            sf.write(skills_content)
            s_name = sf.name

        try:
            jobs_res, skills_res = validate_dataset_pair(j_name, s_name, expect_real=True)
            self.assertTrue(jobs_res.is_valid)
            self.assertFalse(skills_res.is_valid)
            self.assertTrue(any("Orphan foreign keys" in err for err in skills_res.errors))
        finally:
            os.remove(j_name)
            os.remove(s_name)


class TestRscriptDiscovery(unittest.TestCase):
    """Tests that the orchestrator can discover Rscript in the environment."""

    def test_rscript_is_found(self):
        rscript = find_rscript_executable()
        self.assertIsNotNone(rscript, "Rscript executable should be discovered on the system")
        self.assertTrue(os.path.exists(rscript), f"Discovered Rscript path does not exist: {rscript}")


if __name__ == "__main__":
    unittest.main()
