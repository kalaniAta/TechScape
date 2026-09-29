"""
TechScape: Pytest Global Configuration & Shared Fixtures
=========================================================
Provides session-wide project root resolution, empirical data file paths,
and reusable test fixtures across unit and integration test suites.
"""

import os
import sys

import pytest

# Ensure project root is on sys.path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)


@pytest.fixture(scope="session")
def project_root() -> str:
    """Returns absolute path to project root directory."""
    return PROJECT_ROOT


@pytest.fixture(scope="session")
def real_jobs_path(project_root) -> str:
    """Returns absolute path to verified empirical jobs dataset."""
    return os.path.join(project_root, "data", "real_sample", "jobs_real_sample.csv")


@pytest.fixture(scope="session")
def real_skills_path(project_root) -> str:
    """Returns absolute path to verified empirical skills dataset."""
    return os.path.join(project_root, "data", "real_sample", "job_skills_real_sample.csv")


@pytest.fixture(scope="session")
def macro_data_path(project_root) -> str:
    """Returns absolute path to macroeconomic indicators dataset."""
    return os.path.join(project_root, "data", "processed", "macro_labour_indicators.csv")
