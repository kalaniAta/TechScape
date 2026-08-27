"""
TechScape Preprocessing Subpackage
==================================
Text hygiene, encoding normalization, and schema provenance validation.
"""

from .text_hygiene import (
    check_file_encoding,
    sanitize_string,
    verify_directory_encodings,
    EncodingReport
)
from .raw_validator import (
    validate_dataset_pair,
    validate_jobs_table,
    validate_skills_table,
    ValidationResult
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
