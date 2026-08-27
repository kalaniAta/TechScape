"""
TechScape Ingestion Subpackage
==============================
Modular API fetchers and heterogeneous source adapters for raw data ingestion.
"""

from .api_fetcher import BaseJobAPIFetcher, MockJobAPIFetcher, PublicMacroAPIFetcher
from .source_adapters import (
    JSONSourceAdapter,
    TSVSourceAdapter,
    CSVSourceAdapter,
    MacroSeriesAdapter,
    StandardJobRecord
)

__all__ = [
    "BaseJobAPIFetcher",
    "MockJobAPIFetcher",
    "PublicMacroAPIFetcher",
    "JSONSourceAdapter",
    "TSVSourceAdapter",
    "CSVSourceAdapter",
    "MacroSeriesAdapter",
    "StandardJobRecord"
]
