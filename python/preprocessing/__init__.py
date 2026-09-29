"""
TechScape Preprocessing Subpackage
==================================
Text hygiene, encoding normalization, and schema provenance validation.
"""

from .raw_validator import (
    ValidationResult,
    validate_dataset_pair,
    validate_jobs_table,
    validate_skills_table,
)
from .text_hygiene import (
    EncodingReport,
    check_file_encoding,
    sanitize_string,
    verify_directory_encodings,
)

__all__ = [
    "check_file_encoding",
    "sanitize_string",
    "verify_directory_encodings",
    "EncodingReport",
    "validate_dataset_pair",
    "validate_jobs_table",
    "validate_skills_table",
    "ValidationResult"
]
