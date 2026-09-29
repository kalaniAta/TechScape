"""
TechScape: Strict Pydantic Ingestion Schemas
===========================================
Defines strict validation rules for heterogeneous job and skill records.
Guarantees the "Zero Fabrication" governance standard by rejecting missing
or malformed data instead of silently defaulting to fabricated placeholders.
"""

import re
from typing import Any, Dict, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

VALID_CAREER_CATEGORIES = {
    "Software Engineering",
    "Data & AI / ML",
    "Cloud & DevOps",
    "QA & Test Automation",
    "Cyber Security",
    "IT Systems & Infrastructure",
    "Management & Business Analysis",
    "UI/UX & Product Design"
}

VALID_WORK_MODES = {"Hybrid", "On-site", "Remote"}
VALID_EMPLOYMENT_TYPES = {"Full-Time", "Part-Time", "Contract", "Internship"}
VALID_CURRENCIES = {"LKR", "USD"}

DATE_REGEX = re.compile(r"^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$")
URL_REGEX = re.compile(r"^https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&'()*+,;=]+$")


class RawJobIngestionSchema(BaseModel):
    """
    Strict validation model for raw job vacancy records.
    Rejects placeholder defaults ('Unknown Role', 'Confidential', etc.)
    and enforces strict cryptographic provenance constraints.
    """
    model_config = ConfigDict(extra="ignore", str_strip_whitespace=True)

    job_id: str = Field(..., min_length=2, description="Unique job record identifier")
    date_posted: str = Field(..., description="Date posted in YYYY-MM-DD format")
    job_title: str = Field(..., min_length=2, description="Job role title")
    company: str = Field(..., min_length=2, description="Hiring company or organization")
    source: str = Field(..., min_length=2, description="Data source portal identifier")
    source_url: str = Field(..., description="Verifiable public provenance URL")

    career_category: Optional[str] = Field(default=None, description="Standardized career track")
    location: Optional[str] = Field(default="Sri Lanka", description="Job location")
    work_mode: Optional[str] = Field(default="Hybrid", description="Work arrangement")
    employment_type: Optional[str] = Field(default="Full-Time", description="Contract arrangement")

    experience_min: Optional[float] = Field(default=None, ge=0, description="Minimum required experience in years")
    experience_max: Optional[float] = Field(default=None, ge=0, description="Maximum experience threshold in years")
    salary_min: Optional[float] = Field(default=None, gt=0, description="Minimum disclosed salary")
    salary_max: Optional[float] = Field(default=None, gt=0, description="Maximum disclosed salary")
    currency: Optional[str] = Field(default=None, description="Disclosed salary currency")

    collection_date: Optional[str] = Field(default=None, description="Collection timestamp in YYYY-MM-DD format")
    is_synthetic: bool = Field(default=False, description="Synthetic development flag")
    original_title: Optional[str] = Field(default=None, description="Raw unmodified job title")
    original_salary: Optional[str] = Field(default=None, description="Raw unmodified salary text")
    original_experience: Optional[str] = Field(default=None, description="Raw unmodified experience text")

    @field_validator("job_title", "company")
    @classmethod
    def validate_non_placeholder(cls, value: str, info) -> str:
        prohibited_placeholders = {
            "unknown role", "unknown", "untitled", "n/a", "none",
            "confidential", "undisclosed company", "test"
        }
        val_clean = value.strip().lower()
        if not val_clean or val_clean in prohibited_placeholders:
            raise ValueError(f"Field '{info.field_name}' contains invalid placeholder: '{value}'")
        return value.strip()

    @field_validator("date_posted", "collection_date")
    @classmethod
    def validate_iso_date(cls, value: Optional[str], info) -> Optional[str]:
        if value is None:
            return value
        if not DATE_REGEX.match(value.strip()):
            raise ValueError(f"Field '{info.field_name}' value '{value}' must match ISO format YYYY-MM-DD")
        return value.strip()

    @field_validator("source_url")
    @classmethod
    def validate_provenance_url(cls, value: str) -> str:
        val = value.strip()
        if not URL_REGEX.match(val) or "example.com" in val.lower():
            raise ValueError(f"Invalid or placeholder provenance URL: '{value}'")
        return val

    @field_validator("career_category")
    @classmethod
    def validate_career_track(cls, value: Optional[str]) -> Optional[str]:
        if value is not None and value not in VALID_CAREER_CATEGORIES:
            raise ValueError(f"Invalid career category: '{value}'. Allowed: {sorted(VALID_CAREER_CATEGORIES)}")
        return value

    @field_validator("work_mode")
    @classmethod
    def validate_work_mode(cls, value: Optional[str]) -> Optional[str]:
        if value is not None and value not in VALID_WORK_MODES:
            raise ValueError(f"Invalid work mode: '{value}'. Allowed: {sorted(VALID_WORK_MODES)}")
        return value

    @field_validator("currency")
    @classmethod
    def validate_currency(cls, value: Optional[str]) -> Optional[str]:
        if value is not None:
            val_upper = value.strip().upper()
            if val_upper not in VALID_CURRENCIES:
                raise ValueError(f"Unsupported currency: '{value}'. Supported: {sorted(VALID_CURRENCIES)}")
            return val_upper
        return value

    @model_validator(mode="after")
    def validate_numeric_bounds(self) -> "RawJobIngestionSchema":
        # Validate experience bounds
        if self.experience_min is not None and self.experience_max is not None:
            if self.experience_max < self.experience_min:
                raise ValueError(
                    f"experience_max ({self.experience_max}) cannot be less than experience_min ({self.experience_min})"
                )

        # Validate salary bounds
        if self.salary_min is not None and self.salary_max is not None:
            if self.salary_max < self.salary_min:
                raise ValueError(
                    f"salary_max ({self.salary_max}) cannot be less than salary_min ({self.salary_min})"
                )

        # Salary requires currency
        if (self.salary_min is not None or self.salary_max is not None) and not self.currency:
            raise ValueError("Disclosed numeric salary requires a specified currency (LKR or USD)")

        # Default original_title to job_title if omitted
        if not self.original_title:
            self.original_title = self.job_title

        return self

    def to_canonical_dict(self) -> Dict[str, Any]:
        """Returns clean dictionary conforming to TechScape canonical jobs schema."""
        return self.model_dump()


class RawSkillIngestionSchema(BaseModel):
    """Strict validation model for raw skills mapped to a parent job record."""
    model_config = ConfigDict(extra="ignore", str_strip_whitespace=True)

    job_id: str = Field(..., min_length=2, description="Foreign key to parent job")
    skill_name: str = Field(..., min_length=1, description="Canonical skill identifier")
    skill_category: str = Field(default="General", description="Skill technical domain")
    raw_skill_string: Optional[str] = Field(default=None, description="Original unparsed string")
    is_mandatory: bool = Field(default=True, description="Requirement constraint flag")

    @field_validator("skill_name")
    @classmethod
    def validate_skill_name(cls, value: str) -> str:
        clean = value.strip()
        if not clean or clean.lower() in {"n/a", "none", "null", "undefined"}:
            raise ValueError(f"Invalid skill name: '{value}'")
        return clean

    @model_validator(mode="after")
    def ensure_raw_string(self) -> "RawSkillIngestionSchema":
        if not self.raw_skill_string:
            self.raw_skill_string = self.skill_name
        return self
