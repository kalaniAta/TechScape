"""
TechScape: Modular API Fetcher & Ingestion Adapters
===================================================
Provides an extensible, modular interface for ingesting vacancy streams and
macroeconomic data from external APIs or structured feeds without scraping.
"""

import abc
import csv
import json
import os
import sys
from datetime import datetime
from typing import Any, Dict, List, Optional


class BaseJobAPIFetcher(abc.ABC):
    """
    Abstract base class for all job vacancy API fetchers.
    Ensures a standardized contract for upstream data ingestion.
    """

    def __init__(self, endpoint_url: Optional[str] = None, api_key: Optional[str] = None):
        self.endpoint_url = endpoint_url or "https://api.example.com/v1"
        self.api_key = api_key

    @abc.abstractmethod
    def health_check(self) -> bool:
        """Verify API availability and authentication status."""
        pass

    @abc.abstractmethod
    def fetch_vacancies(
        self, query: Optional[str] = None, limit: int = 100, page: int = 1
    ) -> List[Dict[str, Any]]:
        """Fetch raw vacancy records from the data provider."""
        pass

    @abc.abstractmethod
    def fetch_by_id(self, job_id: str) -> Optional[Dict[str, Any]]:
        """Fetch a single raw vacancy by its unique identifier."""
        pass


class MockJobAPIFetcher(BaseJobAPIFetcher):
    """
    Safe reference / mock API fetcher.
    Demonstrates API consumption and schema conformance without network dependencies
    or fabricating empirical records into the frozen dataset.
    """

    def __init__(self, mock_data: Optional[List[Dict[str, Any]]] = None):
        super().__init__(endpoint_url="mock://techscape.api/jobs")
        self._mock_data = mock_data or self._default_mock_vacancies()

    def health_check(self) -> bool:
        return True

    def fetch_vacancies(
        self, query: Optional[str] = None, limit: int = 100, page: int = 1
    ) -> List[Dict[str, Any]]:
        results = self._mock_data
        if query:
            q = query.lower()
            results = [
                j for j in results
                if q in j.get("job_title", "").lower() or q in j.get("career_category", "").lower()
            ]
        start_idx = (page - 1) * limit
        return results[start_idx : start_idx + limit]

    def fetch_by_id(self, job_id: str) -> Optional[Dict[str, Any]]:
        for j in self._mock_data:
            if j.get("job_id") == job_id:
                return j
        return None

    @staticmethod
    def _default_mock_vacancies() -> List[Dict[str, Any]]:
        return [
            {
                "job_id": "API_MOCK_001",
                "date_posted": "2026-08-15",
                "job_title": "Senior Cloud Infrastructure Engineer",
                "career_category": "Cloud & DevOps",
                "company": "Enterprise Cloud Lanka",
                "location": "Colombo, Western Province",
                "work_mode": "Hybrid",
                "employment_type": "Full-Time",
                "experience_min": 4.0,
                "experience_max": 7.0,
                "salary_min": 450000.0,
                "salary_max": 600000.0,
                "currency": "LKR",
                "source": "Mock Partner API",
                "source_url": "https://example.com/jobs/api-mock-001",
                "collection_date": "2026-08-16",
                "is_synthetic": True,
                "skills": ["AWS", "Kubernetes", "Terraform", "Docker", "Linux"]
            },
            {
                "job_id": "API_MOCK_002",
                "date_posted": "2026-08-18",
                "job_title": "Junior Data Analyst",
                "career_category": "Data & AI / ML",
                "company": "Colombo Analytics Group",
                "location": "Colombo, Western Province",
                "work_mode": "Hybrid",
                "employment_type": "Full-Time",
                "experience_min": 1.0,
                "experience_max": 2.0,
                "salary_min": 180000.0,
                "salary_max": 240000.0,
                "currency": "LKR",
                "source": "Mock Partner API",
                "source_url": "https://example.com/jobs/api-mock-002",
                "collection_date": "2026-08-19",
                "is_synthetic": True,
                "skills": ["Python", "SQL", "PowerBI", "Pandas"]
            }
        ]


class PublicMacroAPIFetcher:
    """
    Extensible client for macroeconomic statistics (DCS Labour Force Survey & CBSL).
    Demonstrates ingestion of macroeconomic indicators.
    """

    def __init__(self, endpoint_url: Optional[str] = None):
        self.endpoint_url = endpoint_url or "https://api.cbsl.gov.lk/v1/indicators"

    def fetch_macro_series(self, indicator_code: str) -> List[Dict[str, Any]]:
        """Returns mock time series indicators formatted for TechScape."""
        sample_series = {
            "ICT_EXPORTS_USD_MN": [
                {"year": 2021, "indicator": "ICT Service Exports", "value": 1150.0, "unit": "USD Million"},
                {"year": 2022, "indicator": "ICT Service Exports", "value": 1280.0, "unit": "USD Million"},
                {"year": 2023, "indicator": "ICT Service Exports", "value": 1390.0, "unit": "USD Million"},
                {"year": 2024, "indicator": "ICT Service Exports", "value": 1520.0, "unit": "USD Million"},
                {"year": 2025, "indicator": "ICT Service Exports", "value": 1680.0, "unit": "USD Million"}
            ]
        }
        return sample_series.get(indicator_code, [])


def serialize_to_csv(
    records: List[Dict[str, Any]],
    output_path: str,
    prevent_overwrite: bool = True
) -> bool:
    """
    Safely writes ingested records to a target CSV file.
    Guarantees that existing empirical or frozen files cannot be accidentally destroyed.
    """
    if os.path.exists(output_path) and prevent_overwrite:
        raise FileExistsError(
            f"Target file '{output_path}' already exists. Overwrite blocked to protect data integrity."
        )

    if not records:
        return False

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    fieldnames = list(records[0].keys())

    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in records:
            writer.writerow(r)

    return True
