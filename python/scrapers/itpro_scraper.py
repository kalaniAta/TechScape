"""
TechScape: ITPro Sri Lanka Ingestion Scraper
============================================
Standard-library compliant scraper for retrieving live/periodic IT vacancies
from public job listings on ITPro Sri Lanka (itpro.lk).

Zero external dependencies: uses urllib.request and standard re / html parsing.
"""

import datetime
import html
import re
import ssl
import time
import urllib.request
from typing import Any, Dict, List, Optional


class ITProScraper:
    """
    Scraper for ITPro Sri Lanka public vacancy listings.
    """

    BASE_URL = "https://itpro.lk"
    JOBS_URL = "https://itpro.lk/jobs/"
    USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) TechScape-Analytics/1.0 (+https://github.com/kalaniAta/TechScape)"

    # Strict IT-only domain keywords and regex patterns
    IT_POSITIVE_PATTERNS = [
        r"\bsoftware\b", r"\bdeveloper\b", r"\bprogrammer\b", r"\bqa\b", r"\bquality\s+assurance\b",
        r"\btest\s+automation\b", r"\bautomation\s+engineer\b", r"\bsdet\b", r"\bdevops\b", r"\bcloud\b",
        r"\bsite\s+reliability\b", r"\bsre\b", r"\bplatform\s+engineer\b", r"\bdata\s+scientist\b",
        r"\bdata\s+engineer\b", r"\bdata\s+analyst\b", r"\bai\s+engineer\b", r"\bmachine\s+learning\b",
        r"\bcyber\s+security\b", r"\binformation\s+security\b", r"\binfosec\b", r"\bsoc\s+analyst\b",
        r"\bpenetration\s+test", r"\bui\s*/\s*ux\b", r"\bux\b", r"\bproduct\s+designer\b",
        r"\bsystem\s+admin", r"\bnetwork\s+eng", r"\bit\s+support\b", r"\bhelpdesk\b",
        r"\bfrontend\b", r"\bfront-end\b", r"\bbackend\b", r"\bback-end\b", r"\bfull\s*stack\b",
        r"\barchitect\b", r"\btech\s+lead\b", r"\bscrum\s+master\b", r"\bproduct\s+owner\b",
        r"\bproduct\s+manager\b", r"\bproject\s+manager\b", r"\bengineering\s+manager\b",
        r"\bprogram\s+manager\b", r"\bdelivery\s+manager\b", r"\bit\s+manager\b", r"\bdevelopment\s+manager\b",
        r"\bteam\s+lead\b", r"\brelease\s+manager\b", r"\boperations\s+manager\b", r"\bhead\s+of\b",
        r"\bcto\b", r"\bcio\b", r"\bpmo\b", r"\bbusiness\s+analyst\b", r"\bdatabase\s+admin", r"\bmobile\s+app\b",
        r"\bandroid\b", r"\bios\s+dev", r"\bflutter\b", r"\breact\b", r"\bpython\b", r"\bjava\b",
        r"\b\.net\b", r"\bgolang\b", r"\bdevsecops\b", r"\bnoc\s+engineer\b", r"\bagile\s+coach\b",
        r"\bcreative\s+designer\b"
    ]

    NON_IT_EXCLUSIONS = [
        r"\bseo\s+blog\s+writer\b", r"\bblog\s+writer\b", r"\bcontent\s+writer\b",
        r"\baccountant\b", r"\bcredit\s+controller\b", r"\bcustomer\s+care\b",
        r"\btele\s*sales\b", r"\breceptionist\b", r"\bnurse\b"
    ]

    def __init__(self, request_delay_sec: float = 1.5):
        self.request_delay_sec = request_delay_sec
        self._ssl_ctx = ssl.create_default_context()
        self._ssl_ctx.check_hostname = False
        self._ssl_ctx.verify_mode = ssl.CERT_NONE

    def parse_listing_urls(self, html_content: str, max_links: int = 30) -> List[str]:
        """
        Extracts individual job post URLs from an ITPro listing page HTML.
        """
        if not html_content:
            return []
        matches = re.findall(r'href=["\'](https://itpro\.lk/job/[^"\']+)["\']', html_content)
        # Deduplicate while preserving order
        seen = set()
        unique_urls = []
        for u in matches:
            if u not in seen:
                seen.add(u)
                unique_urls.append(u)
                if len(unique_urls) >= max_links:
                    break
        return unique_urls

    def parse_job_html(self, html_content: str, source_url: str) -> Optional[Dict[str, Any]]:
        """
        Parses a single ITPro job page HTML into a structured raw vacancy dictionary.
        """
        if not html_content:
            return None

        # Extract title tag: e.g. <title>Associate Frontend Engineer at Kangaro Tech - Colombo, Sri Lanka | ITPro.lk</title>
        title_match = re.search(r'<title>(.*?)</title>', html_content, re.IGNORECASE)
        raw_title_tag = title_match.group(1) if title_match else ""

        title = "IT Professional"
        company = "Sri Lankan IT Firm"
        location = "Colombo, Sri Lanka"

        if " at " in raw_title_tag and "|" in raw_title_tag:
            # Format: "<Title> at <Company> - <Location> | ITPro.lk"
            left_part = raw_title_tag.split("|")[0].strip()
            parts = left_part.split(" at ")
            title = parts[0].strip()
            rest = parts[1] if len(parts) > 1 else ""
            if " - " in rest:
                c_parts = rest.split(" - ")
                company = c_parts[0].strip()
                location = c_parts[1].strip()
            else:
                company = rest.strip()
        else:
            # Fallback to h1 tag
            h1_match = re.search(r'<h1[^>]*>(.*?)</h1>', html_content, re.IGNORECASE)
            if h1_match:
                title = re.sub(r'<[^>]+>', ' ', h1_match.group(1)).strip()

        # Extract meta description for raw snippet text
        meta_desc = ""
        meta_match = re.search(r'<meta\s+name=["\']description["\']\s+content=["\'](.*?)["\']', html_content, re.IGNORECASE)
        if meta_match:
            meta_desc = html.unescape(meta_match.group(1)).strip()

        # Extract job ID from URL: e.g. /job/14876/...
        id_match = re.search(r'/job/(\d+)/', source_url)
        job_code = id_match.group(1) if id_match else str(abs(hash(source_url)))[:8]
        source_job_id = f"ITPRO-{job_code}"

        clean_title = html.unescape(title)
        t_low = clean_title.lower()
        if any(re.search(pat, t_low) for pat in self.NON_IT_EXCLUSIONS):
            return None
        if not any(re.search(pat, t_low) for pat in self.IT_POSITIVE_PATTERNS):
            return None

        return {
            "source": "ITPro_LK",
            "source_job_id": source_job_id,
            "source_url": source_url,
            "job_title": clean_title,
            "company": html.unescape(company),
            "location": html.unescape(location),
            "date_posted": datetime.date.today().isoformat(),
            "raw_text": meta_desc or f"{clean_title} at {company}. {location}",
            "retrieved_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
        }

    def fetch_live_vacancies(self, limit: int = 15, timeout: int = 12) -> List[Dict[str, Any]]:
        """
        Fetches live IT vacancies from ITPro LK with rate-limiting between detail calls.
        """
        req = urllib.request.Request(
            self.JOBS_URL,
            headers={"User-Agent": self.USER_AGENT, "Accept": "text/html"}
        )
        job_urls: List[str] = []
        try:
            time.sleep(self.request_delay_sec)
            with urllib.request.urlopen(req, context=self._ssl_ctx, timeout=timeout) as resp:
                html_text = resp.read().decode('utf-8', errors='ignore')
                job_urls = self.parse_listing_urls(html_text, max_links=limit)
        except Exception as e:
            print(f"[ITProScraper] Warning: Unable to fetch listing index ({e}).")
            return []

        records: List[Dict[str, Any]] = []
        for url in job_urls:
            try:
                time.sleep(self.request_delay_sec)
                job_req = urllib.request.Request(url, headers={"User-Agent": self.USER_AGENT})
                with urllib.request.urlopen(job_req, context=self._ssl_ctx, timeout=timeout) as resp:
                    page_html = resp.read().decode('utf-8', errors='ignore')
                    rec = self.parse_job_html(page_html, url)
                    if rec:
                        records.append(rec)
            except Exception as e:
                print(f"[ITProScraper] Skip {url}: {e}")

        return records
