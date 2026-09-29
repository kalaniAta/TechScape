"""
TechScape: Dead-Letter Queue (DLQ) Quarantine Engine
===================================================
Intercepts, documents, and quarantines records failing schema validation
or provenance rules, ensuring malformed records are preserved for auditing
without halting pipeline batch execution.
"""

import json
import os
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
QUARANTINE_DIR = os.path.join(PROJECT_ROOT, "data", "quarantine")


@dataclass
class StructuredValidationError:
    """Detailed description of a field-level validation failure."""
    field: str
    error_type: str
    message: str


@dataclass
class QuarantinedRecord:
    """Canonical representation of an unprocessable raw record in the DLQ."""
    quarantine_id: str
    run_id: str
    source_name: str
    record_index: int
    raw_payload: Dict[str, Any]
    errors: List[Dict[str, str]]
    timestamp_utc: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


class QuarantineEngine:
    """
    In-memory accumulator and disk serializer for quarantined DLQ records.
    """

    def __init__(self, run_id: str, source_name: str, quarantine_dir: str = QUARANTINE_DIR):
        self.run_id = run_id
        self.source_name = source_name
        self.quarantine_dir = quarantine_dir
        self.records: List[QuarantinedRecord] = []
        os.makedirs(self.quarantine_dir, exist_ok=True)

    def record_failure(
        self,
        raw_payload: Dict[str, Any],
        record_index: int,
        errors: List[StructuredValidationError]
    ) -> QuarantinedRecord:
        """Adds a failed record to the quarantine accumulator."""
        qid = f"QL-{self.run_id}-{len(self.records) + 1:04d}"
        q_record = QuarantinedRecord(
            quarantine_id=qid,
            run_id=self.run_id,
            source_name=self.source_name,
            record_index=record_index,
            raw_payload=raw_payload,
            errors=[asdict(e) for e in errors]
        )
        self.records.append(q_record)
        return q_record

    def flush_to_disk(self) -> Optional[str]:
        """
        Serializes all accumulated quarantine records to data/quarantine/quarantine_<run_id>.json.
        Returns the absolute file path, or None if no records were quarantined.
        """
        if not self.records:
            return None

        filename = f"quarantine_{self.run_id}.json"
        filepath = os.path.join(self.quarantine_dir, filename)

        payload = {
            "run_id": self.run_id,
            "source_name": self.source_name,
            "quarantine_count": len(self.records),
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "records": [r.to_dict() for r in self.records]
        }

        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)

        return filepath

    @property
    def count(self) -> int:
        return len(self.records)

    def get_summary(self) -> Dict[str, Any]:
        """Returns error frequency distributions across quarantined records."""
        err_freq: Dict[str, int] = {}
        for r in self.records:
            for e in r.errors:
                key = f"{e['field']}:{e['error_type']}"
                err_freq[key] = err_freq.get(key, 0) + 1

        return {
            "quarantine_count": len(self.records),
            "error_distribution": err_freq
        }
