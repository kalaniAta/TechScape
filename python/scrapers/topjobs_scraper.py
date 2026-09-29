"""
TechScape: TopJobs Sri Lanka Ingestion Scraper
==============================================
Standard-library compliant scraper for retrieving live/periodic IT vacancies
from public category listings on TopJobs Sri Lanka (topjobs.lk).

Zero external dependencies: uses urllib.request and standard re / html parsing.
"""

import datetime
import html
import re
import ssl
import time
import urllib.request
from typing import Any, Dict, List


class TopJobsScraper:
    """
    Scraper for TopJobs Sri Lanka public vacancy listings.
    """

    BASE_URL = "https://www.topjobs.lk"
    CATEGORY_URL = "https://www.topjobs.lk/applicant/vacancybyfunctionalarea.jsp?FA=SDO"
    USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) TechScape-Analytics/1.0 (+https://github.com/kalaniAta/TechScape)"

    # Strict IT-only domain keywords and regex patterns
    IT_POSITIVE_PATTERNS = [
        r"\bsoftware\b", r"\bdeveloper\b", r"\bprogrammer\b", r"\bsqa\b", r"\bqa\s+eng",
        r"\bqa\s+auto", r"\btest\s+auto", r"\bautomation\s+eng", r"\bsdet\b", r"\bsoftware\s+test",
        r"\bquality\s+assurance\b", r"\bqa\s+lead\b", r"\bqa\s+analyst\b", r"\bdevops\b", r"\bcloud\b",
        r"\bsite\s+reliability\b", r"\bsre\b", r"\bplatform\s+engineer\b", r"\bdata\s+scientist\b",
        r"\bdata\s+engineer\b", r"\bdata\s+analyst\b", r"\bai\s+engineer\b", r"\bmachine\s+learning\b",
        r"\bcyber\s+security\b", r"\binformation\s+security\b", r"\binfosec\b", r"\bsoc\s+analyst\b",
        r"\bpenetration\s+test", r"\bui\s*/\s*ux\b", r"\bux\b", r"\bproduct\s+designer\b",
        r"\bsystem\s+admin", r"\bnetwork\s+eng", r"\bit\s+support\b", r"\bhelpdesk\b",
        r"\bfrontend\b", r"\bfront-end\b", r"\bbackend\b", r"\bback-end\b", r"\bfull\s*stack\b",
        r"\bsoftware\s+architect\b", r"\bsolutions\s+architect\b", r"\btech\s+lead\b", r"\bscrum\s+master\b",
        r"\bproduct\s+owner\b", r"\bproduct\s+manager\b", r"\bproject\s+manager\b", r"\bengineering\s+manager\b",
        r"\bprogram\s+manager\b", r"\bdelivery\s+manager\b", r"\bit\s+manager\b", r"\bdevelopment\s+manager\b",
        r"\bteam\s+lead\b", r"\brelease\s+manager\b", r"\boperations\s+manager\b", r"\bhead\s+of\b",
        r"\bcto\b", r"\bcio\b", r"\bpmo\b", r"\bbusiness\s+analyst\b", r"\bdatabase\s+admin", r"\bmobile\s+app\b",
        r"\bandroid\b", r"\bios\s+dev", r"\bflutter\b", r"\breact\b", r"\bpython\b", r"\bjava\b",
        r"\b\.net\b", r"\bgolang\b", r"\bdevsecops\b", r"\bnoc\s+engineer\b", r"\bagile\s+coach\b"
    ]

    # Explicit exclusions for non-IT vacancies
    NON_IT_EXCLUSIONS = [
        r"\bfood\b", r"\bqhse\b", r"\biso\s*\d+", r"\bauditor\b", r"\baudit\b", r"\baccountant\b",
        r"\baccounting\b", r"\bcredit\s+controller\b", r"\bcustomer\s+care\b", r"\bcustomer\s+service\b",
        r"\bcall\s+center\b", r"\btele\s*sales\b", r"\bsupply\s+chain\b", r"\bprocurement\b",
        r"\breceptionist\b", r"\bnurse\b", r"\bmedical\b", r"\bteacher\b", r"\blecturer\b",
        r"\bstudent\s+enrollment\b", r"\badmissions\b", r"\bcivil\s+eng", r"\bmechanical\s+eng",
        r"\belectrical\s+eng", r"\bdraftsman\b", r"\bquantity\s+surveyor\b", r"\bdriver\b",
        r"\bcashier\b", r"\bchef\b", r"\bcook\b", r"\bhotel\b", r"\bhousekeeping\b",
        r"\bseo\s+blog\s+writer\b", r"\bblog\s+writer\b", r"\br&d\b", r"\bconstruction\b",
        r"\bmanufacturing\b", r"\bapparel\b", r"\bgarment\b", r"\btextile\b", r"\bchemical\b",
        r"\bcosmetic\b", r"\bfinance\s+director\b", r"\bgroup\s+finance\b"
    ]

    def __init__(self, request_delay_sec: float = 1.5):
        self.request_delay_sec = request_delay_sec
        self._ssl_ctx = ssl.create_default_context()
        self._ssl_ctx.check_hostname = False
        self._ssl_ctx.verify_mode = ssl.CERT_NONE

    def parse_html_listings(self, html_content: str, max_records: int = 50, filter_it_only: bool = True) -> List[Dict[str, Any]]:
        """
        Parses TopJobs HTML content and returns structured raw job dictionaries.
        Supports both span and input hidden field conventions across TopJobs versions.
        """
        records: List[Dict[str, Any]] = []
        if not html_content:
            return records

        tr_pattern = re.compile(r'<tr[^>]*id=["\']?tr\d+["\']?[^>]*>(.*?)</tr>', re.DOTALL | re.IGNORECASE)
        rows = tr_pattern.findall(html_content)

        if not rows:
            table_match = re.search(r'<table[^>]*id=["\']?table1["\']?[^>]*>(.*?)</table>', html_content, re.DOTALL | re.IGNORECASE)
            if table_match:
                rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table_match.group(1), re.DOTALL | re.IGNORECASE)

        for row in rows:
            if len(records) >= max_records:
                break

            # 1. Extract hidden codes (Supports: <span id="hdnJC0" ...>VALUE</span> and <input id="hdnJC0" value="VALUE">)
            jc_match = re.search(r'id=["\']?hdnJC\d+["\']?[^>]*>([A-Za-z0-9_]+)<', row, re.IGNORECASE) or \
                       re.search(r'id=["\']?hdnJC\d+["\']?[^>]*value=["\']?([A-Za-z0-9_]+)["\']?', row, re.IGNORECASE)

            ec_match = re.search(r'id=["\']?hdnEC\d+["\']?[^>]*>([A-Za-z0-9_]+)<', row, re.IGNORECASE) or \
                       re.search(r'id=["\']?hdnEC\d+["\']?[^>]*value=["\']?([A-Za-z0-9_]+)["\']?', row, re.IGNORECASE)

            ac_match = re.search(r'id=["\']?hdnAC\d+["\']?[^>]*>([A-Za-z0-9_]+)<', row, re.IGNORECASE) or \
                       re.search(r'id=["\']?hdnAC\d+["\']?[^>]*value=["\']?([A-Za-z0-9_]+)["\']?', row, re.IGNORECASE)

            jc = jc_match.group(1) if jc_match else None
            ec = ec_match.group(1) if ec_match else "DEFZZZ"
            ac = ac_match.group(1) if ac_match else "DEFZZZ"

            if not jc:
                continue

            # 2. Extract Title (usually in <h2>, <a>, or table cell)
            title = None
            h2_match = re.search(r'<h2[^>]*>(.*?)</h2>', row, re.DOTALL | re.IGNORECASE)
            if h2_match:
                title = re.sub(r'<[^>]+>', ' ', h2_match.group(1)).strip()
            if not title:
                a_match = re.search(r'<a[^>]*>(.*?)</a>', row, re.DOTALL | re.IGNORECASE)
                if a_match:
                    title = re.sub(r'<[^>]+>', ' ', a_match.group(1)).strip()

            if not title:
                continue
            title = html.unescape(' '.join(title.split()))

            # Filter strictly for IT relevance
            if filter_it_only:
                t_low = title.lower()
                # 1. Check non-IT exclusions
                if any(re.search(pat, t_low) for pat in self.NON_IT_EXCLUSIONS):
                    continue
                # 2. Check positive IT patterns
                if not any(re.search(pat, t_low) for pat in self.IT_POSITIVE_PATTERNS):
                    continue

            # 3. Extract Company Name (usually in <h1>)
            company = "Sri Lankan IT Employer"
            h1_match = re.search(r'<h1[^>]*>(.*?)</h1>', row, re.DOTALL | re.IGNORECASE)
            if h1_match:
                company = re.sub(r'<[^>]+>', ' ', h1_match.group(1)).strip()
                company = html.unescape(' '.join(company.split()))

            # 4. Extract Location
            location = "Colombo, Sri Lanka"
            # Location is typically the last or penultimate cell with text
            loc_cells = re.findall(r'<td[^>]*nowrap[^>]*>(.*?)</td>', row, re.DOTALL | re.IGNORECASE)
            for lc in loc_cells:
                clean_lc = html.unescape(' '.join(re.sub(r'<[^>]+>', ' ', lc).split()))
                if clean_lc and not any(month in clean_lc for month in ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]):
                    location = f"{clean_lc}, Sri Lanka"

            # 5. Extract Posting Date
            date_posted = datetime.date.today().isoformat()
            date_match = re.search(r'([A-Za-z]{3}\s+[A-Za-z]{3}\s+\d{1,2}\s+\d{4})', row)
            if date_match:
                raw_d = date_match.group(1)
                try:
                    dt = datetime.datetime.strptime(raw_d, "%a %b %d %Y")
                    date_posted = dt.date().isoformat()
                except Exception:
                    pass

            source_url = f"{self.BASE_URL}/employer/JobAdvertismentServlet?ac={ac}&jc={jc}&ec={ec}&pg=applicant/vacancybyfunctionalarea.jsp"
            source_job_id = f"TJ-{jc}"

            records.append({
                "source": "TopJobs_LK",
                "source_job_id": source_job_id,
                "source_url": source_url,
                "job_title": title,
                "company": company,
                "location": location,
                "date_posted": date_posted,
                "raw_text": f"{title} at {company}. Location: {location}. TopJobs Reference: {source_job_id}",
                "retrieved_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
            })

        return records

    def fetch_live_vacancies(self, limit: int = 30, timeout: int = 30) -> List[Dict[str, Any]]:
        """
        Fetches live IT vacancies from TopJobs LK with respectful rate-limiting and retry.
        """
        req = urllib.request.Request(
            self.CATEGORY_URL,
            headers={"User-Agent": self.USER_AGENT, "Accept": "text/html"}
        )
        for attempt in range(2):
            try:
                time.sleep(self.request_delay_sec)
                with urllib.request.urlopen(req, context=self._ssl_ctx, timeout=timeout) as resp:
                    html_text = resp.read().decode('utf-8', errors='ignore')
                    return self.parse_html_listings(html_text, max_records=limit, filter_it_only=True)
            except Exception as e:
                if attempt == 0:
                    print(f"[TopJobsScraper] Notice: Retrying live fetch ({e})...")
                    time.sleep(2)
                else:
                    print(f"[TopJobsScraper] Warning: Unable to fetch live listings ({e}).")
        return []
