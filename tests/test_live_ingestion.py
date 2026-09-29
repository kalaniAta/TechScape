"""
TechScape: Unit Tests for Live Ingestion, Parsers & Dataset Isolation
=====================================================================
Deterministic offline test suite verifying scrapers, feature extractors,
deduplication, provenance retention, and frozen dataset protection.

Runs in < 1 second with zero network dependency.
"""

import os
import sys
import unittest

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from python.live_updater import deduplicate_raw_records, run_live_update
from python.preprocessing.live_parser import (
    classify_career_category,
    classify_seniority,
    extract_experience_bounds,
    extract_salary_bounds,
    extract_skills_from_text,
)
from python.scrapers.itpro_scraper import ITProScraper
from python.scrapers.topjobs_scraper import TopJobsScraper
from tests.fixtures.sample_fixtures import (
    SAMPLE_ITPRO_JOB_HTML,
    SAMPLE_ITPRO_LIST_HTML,
    SAMPLE_TOPJOBS_HTML,
)


class TestTopJobsParser(unittest.TestCase):
    """Tests for TopJobs HTML parsing using offline deterministic fixtures."""

    def setUp(self):
        self.scraper = TopJobsScraper()

    def test_parse_valid_topjobs_fixture(self):
        records = self.scraper.parse_html_listings(SAMPLE_TOPJOBS_HTML, max_records=10)
        self.assertEqual(len(records), 3)

        # Record 1: Sysco LABS
        r1 = records[0]
        self.assertEqual(r1["source"], "TopJobs_LK")
        self.assertEqual(r1["source_job_id"], "TJ-0001541300")
        self.assertEqual(r1["company"], "Sysco LABS Sri Lanka")
        self.assertIn("Senior Software Engineer", r1["job_title"])
        self.assertIn("topjobs.lk", r1["source_url"])

        # Record 2: 99x
        r2 = records[1]
        self.assertEqual(r2["source_job_id"], "TJ-0001541301")
        self.assertEqual(r2["company"], "99x")
        self.assertIn("QA Automation Engineer", r2["job_title"])

    def test_parse_malformed_html(self):
        malformed = "<html><body><div>No tables or vacancy ids here</div></body></html>"
        records = self.scraper.parse_html_listings(malformed)
        self.assertEqual(len(records), 0)

    def test_parse_empty_html(self):
        records = self.scraper.parse_html_listings("")
        self.assertEqual(len(records), 0)


class TestITProParser(unittest.TestCase):
    """Tests for ITPro HTML parsing using offline deterministic fixtures."""

    def setUp(self):
        self.scraper = ITProScraper()

    def test_parse_listing_urls(self):
        urls = self.scraper.parse_listing_urls(SAMPLE_ITPRO_LIST_HTML, max_links=10)
        self.assertEqual(len(urls), 3)
        self.assertEqual(urls[0], "https://itpro.lk/job/14876/associate-frontend-engineer-at-kangaro-tech/")

    def test_parse_job_detail(self):
        url = "https://itpro.lk/job/14876/associate-frontend-engineer-at-kangaro-tech/"
        record = self.scraper.parse_job_html(SAMPLE_ITPRO_JOB_HTML, url)
        self.assertIsNotNone(record)
        self.assertEqual(record["source"], "ITPro_LK")
        self.assertEqual(record["source_job_id"], "ITPRO-14876")
        self.assertEqual(record["job_title"], "Associate Frontend Engineer")
        self.assertEqual(record["company"], "Kangaro Tech")
        self.assertIn("React", record["raw_text"])

    def test_parse_empty_job_html(self):
        record = self.scraper.parse_job_html("", "https://itpro.lk/job/999/")
        self.assertIsNone(record)


class TestLiveFeatureParser(unittest.TestCase):
    """Tests for conservative regex extraction of skills, salaries, and experience."""

    def test_skill_extraction(self):
        text = "Looking for a Python Developer with Docker, AWS, PostgreSQL and React experience."
        skills = extract_skills_from_text(text)
        skill_names = [s[0] for s in skills]
        self.assertIn("Python", skill_names)
        self.assertIn("Docker", skill_names)
        self.assertIn("AWS", skill_names)
        self.assertIn("PostgreSQL", skill_names)
        self.assertIn("React", skill_names)

    def test_salary_bounds_extraction_lkr(self):
        text = "Starting salary: LKR 250,000 - 400,000 per month."
        s_min, s_max, curr, raw = extract_salary_bounds(text)
        self.assertEqual(s_min, 250000.0)
        self.assertEqual(s_max, 400000.0)
        self.assertEqual(curr, "LKR")

    def test_salary_bounds_extraction_usd(self):
        text = "Pegged compensation: USD 1,200 - 2,000 monthly."
        s_min, s_max, curr, raw = extract_salary_bounds(text)
        self.assertEqual(s_min, 1200.0)
        self.assertEqual(s_max, 2000.0)
        self.assertEqual(curr, "USD")

    def test_qualitative_salary_is_none(self):
        text = "Attractive remuneration package and medical insurance."
        s_min, s_max, curr, raw = extract_salary_bounds(text)
        self.assertIsNone(s_min)
        self.assertIsNone(s_max)
        self.assertIsNone(curr)

    def test_experience_bounds_extraction(self):
        text = "Requires 3-5 years of software engineering experience."
        exp_min, exp_max = extract_experience_bounds(text)
        self.assertEqual(exp_min, 3.0)
        self.assertEqual(exp_max, 5.0)

    def test_experience_plus_extraction(self):
        text = "Minimum 5+ years building backend systems."
        exp_min, exp_max = extract_experience_bounds(text)
        self.assertEqual(exp_min, 5.0)
        self.assertIsNone(exp_max)

    def test_unspecified_experience_is_none(self):
        text = "Great opportunity to join our growing engineering team."
        exp_min, exp_max = extract_experience_bounds(text)
        self.assertIsNone(exp_min)
        self.assertIsNone(exp_max)

    def test_career_classification(self):
        # Specialist tracks
        self.assertEqual(classify_career_category("Data Scientist (NLP / LLM)", ""), "Data & AI / ML")
        self.assertEqual(classify_career_category("DevOps / Cloud Engineer", ""), "Cloud & DevOps")
        self.assertEqual(classify_career_category("QA Automation Specialist", ""), "QA & Test Automation")
        self.assertEqual(classify_career_category("Security Analyst (SOC)", ""), "Cyber Security")
        self.assertEqual(classify_career_category("UI/UX Designer", ""), "UI/UX & Product Design")
        self.assertEqual(classify_career_category("Systems & Network Administrator", ""), "IT Systems & Infrastructure")
        self.assertEqual(classify_career_category("Full Stack Developer", ""), "Software Engineering")

        # Management & Business Analysis roles (must not be misclassified as Software Engineering)
        self.assertEqual(classify_career_category("Engineering Manager", "Manage a team of software developers"), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Software Engineering Manager", ""), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Technical Project Manager", "Agile sprint management"), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Product Manager", "Lead product roadmap"), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Associate Product Manager", ""), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Scrum Master / Agile Delivery Lead", ""), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Senior Business Analyst", ""), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Director of Engineering", ""), "Management & Business Analysis")
        self.assertEqual(classify_career_category("IT Manager", ""), "Management & Business Analysis")
        self.assertEqual(classify_career_category("Delivery Manager", ""), "Management & Business Analysis")

    def test_seniority_classification(self):
        self.assertEqual(classify_seniority("Software Engineering Intern", "", 0.0), "Intern")
        self.assertEqual(classify_seniority("Associate QA Engineer", "", 1.0), "Junior")
        self.assertEqual(classify_seniority("Senior Software Engineer", "", 5.0), "Senior")
        self.assertEqual(classify_seniority("Lead Architect", "", 7.0), "Lead")


class TestDeduplicationAndProvenance(unittest.TestCase):
    """Tests for record deduplication and provenance retention."""

    def test_deduplication(self):
        records = [
            {"source_job_id": "TJ-100", "company": "Sysco", "job_title": "Java Dev"},
            {"source_job_id": "TJ-100", "company": "Sysco", "job_title": "Java Dev (Duplicate ID)"},
            {"source_job_id": "TJ-101", "company": "Sysco", "job_title": "Java Dev"},  # Duplicate company + title
            {"source_job_id": "TJ-102", "company": "WSO2", "job_title": "Go Dev"},
        ]
        deduped = deduplicate_raw_records(records)
        self.assertEqual(len(deduped), 2)
        self.assertEqual(deduped[0]["source_job_id"], "TJ-100")
        self.assertEqual(deduped[1]["source_job_id"], "TJ-102")


class TestDatasetIsolation(unittest.TestCase):
    """Guarantees that the baseline empirical academic dataset is never touched."""

    def test_frozen_real_sample_protection(self):
        real_sample_csv = os.path.join(PROJECT_ROOT, "data", "real_sample", "jobs_real_sample.csv")
        self.assertTrue(os.path.exists(real_sample_csv))
        before_stat = os.stat(real_sample_csv)

        # Backup existing live feed and dashboard files to preserve clean git tree
        tracked_files = [
            os.path.join(PROJECT_ROOT, "data", "live_feed", "jobs_live_feed.csv"),
            os.path.join(PROJECT_ROOT, "data", "live_feed", "job_skills_live_feed.csv"),
            os.path.join(PROJECT_ROOT, "data", "live_feed", "live_feed_metadata.json"),
            os.path.join(PROJECT_ROOT, "dashboard", "data.js"),
        ]
        backups = {}
        for p in tracked_files:
            if os.path.exists(p):
                with open(p, "rb") as bf:
                    backups[p] = bf.read()

        try:
            # Run live updater with offline fixtures
            metadata = run_live_update(sources=["topjobs", "itpro"], limit_per_source=5, use_fixtures=True)
            self.assertIsNotNone(metadata)
            self.assertIn("total_retrieved", metadata)

            # Check real_sample is unchanged
            after_stat = os.stat(real_sample_csv)
            self.assertEqual(before_stat.st_mtime, after_stat.st_mtime)
            self.assertEqual(before_stat.st_size, after_stat.st_size)

            # Check live feed was created in data/live_feed/
            live_csv = os.path.join(PROJECT_ROOT, "data", "live_feed", "jobs_live_feed.csv")
            self.assertTrue(os.path.exists(live_csv))
        finally:
            for p, content in backups.items():
                with open(p, "wb") as bf:
                    bf.write(content)


if __name__ == "__main__":
    unittest.main()
