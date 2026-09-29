"""
TechScape: Ingestion Run Manifest Engine
========================================
Generates cryptographic receipts and execution telemetry for every ingestion
pipeline execution, recording input hashes, throughput metrics, duration,
and quarantine artifacts to ensure 100% auditable data governance.
"""

import hashlib
import json
import os
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Any, Dict, Optional

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MANIFEST_DIR = os.path.join(PROJECT_ROOT, "data", "manifests")


def compute_file_sha256(filepath: str) -> str:
    """Computes SHA-256 hash of a file for cryptographic provenance tracking."""
    if not os.path.exists(filepath):
        return "NON_EXISTENT_FILE"
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()


@dataclass
class IngestionManifest:
    """Immutable audit record detailing an ingestion batch execution."""
    run_id: str
    source_name: str
    input_file: str
    records_read: int
    records_accepted: int
    records_quarantined: int
    records_deduplicated: int
    duration_seconds: float
    manifest_version: str = "1.0"
    timestamp_utc: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    input_sha256: str = "N/A"
    quarantine_file: Optional[str] = None
    output_file: Optional[str] = None
    status: str = "SUCCESS"

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


class ManifestEngine:
    """Generates, tracks, and persists execution manifests to disk."""

    def __init__(self, manifest_dir: str = MANIFEST_DIR):
        self.manifest_dir = manifest_dir
        os.makedirs(self.manifest_dir, exist_ok=True)

    def create_and_save_manifest(
        self,
        run_id: str,
        source_name: str,
        input_file: str,
        records_read: int,
        records_accepted: int,
        records_quarantined: int,
        records_deduplicated: int,
        duration_seconds: float,
        quarantine_file: Optional[str] = None,
        output_file: Optional[str] = None
    ) -> IngestionManifest:
        """Constructs and serializes an IngestionManifest to disk."""
        sha256_hash = compute_file_sha256(input_file) if os.path.exists(input_file) else "IN_MEMORY_PAYLOAD"

        if records_quarantined > 0:
            status = "COMPLETED_WITH_QUARANTINE"
        elif records_accepted == 0 and records_read > 0:
            status = "FAILED_ALL_QUARANTINED"
        else:
            status = "SUCCESS"

        manifest = IngestionManifest(
            manifest_version="1.0",
            run_id=run_id,
            source_name=source_name,
            input_file=input_file,
            input_sha256=sha256_hash,
            records_read=records_read,
            records_accepted=records_accepted,
            records_quarantined=records_quarantined,
            records_deduplicated=records_deduplicated,
            duration_seconds=round(duration_seconds, 4),
            quarantine_file=quarantine_file,
            output_file=output_file,
            status=status
        )

        manifest_file = os.path.join(self.manifest_dir, f"manifest_{run_id}.json")
        with open(manifest_file, "w", encoding="utf-8") as f:
            json.dump(manifest.to_dict(), f, indent=2, ensure_ascii=False)

        return manifest
