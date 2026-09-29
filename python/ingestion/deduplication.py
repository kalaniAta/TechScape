"""
TechScape: Deterministic Composite Key Deduplication Engine
===========================================================
Generates cryptographic stable fingerprints from canonical posting attributes
to accurately identify and filter duplicate job vacancies across ingestion runs.
"""

import hashlib
import re
from typing import Any, Dict, List, Optional, Set, Tuple


def normalize_token(text: Optional[str]) -> str:
    """Normalizes string tokens for collision-resistant key generation."""
    if not text:
        return ""
    # Lowercase, strip punctuation and collapse whitespace
    clean = re.sub(r"[^\w\s]", "", str(text).lower())
    return " ".join(clean.split())


def compute_stable_job_fingerprint(record: Dict[str, Any]) -> str:
    """
    Computes a deterministic SHA-256 fingerprint for a job posting based on:
    canonical title, company, date posted, and location.
    """
    title = normalize_token(record.get("job_title") or record.get("original_title") or record.get("title"))
    company = normalize_token(record.get("company") or record.get("employer"))
    date_posted = str(record.get("date_posted") or record.get("posted_date") or "").strip()
    location = normalize_token(record.get("location") or "colombo")

    raw_key = f"{title}|{company}|{date_posted}|{location}"
    return hashlib.sha256(raw_key.encode("utf-8")).hexdigest()


class DeduplicationEngine:
    """
    Deduplication filter maintaining seen fingerprints and job IDs.
    """

    def __init__(self, existing_fingerprints: Optional[Set[str]] = None):
        self.seen_fingerprints: Set[str] = set(existing_fingerprints or [])
        self.seen_job_ids: Set[str] = set()

    def is_duplicate(self, record: Dict[str, Any]) -> bool:
        """Checks if a record is a duplicate by job_id or composite fingerprint."""
        jid = str(record.get("job_id", "")).strip()
        if jid and jid in self.seen_job_ids:
            return True

        fingerprint = compute_stable_job_fingerprint(record)
        return fingerprint in self.seen_fingerprints

    def register(self, record: Dict[str, Any]) -> None:
        """Registers a seen record into the deduplication state."""
        jid = str(record.get("job_id", "")).strip()
        if jid:
            self.seen_job_ids.add(jid)

        fingerprint = compute_stable_job_fingerprint(record)
        self.seen_fingerprints.add(fingerprint)

    def deduplicate_batch(
        self, records: List[Dict[str, Any]]
    ) -> Tuple[List[Dict[str, Any]], int]:
        """
        Filters a batch of records, retaining unique entries in insertion order.
        Returns (unique_records, duplicate_count).
        """
        unique_records = []
        duplicate_count = 0

        for r in records:
            if self.is_duplicate(r):
                duplicate_count += 1
            else:
                self.register(r)
                unique_records.append(r)

        return unique_records, duplicate_count
