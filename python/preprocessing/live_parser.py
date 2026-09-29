"""
TechScape: Conservative Feature Extraction & NLP Regex Parser
============================================================
Parses raw live/source-retrieved job records into normalized schemas with
conservative field extraction (no hallucinated / invented values).

Standard Library Only (re, json, typing).
"""

import re
from typing import Any, Dict, List, Optional, Tuple

# Standardized Career Categories
# Standardized Career Categories
CAREER_CATEGORIES = [
    ("Management & Business Analysis", [
        # Explicit Management / Leadership Titles
        r"\b(?:software\s+)?engineering\s+manag",
        r"\bdevelopment\s+manag",
        r"\bdev\s+manag",
        r"\btech(?:nical)?\s+manag",
        r"\bit\s+manag",
        r"\btechnology\s+manag",
        r"\bproduct\s+manag",
        r"\bproject\s+manag",
        r"\bprogram\s+manag",
        r"\bdelivery\s+manag",
        r"\bservice\s+delivery",
        r"\brelease\s+manag",
        r"\boperations?\s+manag",
        r"\bgeneral\s+manag",
        r"\bqa\s+manag",
        r"\btest\s+manag",
        # Product & Agile Roles
        r"\bproduct\s+owner\b",
        r"\bproduct\s+lead\b",
        r"\bscrum\s+master\b",
        r"\bagile\s+coach\b",
        r"\bagile\s+delivery\b",
        r"\bteam\s+lead\b",
        r"\btech(?:nical)?\s+lead\b",
        r"\bengineering\s+lead\b",
        r"\bdelivery\s+lead\b",
        r"\blead\s+developer\b",
        # Business & Systems Analysis
        r"\bbusiness\s+analyst\b",
        r"\bbusiness\s+systems?\s+analyst\b",
        r"\bsystems?\s+analyst\b",
        r"\bit\s+analyst\b",
        r"\btechnical\s+analyst\b",
        r"\bba\b",
        r"\bit\s+consultant\b",
        r"\bbusiness\s+consultant\b",
        r"\bpmo\b",
        # Executive / Department Heads
        r"\bhead\s+of\s+(?:engineering|technology|it|software|development|product|qa|infrastructure|data)\b",
        r"\bdirector\s+of\s+(?:engineering|technology|it|software|development|product|qa|infrastructure)\b",
        r"\bvp\s+of\s+(?:engineering|technology|it|software|product)\b",
        r"\bvice\s+president\b",
        r"\bchief\s+technology\s+officer\b",
        r"\bchief\s+information\s+officer\b",
        r"\bcto\b",
        r"\bcio\b"
    ]),
    ("Data & AI / ML", [
        r"data\s*scien", r"machine\s*learn", r"\bai\s+eng", r"\bai\s+solut", r"\bai\s+dev", r"\bai\s+research",
        r"\bnlp\b", r"\bllm\b", r"data\s*eng", r"analytics\s*eng", r"big\s*data", r"deep\s*learn",
        r"business\s*intellig", r"\bbi\s+dev", r"\bbi\s+analyst", r"data\s*analyst", r"computer\s*vision",
        r"mlops", r"pyspark", r"databricks", r"snowflake\b", r"genai", r"generative\s*ai"
    ]),
    ("Cloud & DevOps", [
        r"devops", r"cloud\b", r"site\s*reliab", r"\bsre\b", r"platform\s*eng", r"infrastructure\s*eng",
        r"cloud\s*eng", r"cloud\s*architect", r"kubernetes", r"\bk8s\b", r"\baws\b", r"\bazure\b",
        r"terraform", r"ci[/-]?cd", r"sysops", r"devsecops", r"cloud\s*infra"
    ]),
    ("QA & Test Automation", [
        r"\bsqa\b", r"\bqa\s+eng", r"\bqa\s+auto", r"\btest\s+auto", r"\bautomation\s+eng", r"\bsdet\b",
        r"\bsoftware\s+test", r"\bsoftware\s+quality", r"\bquality\s+assurance", r"\bqa\s+lead\b",
        r"\bqa\s+analyst\b", r"\bqa\s+intern\b", r"\bqa\s+associate\b", r"\bqa\s+specialist\b",
        r"\bperformance\s+test", r"\bmanual\s+test", r"\btest\s+eng", r"\btester\b",
        r"selenium", r"cypress", r"playwright", r"jmeter", r"restassured"
    ]),
    ("Cyber Security", [
        r"secur", r"cyber", r"\bsoc\b", r"\bsiem\b", r"penetrat", r"infosec", r"vulnerability",
        r"ethical\s*hack", r"\bgrc\b", r"iso\s*27001", r"security\s*eng", r"security\s*analyst",
        r"security\s*consultant", r"threat\s*intel"
    ]),
    ("UI/UX & Product Design", [
        r"ui\s*/\s*ux", r"\bux\b", r"\bui\b", r"product\s*design", r"user\s*exper", r"user\s*inter",
        r"figma", r"visual\s*design", r"web\s*design", r"interaction\s*design", r"ux\s*research"
    ]),
    ("IT Systems & Infrastructure", [
        r"system\s*admin", r"systems?\s*eng", r"network\s*eng", r"network\s*admin", r"it\s*support",
        r"helpdesk", r"help\s*desk", r"desktop\s*support", r"infrastructure\s*admin", r"system\s*support",
        r"linux\s*admin", r"\bnoc\b", r"network\s*operat", r"active\s*directory", r"sysadmin"
    ]),
    ("Software Engineering", [
        r"software\s*eng", r"software\s*dev", r"full[- ]?stack", r"frontend", r"front[- ]?end",
        r"backend", r"back[- ]?end", r"mobile\s*dev", r"mobile\s*app", r"android", r"\bios\b",
        r"flutter", r"react\b", r"java\b", r"\.net\b", r"python\b", r"golang\b", r"programmer",
        r"web\s*dev", r"application\s*eng", r"application\s*dev", r"software\s*architect",
        r"solutions?\s*architect", r"software", r"developer", r"engineer"
    ])
]

# Standardized Skill Taxonomy
SKILL_TAXONOMY = {
    "Programming Languages": [
        "Python", "Java", "C#", "TypeScript", "JavaScript", "Golang", "C++", "PHP", "Kotlin", "Swift", "Dart", "Ruby", "Rust", "Scala"
    ],
    "Web Frameworks": [
        "React", "Node.js", "Angular", "Spring Boot", ".NET Core", "Django", "FastAPI", "Vue.js", "Express.js", "Flask", "Next.js", "ASP.NET", "Laravel"
    ],
    "Cloud & DevOps": [
        "AWS", "Azure", "GCP", "Docker", "Kubernetes", "Terraform", "CI/CD", "Linux", "Git", "GitHub Actions", "Jenkins", "Ansible", "Prometheus", "Grafana"
    ],
    "Databases": [
        "SQL", "PostgreSQL", "MySQL", "MongoDB", "Redis", "Oracle", "Elasticsearch", "SQL Server", "DynamoDB", "Snowflake", "Cassandra"
    ],
    "QA & Testing": [
        "Selenium", "Cypress", "Playwright", "Postman", "JUnit", "TestNG", "JIRA", "JMeter", "RestAssured", "Appium"
    ],
    "Data & AI": [
        "Machine Learning", "PyTorch", "TensorFlow", "Pandas", "Scikit-Learn", "NLP", "LLM", "Power BI", "Tableau", "Apache Spark", "Databricks"
    ],
    "Design & Management": [
        "Figma", "UI/UX", "Agile", "Scrum", "REST API", "Microservices", "GraphQL"
    ]
}


def is_strictly_it_job(title: str, text: str = "") -> bool:
    """
    Validates whether a job posting strictly belongs to the Information Technology (IT) sector.
    Excludes non-IT vacancies (e.g. food testing, customer care, auditing, accounting, civil/mechanical engineering).
    """
    combined = f"{title} {text}".lower()

    # Non-IT exclusion patterns
    non_it_patterns = [
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
    if any(re.search(pat, combined) for pat in non_it_patterns):
        return False

    # Must match at least one IT career track regex pattern
    for cat_name, patterns in CAREER_CATEGORIES:
        for p in patterns:
            if re.search(p, combined):
                return True
    return False


def classify_career_category(title: str, text: str = "") -> str:
    """
    Conservatively classifies career track using a two-phase hierarchical strategy:
    Phase 1: Title-first matching against canonical IT categories (authoritative).
    Phase 2: Combined snippet / text matching if title does not yield a match.
    """
    title_clean = title.strip().lower()
    text_clean = text.strip().lower()

    # Phase 1: High-precision Title match (Management & specialist tracks evaluated first)
    for cat_name, patterns in CAREER_CATEGORIES:
        for p in patterns:
            if re.search(p, title_clean):
                return cat_name

    # Phase 2: Context / Description match
    combined = f"{title_clean} {text_clean}".strip()
    if combined:
        for cat_name, patterns in CAREER_CATEGORIES:
            for p in patterns:
                if re.search(p, combined):
                    return cat_name

    return "Software Engineering"  # Default fallback


def classify_seniority(title: str, text: str, exp_min: Optional[float]) -> str:
    """Infers seniority tier conservatively."""
    comb = f"{title} {text}".lower()
    if any(k in comb for k in ["intern", "trainee", "undergraduate", "apprentice"]):
        return "Intern"
    if any(k in comb for k in ["lead", "architect", "principal", "manager", "head of", "director", "chief"]):
        return "Lead"
    if any(k in comb for k in ["senior", "sr.", "sr "]) or (exp_min is not None and exp_min >= 5.0):
        return "Senior"
    if any(k in comb for k in ["junior", "jr.", "associate", "entry", "graduate"]) or (exp_min is not None and exp_min <= 1.0):
        return "Junior"
    return "Mid"


def classify_work_mode(text: str) -> str:
    """Infers work mode arrangement."""
    t = text.lower()
    if "remote" in t or "work from home" in t or "wfh" in t:
        return "Remote"
    if "hybrid" in t or "flexible" in t:
        return "Hybrid"
    if "on-site" in t or "onsite" in t or "in office" in t:
        return "On-site"
    return "Hybrid"  # Market standard default


def extract_experience_bounds(text: str) -> Tuple[Optional[float], Optional[float]]:
    """
    Extracts experience minimum and maximum years using robust regex.
    Returns (min_exp, max_exp).
    """
    t = text.lower()

    # Pattern: 3-5 years / 2 to 4 years
    range_match = re.search(r'(\d+)\s*(?:-|to)\s*(\d+)\s*\+?\s*(?:years?|yrs?)', t)
    if range_match:
        try:
            return float(range_match.group(1)), float(range_match.group(2))
        except ValueError:
            pass

    # Pattern: 5+ years / 3+ yrs
    plus_match = re.search(r'(\d+)\s*\+\s*(?:years?|yrs?)', t)
    if plus_match:
        try:
            return float(plus_match.group(1)), None
        except ValueError:
            pass

    # Pattern: minimum 2 years / at least 3 yrs
    min_match = re.search(r'(?:minimum|min|at least)\s*(\d+)\s*(?:years?|yrs?)', t)
    if min_match:
        try:
            return float(min_match.group(1)), None
        except ValueError:
            pass

    # Pattern: 1 year experience
    single_match = re.search(r'(\d+)\s+(?:years?|yrs?)\s+(?:of\s+)?experience', t)
    if single_match:
        try:
            return float(single_match.group(1)), None
        except ValueError:
            pass

    return None, None


def extract_salary_bounds(text: str) -> Tuple[Optional[float], Optional[float], Optional[str], Optional[str]]:
    """
    Extracts salary min, max, currency, and raw string.
    """
    # LKR pattern: LKR 250,000 - 400,000 / Rs. 150,000 - 250,000
    lkr_match = re.search(r'(?:lkr|rs\.?)\s*([\d,]+)\s*(?:-|to)\s*([\d,]+)', text, re.IGNORECASE)
    if lkr_match:
        try:
            s_min = float(lkr_match.group(1).replace(",", ""))
            s_max = float(lkr_match.group(2).replace(",", ""))
            raw = f"LKR {int(s_min):,} - {int(s_max):,}"
            return s_min, s_max, "LKR", raw
        except ValueError:
            pass

    # USD pattern: USD 800 - 1500 / $1,000 - $2,000
    usd_match = re.search(r'(?:usd|\$)\s*([\d,]+)\s*(?:-|to)\s*(?:usd|\$)?\s*([\d,]+)', text, re.IGNORECASE)
    if usd_match:
        try:
            s_min = float(usd_match.group(1).replace(",", ""))
            s_max = float(usd_match.group(2).replace(",", ""))
            raw = f"USD {int(s_min):,} - {int(s_max):,}"
            return s_min, s_max, "USD", raw
        except ValueError:
            pass

    # LKR single amount (e.g. Allowance LKR 50,000)
    single_lkr = re.search(r'(?:allowance|stipend|salary)\s*(?:of)?\s*(?:lkr|rs\.?)\s*([\d,]+)', text, re.IGNORECASE)
    if single_lkr:
        try:
            val = float(single_lkr.group(1).replace(",", ""))
            return val, val, "LKR", f"LKR {int(val):,}"
        except ValueError:
            pass

    return None, None, None, None


def extract_skills_from_text(text: str) -> List[Tuple[str, str]]:
    """
    Identifies technical skills mentioned in the job text.
    Returns list of (skill_name, skill_category) tuples.
    """
    found = []
    text_lower = f" {text.lower()} "

    for category, skill_list in SKILL_TAXONOMY.items():
        for skill in skill_list:
            # Word boundary regex matching
            escaped = re.escape(skill.lower())
            if skill.lower() in [".net core", "asp.net", "c#", "c++", "node.js"]:
                pattern = r'(?:\s|[^\w]|^)' + escaped + r'(?:\s|[^\w]|$)'
            else:
                pattern = r'\b' + escaped + r'\b'

            if re.search(pattern, text_lower):
                found.append((skill, category))

    # Deduplicate by skill name
    seen = set()
    unique = []
    for s_name, s_cat in found:
        if s_name not in seen:
            seen.add(s_name)
            unique.append((s_name, s_cat))

    return unique


def parse_and_normalize_record(raw_record: Dict[str, Any], record_idx: int) -> Tuple[Dict[str, Any], List[Dict[str, Any]]]:
    """
    Transforms a single raw ingested job dictionary into standardized normalized schemas:
    1. Normalized Job Row
    2. List of Skill Rows
    """
    job_id = f"LIVE_{record_idx:05d}"
    title = raw_record.get("job_title", "Software Engineer").strip()
    company = raw_record.get("company", "Sri Lankan Tech Employer").strip()
    location = raw_record.get("location", "Colombo, Sri Lanka").strip()
    source = raw_record.get("source", "TopJobs_LK")
    source_url = raw_record.get("source_url", "https://www.topjobs.lk")
    source_job_id = raw_record.get("source_job_id", job_id)
    date_posted = raw_record.get("date_posted", "2026-08-28")
    raw_text = raw_record.get("raw_text", title)
    retrieved_at = raw_record.get("retrieved_at", "")

    # Feature engineering
    exp_min, exp_max = extract_experience_bounds(raw_text)
    salary_min, salary_max, currency, salary_raw = extract_salary_bounds(raw_text)
    career_cat = classify_career_category(title, raw_text)
    seniority = classify_seniority(title, raw_text, exp_min)
    work_mode = classify_work_mode(raw_text)
    skills = extract_skills_from_text(f"{title} {raw_text}")

    is_entry = (seniority in ["Intern", "Junior"]) or (exp_min is not None and exp_min <= 1.0)
    salary_mid = ((salary_min + salary_max) / 2.0) if (salary_min and salary_max) else salary_min

    # Date quarter / year calculations
    try:
        parts = date_posted.split("-")
        p_year = int(parts[0])
        p_month = int(parts[1])
        p_quarter = f"Q{(p_month - 1) // 3 + 1}"
        p_year_quarter = f"{p_year}-{p_quarter}"
        p_year_month = f"{p_year}-{parts[1]}"
    except Exception:
        p_year = 2026
        p_month = 8
        p_quarter = "Q3"
        p_year_quarter = "2026-Q3"
        p_year_month = "2026-08"

    skill_names = [s[0] for s in skills]
    skill_names_concat = "; ".join(skill_names) if skill_names else "General IT Stack"

    job_row = {
        "job_id": job_id,
        "source": source,
        "source_url": source_url,
        "collection_date": date_posted,
        "source_job_id": source_job_id,
        "date_posted": date_posted,
        "original_title": title,
        "job_title": title,
        "career_category": career_cat,
        "seniority_level": seniority,
        "company": company,
        "location": location,
        "work_mode": work_mode,
        "employment_type": "Full-time" if seniority != "Intern" else "Internship",
        "original_experience": f"{int(exp_min)}+ years" if exp_min else "Not Stated",
        "experience_min": exp_min if exp_min is not None else "",
        "experience_max": exp_max if exp_max is not None else "",
        "original_salary": salary_raw if salary_raw else "Negotiable",
        "salary_min": salary_min if salary_min is not None else "",
        "salary_max": salary_max if salary_max is not None else "",
        "currency": currency if currency else "",
        "is_synthetic": False,
        "posting_year": p_year,
        "posting_month": p_month,
        "posting_quarter": p_quarter,
        "posting_year_quarter": p_year_quarter,
        "posting_year_month": p_year_month,
        "is_entry_level": is_entry,
        "salary_disclosed": salary_min is not None,
        "salary_midpoint": salary_mid if salary_mid is not None else "",
        "skill_count": len(skills),
        "skill_names_concat": skill_names_concat,
        "retrieved_at": retrieved_at
    }

    skill_rows = []
    for s_idx, (s_name, s_cat) in enumerate(skills, 1):
        skill_rows.append({
            "skill_id": f"{job_id}_SKILL_{s_idx:02d}",
            "job_id": job_id,
            "skill_name": s_name,
            "skill_category": s_cat,
            "is_standardized": True
        })

    return job_row, skill_rows
