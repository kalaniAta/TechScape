"""
TechScape: Text Hygiene & Encoding Sanitization
==============================================
Validates and sanitizes text files to ensure strict UTF-8 compliance,
handles Byte-Order Marks (BOM), normalizes line endings, and eliminates
non-printable control characters without modifying dataset values.
"""

import html
import os
import re
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple


@dataclass
class EncodingReport:
    """Diagnostic report on file encoding and text hygiene."""
    file_path: str
    is_valid_utf8: bool
    has_bom: bool
    has_null_bytes: bool
    has_crlf: bool
    line_count: int
    issues_found: List[str]

    @property
    def is_healthy(self) -> bool:
        return self.is_valid_utf8 and not self.has_null_bytes and len(self.issues_found) == 0


def sanitize_string(text: str) -> str:
    """
    Cleans a text string:
    1. Unescapes common HTML entities (&amp; -> &, etc.)
    2. Strips ASCII control characters except standard whitespace (\\t, \\n, \\r)
    3. Normalizes multiple contiguous horizontal spaces to a single space
    """
    if not isinstance(text, str):
        return str(text) if text is not None else ""

    # Unescape HTML entities
    cleaned = html.unescape(text)

    # Remove non-printable control chars except \t, \n, \r
    cleaned = "".join(
        ch for ch in cleaned
        if ch in ("\t", "\n", "\r") or (ord(ch) >= 32 and ord(ch) != 127)
    )

    # Normalize horizontal whitespace within single lines
    lines = cleaned.splitlines()
    normalized_lines = [re.sub(r"[ \t]+", " ", l).strip() for l in lines]
    return "\n".join(normalized_lines)


def check_file_encoding(file_path: str) -> EncodingReport:
    """
    Analyzes raw bytes of a file to check UTF-8 compliance, BOM, nulls, and line endings.
    """
    issues = []
    has_bom = False
    has_nulls = False
    is_utf8 = True
    has_crlf = False
    line_count = 0

    if not os.path.exists(file_path):
        return EncodingReport(
            file_path=file_path,
            is_valid_utf8=False,
            has_bom=False,
            has_null_bytes=False,
            has_crlf=False,
            line_count=0,
            issues_found=[f"File does not exist: {file_path}"]
        )

    with open(file_path, "rb") as f:
        raw_bytes = f.read()

    # Check for UTF-8 Byte Order Mark (BOM)
    if raw_bytes.startswith(b"\xef\xbb\xbf"):
        has_bom = True
        issues.append("Contains UTF-8 Byte Order Mark (BOM)")

    # Check for null bytes
    if b"\x00" in raw_bytes:
        has_nulls = True
        issues.append("Contains forbidden null bytes (\\x00)")

    # Check for CRLF line endings
    if b"\r\n" in raw_bytes:
        has_crlf = True

    # Validate UTF-8 decoding
    try:
        content = raw_bytes.decode("utf-8")
        line_count = len(content.splitlines())
    except UnicodeDecodeError as e:
        is_utf8 = False
        issues.append(f"UTF-8 decode failed: {str(e)}")

    return EncodingReport(
        file_path=file_path,
        is_valid_utf8=is_utf8,
        has_bom=has_bom,
        has_null_bytes=has_nulls,
        has_crlf=has_crlf,
        line_count=line_count,
        issues_found=issues
    )


def verify_directory_encodings(directory_path: str, pattern: str = ".csv") -> Dict[str, EncodingReport]:
    """
    Scans all matching files in a directory and returns an encoding report dictionary.
    """
    reports = {}
    if not os.path.exists(directory_path):
        return reports

    for root, _, files in os.walk(directory_path):
        for f in files:
            if f.endswith(pattern):
                full_path = os.path.join(root, f)
                rel_path = os.path.relpath(full_path, directory_path)
                reports[rel_path] = check_file_encoding(full_path)

    return reports
