"""
TechScape Relational Domain Models (SQLAlchemy 2.0 Declarative).
Defines schemas, foreign key cascades, and compound B-Tree indexes.
"""

from datetime import datetime, timezone
from typing import List, Optional

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    """Base declarative class for all TechScape ORM models."""
    pass


class Job(Base):
    """
    Job vacancy posting entity.
    Stores complete provenance, classification, compensation, and work mode.
    """
    __tablename__ = "jobs"

    job_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    source: Mapped[str] = mapped_column(String(64), nullable=False)
    source_url: Mapped[str] = mapped_column(String(1024), nullable=False)
    collection_date: Mapped[str] = mapped_column(String(32), nullable=False)
    source_job_id: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    date_posted: Mapped[str] = mapped_column(String(32), nullable=False)
    original_title: Mapped[str] = mapped_column(String(255), nullable=False)
    job_title: Mapped[str] = mapped_column(String(255), nullable=False)
    career_category: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    seniority_level: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    company: Mapped[str] = mapped_column(String(255), index=True, nullable=False)
    location: Mapped[str] = mapped_column(String(150), nullable=False)
    work_mode: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    employment_type: Mapped[str] = mapped_column(String(50), nullable=False)
    original_experience: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    experience_min: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    experience_max: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    original_salary: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    salary_min: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    salary_max: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    currency: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    is_synthetic: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    # Relationships
    skills: Mapped[List["JobSkill"]] = relationship(
        back_populates="job",
        cascade="all, delete-orphan",
        passive_deletes=True
    )

    __table_args__ = (
        Index("ix_jobs_category_work_mode", "career_category", "work_mode"),
        Index("ix_jobs_category_seniority", "career_category", "seniority_level"),
    )

    def __repr__(self) -> str:
        return f"<Job(job_id='{self.job_id}', title='{self.job_title}', company='{self.company}')>"


class Skill(Base):
    """
    Canonical skill taxonomy entity.
    Stores normalized skill names and categories.
    """
    __tablename__ = "skills"

    skill_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    skill_name: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    skill_category: Mapped[str] = mapped_column(String(100), index=True, nullable=False)

    # Relationships
    job_associations: Mapped[List["JobSkill"]] = relationship(
        back_populates="skill",
        cascade="all, delete-orphan",
        passive_deletes=True
    )

    def __repr__(self) -> str:
        return f"<Skill(id={self.skill_id}, name='{self.skill_name}', category='{self.skill_category}')>"


class JobSkill(Base):
    """
    Relational association between a Job posting and a Skill entity.
    Enforces CASCADE deletes and uniqueness per (job_id, skill_id) pair.
    """
    __tablename__ = "job_skills"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    job_id: Mapped[str] = mapped_column(
        String(64),
        ForeignKey("jobs.job_id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    skill_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey("skills.skill_id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    skill_raw: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    is_required: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    # Relationships
    job: Mapped["Job"] = relationship(back_populates="skills")
    skill: Mapped["Skill"] = relationship(back_populates="job_associations")

    __table_args__ = (
        UniqueConstraint("job_id", "skill_id", name="uq_job_skill"),
    )

    def __repr__(self) -> str:
        return f"<JobSkill(job='{self.job_id}', skill_id={self.skill_id}, raw='{self.skill_raw}')>"


class MacroIndicator(Base):
    """
    Longitudinal macroeconomic indicator from official statistics (CBSL / DCS).
    """
    __tablename__ = "macro_indicators"

    indicator_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    indicator_name: Mapped[str] = mapped_column(String(150), index=True, nullable=False)
    year: Mapped[int] = mapped_column(Integer, index=True, nullable=False)
    quarter: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    population_group: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    value: Mapped[float] = mapped_column(Float, nullable=False)
    unit: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    source: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)

    def __repr__(self) -> str:
        return f"<MacroIndicator(id='{self.indicator_id}', year={self.year}, value={self.value})>"


class PipelineRun(Base):
    """
    Operational audit log tracking pipeline executions, DLQ quarantine counts, and manifests.
    """
    __tablename__ = "pipeline_runs"

    run_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    source_name: Mapped[str] = mapped_column(String(100), nullable=False)
    status: Mapped[str] = mapped_column(String(50), nullable=False)
    records_read: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    records_accepted: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    records_quarantined: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    records_deduplicated: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    quarantine_file: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)
    manifest_file: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)
    duration_seconds: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    def __repr__(self) -> str:
        return f"<PipelineRun(run_id='{self.run_id}', status='{self.status}', accepted={self.records_accepted})>"
