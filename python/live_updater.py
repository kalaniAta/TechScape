"""
TechScape: Source-Retrieved Live Feed Ingestion & Updater
=========================================================
Executes periodic/on-demand retrieval from permitted Sri Lankan job portals,
normalizes features, deduplicates records, and updates data/live_feed/
and the dashboard bundle.

GUARANTEES 100% ISOLATION: Never alters data/real_sample/ or frozen academic artifacts.

Usage:
    python python/live_updater.py [--sources topjobs,itpro] [--limit 40] [--offline-fixtures]
"""

import argparse
import csv
import datetime
import json
import os
import sys
from typing import Any, Dict, List, Set, Tuple

# Ensure project root is in sys.path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from python.preprocessing.live_parser import is_strictly_it_job, parse_and_normalize_record
from python.scrapers.itpro_scraper import ITProScraper
from python.scrapers.topjobs_scraper import TopJobsScraper
from tests.fixtures.sample_fixtures import (
    SAMPLE_ITPRO_JOB_HTML,
    SAMPLE_ITPRO_LIST_HTML,
    SAMPLE_TOPJOBS_HTML,
)

LIVE_FEED_DIR = os.path.join(PROJECT_ROOT, "data", "live_feed")
DASHBOARD_DATA_JS = os.path.join(PROJECT_ROOT, "dashboard", "data.js")
BASELINE_JOBS_CSV = os.path.join(PROJECT_ROOT, "data", "processed", "jobs_real_transformed.csv")
BASELINE_SKILLS_CSV = os.path.join(PROJECT_ROOT, "data", "processed", "job_skills_real_transformed.csv")
MACRO_CSV = os.path.join(PROJECT_ROOT, "data", "processed", "macro_labour_indicators.csv")


def ensure_live_feed_directory() -> str:
    """Creates data/live_feed/ directory if not present."""
    os.makedirs(LIVE_FEED_DIR, exist_ok=True)
    return LIVE_FEED_DIR


def fetch_raw_listings(sources: List[str], limit_per_source: int, use_fixtures: bool = False) -> List[Dict[str, Any]]:
    """
    Fetches raw listings from permitted sources or offline fixtures.
    """
    all_raw: List[Dict[str, Any]] = []

    if use_fixtures:
        print("[INFO] Using offline deterministic test fixtures...")
        if "topjobs" in sources:
            tj = TopJobsScraper()
            records = tj.parse_html_listings(SAMPLE_TOPJOBS_HTML, max_records=limit_per_source)
            all_raw.extend(records)
            print(f"  [TopJobs Fixture] Parsed {len(records)} test records.")

        if "itpro" in sources:
            itp = ITProScraper()
            urls = itp.parse_listing_urls(SAMPLE_ITPRO_LIST_HTML, max_links=limit_per_source)
            for u in urls:
                rec = itp.parse_job_html(SAMPLE_ITPRO_JOB_HTML, u)
                if rec:
                    all_raw.append(rec)
            print(f"  [ITPro Fixture] Parsed {len(urls)} test records.")
        return all_raw

    # Live Fetching
    if "topjobs" in sources:
        print(f"[FETCH] Fetching live vacancies from TopJobs Sri Lanka (limit={limit_per_source})...")
        tj = TopJobsScraper()
        tj_records = tj.fetch_live_vacancies(limit=limit_per_source)
        all_raw.extend(tj_records)
        print(f"  [OK] TopJobs: Successfully retrieved {len(tj_records)} vacancy notices.")

    if "itpro" in sources:
        print(f"[FETCH] Fetching live vacancies from ITPro Sri Lanka (limit={limit_per_source})...")
        itp = ITProScraper()
        itp_records = itp.fetch_live_vacancies(limit=min(limit_per_source, 15))
        all_raw.extend(itp_records)
        print(f"  [OK] ITPro: Successfully retrieved {len(itp_records)} vacancy notices.")

    return all_raw


def deduplicate_raw_records(raw_records: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Deduplicates records based on source_job_id and (company, title) tuple.
    """
    seen_ids: Set[str] = set()
    seen_tuples: Set[Tuple[str, str]] = set()
    deduped: List[Dict[str, Any]] = []

    for r in raw_records:
        src_id = r.get("source_job_id", "")
        comp = r.get("company", "").strip().lower()
        title = r.get("job_title", "").strip().lower()

        if src_id and src_id in seen_ids:
            continue
        if comp and title and (comp, title) in seen_tuples:
            continue

        if src_id:
            seen_ids.add(src_id)
        if comp and title:
            seen_tuples.add((comp, title))

        deduped.append(r)

    return deduped


def write_csv(filepath: str, rows: List[Dict[str, Any]]) -> None:
    """Writes list of dicts to CSV file cleanly."""
    if not rows:
        return
    fieldnames = list(rows[0].keys())
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def read_csv_as_dicts(filepath: str) -> List[Dict[str, Any]]:
    """Reads a CSV file into list of dictionaries."""
    if not os.path.exists(filepath):
        return []
    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return list(reader)


def export_unified_dashboard_payload(
    baseline_jobs: List[Dict[str, Any]],
    baseline_skills: List[Dict[str, Any]],
    live_jobs: List[Dict[str, Any]],
    live_skills: List[Dict[str, Any]],
    live_metadata: Dict[str, Any],
    macro_records: List[Dict[str, Any]]
) -> None:
    """
    Constructs and writes dashboard/data.js containing both the verified baseline
    academic dataset and the source-retrieved live feed.
    """
    def serialize_val(v: Any) -> str:
        if v is None or v == "" or v == "NA" or v == "null":
            return "null"
        if isinstance(v, bool):
            return "true" if v else "false"
        if isinstance(v, (int, float)):
            return str(v)
        # Check numeric string
        if isinstance(v, str):
            if v.lower() == "true":
                return "true"
            if v.lower() == "false":
                return "false"
            try:
                num = float(v)
                if "." not in v:
                    return str(int(num))
                return str(num)
            except ValueError:
                pass
        # String escaping
        s = str(v).replace("\\", "\\\\").replace('"', '\\"').replace("\r", "").replace("\n", "\\n").replace("\t", "\\t")
        return f'"{s}"'

    def row_to_json(row: Dict[str, Any]) -> str:
        pairs = [f'"{k}": {serialize_val(v)}' for k, v in row.items()]
        return "{" + ", ".join(pairs) + "}"

    def list_to_json(rows: List[Dict[str, Any]]) -> str:
        if not rows:
            return "[]"
        items = [row_to_json(r) for r in rows]
        return "[\n    " + ",\n    ".join(items) + "\n  ]"

    payload = f"""// TechScape Dual-Track Analytical Data Bundle (Auto-generated)
// TRACK A: Verified Baseline Empirical Academic Corpus (n={len(baseline_jobs)})
// TRACK B: Source-Retrieved Periodic Live Feed (n={len(live_jobs)})

window.TECHSCAPE_DATA = {{
  // 1. Dual Track Datasets
  baseline: {{
    jobs: {list_to_json(baseline_jobs)},
    skills: {list_to_json(baseline_skills)},
    metadata: {{
      name: "Verified Real Sample",
      sample_size: {len(baseline_jobs)},
      skills_count: {len(baseline_skills)},
      collection_window: "Aug 10 - Aug 26, 2026",
      academic_status: "Frozen Empirical Corpus",
      provenance: "100% Traceable Sri Lankan IT Employers"
    }}
  }},

  live_feed: {{
    jobs: {list_to_json(live_jobs)},
    skills: {list_to_json(live_skills)},
    metadata: {json.dumps(live_metadata, indent=4)}
  }},

  // 2. Default View Pointers (Defaults to Baseline for Academic Reproducibility)
  jobs: {list_to_json(baseline_jobs)},
  skills: {list_to_json(baseline_skills)},

  // 3. Macroeconomic Longitudinal Series
  macro: {list_to_json(macro_records)}
}};
"""
    with open(DASHBOARD_DATA_JS, "w", encoding="utf-8") as f:
        f.write(payload)

    print(f"[EXPORT] Dashboard data bundle successfully generated at `{DASHBOARD_DATA_JS}`")


def run_live_update(
    sources: List[str] = ["topjobs", "itpro"],
    limit_per_source: int = 40,
    use_fixtures: bool = False
) -> Dict[str, Any]:
    """
    Main orchestration routine for source ingestion, validation, and dashboard export.
    """
    print("=" * 72)
    print("[INIT] TechScape: Source-Retrieved Live Feed Ingestion Pipeline")
    print(f"Timestamp: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Target Sources: {', '.join(sources)}")
    print("=" * 72)

    ensure_live_feed_directory()

    # 1. Ingest raw listings
    raw_listings = fetch_raw_listings(sources, limit_per_source, use_fixtures=use_fixtures)
    print(f"\n[INFO] Ingestion complete: {len(raw_listings)} total raw listings fetched.")

    # 2. Deduplicate
    deduped_raw = deduplicate_raw_records(raw_listings)
    print(f"[INFO] Deduplication complete: {len(deduped_raw)} unique records retained.")

    # 3. Parse and extract features strictly for IT sector roles
    parsed_jobs: List[Dict[str, Any]] = []
    parsed_skills: List[Dict[str, Any]] = []

    valid_idx = 1
    for raw_item in deduped_raw:
        job_t = raw_item.get("job_title", "")
        raw_t = raw_item.get("raw_text", "")
        if not is_strictly_it_job(job_t, raw_t):
            print(f"  [DISCARD NON-IT] Skipping non-IT vacancy: '{job_t}' ({raw_item.get('company')})")
            continue

        job_row, skill_rows = parse_and_normalize_record(raw_item, valid_idx)
        parsed_jobs.append(job_row)
        parsed_skills.extend(skill_rows)
        valid_idx += 1

    print(f"\n[INFO] Validated {len(parsed_jobs)} strictly IT sector jobs (discarded {len(deduped_raw) - len(parsed_jobs)} non-IT listings).")

    # Source breakdown
    source_counts: Dict[str, int] = {}
    for j in parsed_jobs:
        s = j.get("source", "Unknown")
        source_counts[s] = source_counts.get(s, 0) + 1

    retrieval_iso = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    metadata = {
        "retrieved_at": retrieval_iso,
        "total_retrieved": len(parsed_jobs),
        "skills_extracted": len(parsed_skills),
        "source_counts": source_counts,
        "sources_attempted": sources,
        "mode": "Offline Test Fixtures" if use_fixtures else "Periodic Public Web Retrieval",
        "disclaimer": "Source-Retrieved feed. Vacancies are subject to employer removal."
    }

    # 4. Save to data/live_feed/
    jobs_csv_path = os.path.join(LIVE_FEED_DIR, "jobs_live_feed.csv")
    skills_csv_path = os.path.join(LIVE_FEED_DIR, "job_skills_live_feed.csv")
    meta_json_path = os.path.join(LIVE_FEED_DIR, "live_feed_metadata.json")

    write_csv(jobs_csv_path, parsed_jobs)
    write_csv(skills_csv_path, parsed_skills)
    with open(meta_json_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    print(f"\n[SAVE] Saved {len(parsed_jobs)} live job records to `{jobs_csv_path}`")
    print(f"[SAVE] Saved {len(parsed_skills)} skill mappings to `{skills_csv_path}`")
    print(f"[SAVE] Saved metadata to `{meta_json_path}`")

    # 5. Read baseline dataset (never modified) and macro data
    baseline_jobs = read_csv_as_dicts(BASELINE_JOBS_CSV)
    baseline_skills = read_csv_as_dicts(BASELINE_SKILLS_CSV)
    macro_records = read_csv_as_dicts(MACRO_CSV)

    # 6. Export dashboard bundle
    export_unified_dashboard_payload(
        baseline_jobs=baseline_jobs,
        baseline_skills=baseline_skills,
        live_jobs=parsed_jobs,
        live_skills=parsed_skills,
        live_metadata=metadata,
        macro_records=macro_records
    )

    print("\n" + "=" * 72)
    print("[SUCCESS] Live Feed Update Completed Successfully!")
    print(f"Verified Baseline Corpus: {len(baseline_jobs)} jobs (Untouched & Frozen)")
    print(f"Source-Retrieved Live Feed: {len(parsed_jobs)} jobs across {len(source_counts)} sources")
    print("=" * 72)

    return metadata


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TechScape Source-Retrieved Live Feed Ingestion")
    parser.add_argument("--sources", type=str, default="topjobs,itpro", help="Comma-separated sources (topjobs,itpro)")
    parser.add_argument("--limit", type=int, default=40, help="Max listings to fetch per source")
    parser.add_argument("--offline-fixtures", action="store_true", help="Use offline test fixtures instead of live network")

    args = parser.parse_args()
    selected_sources = [s.strip().lower() for s in args.sources.split(",") if s.strip()]

    run_live_update(
        sources=selected_sources,
        limit_per_source=args.limit,
        use_fixtures=args.offline_fixtures
    )
