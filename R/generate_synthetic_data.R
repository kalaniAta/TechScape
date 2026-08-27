# ==============================================================================
# TechScape: Synthetic Data Generator (Development & Pipeline Testing Asset)
# ==============================================================================
# WARNING: This script generates STRUCTURAL SYNTHETIC DATA strictly for testing
# the R data cleaning, validation, transformation, and visualization pipelines.
#
# METHODOLOGICAL RULE:
# Synthetic observations and generated historical distributions are development
# assumptions only and MUST NEVER BE INTERPRETED OR CITED as empirical evidence
# of actual Sri Lankan IT labour market trends.
# ==============================================================================

generate_synthetic_dataset <- function(
    n_records = 300,
    seed = 42,
    output_jobs_path = "data/synthetic/jobs_synthetic_dev.csv",
    output_skills_path = "data/synthetic/job_skills_synthetic_dev.csv"
) {
  set.seed(seed)
  message(sprintf("Generating %d synthetic job records with deterministic seed %d...", n_records, seed))
  
  # Ensure output directory exists
  dir.create(dirname(output_jobs_path), recursive = TRUE, showWarnings = FALSE)
  dir.create(dirname(output_skills_path), recursive = TRUE, showWarnings = FALSE)
  
  # Career category definitions and realistic title aliases
  categories <- list(
    "Software Engineering" = list(
      standard_titles = c("Software Engineer", "Senior Software Engineer", "Associate Software Engineer", 
                          "Full Stack Developer", "Backend Engineer", "Frontend Developer", "Tech Lead"),
      raw_variants = c("Software Eng", "SE", "SSE", "Full Stack Dev", "Full-Stack Software Engineer", 
                       "Sr. Software Developer", "Associate SE", "Software Developer"),
      skills = list(
        list(raw = c("Java", "java", "Java 17", "Core Java"), name = "Java", cat = "Programming Language"),
        list(raw = c("Spring Boot", "spring-boot", "SpringBoot"), name = "Spring Boot", cat = "Framework/Library"),
        list(raw = c("Python", "python", "Python3"), name = "Python", cat = "Programming Language"),
        list(raw = c("React", "react.js", "ReactJS", "REACT"), name = "React", cat = "Framework/Library"),
        list(raw = c("Node.js", "NodeJS", "node"), name = "Node.js", cat = "Framework/Library"),
        list(raw = c("TypeScript", "typescript", "TS"), name = "TypeScript", cat = "Programming Language"),
        list(raw = c("C#", "C#.NET", "c#"), name = "C#", cat = "Programming Language"),
        list(raw = c(".NET Core", ".NET", "dot net"), name = ".NET", cat = "Framework/Library"),
        list(raw = c("PostgreSQL", "postgres", "Postgresql"), name = "PostgreSQL", cat = "Database"),
        list(raw = c("MySQL", "mysql"), name = "MySQL", cat = "Database"),
        list(raw = c("Docker", "docker"), name = "Docker", cat = "Cloud/DevOps"),
        list(raw = c("REST APIs", "RESTful API", "REST"), name = "REST API", cat = "Tool/Methodology")
      )
    ),
    "QA & Test Automation" = list(
      standard_titles = c("QA Automation Engineer", "Senior QA Engineer", "Associate QA Engineer", "Quality Assurance Analyst", "QA Lead"),
      raw_variants = c("QA Engineer", "Automation Test Engineer", "Sr. QA Automation Eng", "QA / Tester", "Associate QA"),
      skills = list(
        list(raw = c("Selenium", "Selenium WebDriver", "selenium"), name = "Selenium", cat = "Tool/Methodology"),
        list(raw = c("Cypress", "Cypress.io"), name = "Cypress", cat = "Tool/Methodology"),
        list(raw = c("Playwright", "playwright"), name = "Playwright", cat = "Tool/Methodology"),
        list(raw = c("Postman", "postman"), name = "Postman", cat = "Tool/Methodology"),
        list(raw = c("JMeter", "jmeter"), name = "JMeter", cat = "Tool/Methodology"),
        list(raw = c("Java", "Java"), name = "Java", cat = "Programming Language"),
        list(raw = c("Manual Testing", "manual QA"), name = "Manual Testing", cat = "Tool/Methodology"),
        list(raw = c("JIRA", "jira"), name = "JIRA", cat = "Tool/Methodology")
      )
    ),
    "Cloud & DevOps" = list(
      standard_titles = c("DevOps Engineer", "Cloud Engineer", "Site Reliability Engineer", "Senior Cloud Engineer", "DevOps Lead"),
      raw_variants = c("DevOps / SRE", "Cloud Infra Engineer", "Sr DevOps Eng", "Platform Engineer"),
      skills = list(
        list(raw = c("AWS", "AWS Cloud", "Amazon Web Services"), name = "AWS", cat = "Cloud/DevOps"),
        list(raw = c("Azure", "Microsoft Azure", "azure"), name = "Azure", cat = "Cloud/DevOps"),
        list(raw = c("Terraform", "terraform", "IaC"), name = "Terraform", cat = "Cloud/DevOps"),
        list(raw = c("Kubernetes", "K8s", "k8s"), name = "Kubernetes", cat = "Cloud/DevOps"),
        list(raw = c("Docker", "docker"), name = "Docker", cat = "Cloud/DevOps"),
        list(raw = c("CI/CD", "CI-CD Pipelines", "GitLab CI"), name = "CI/CD", cat = "Tool/Methodology"),
        list(raw = c("Linux", "linux administration", "Ubuntu/RHEL"), name = "Linux", cat = "Tool/Methodology")
      )
    ),
    "Data & AI / ML" = list(
      standard_titles = c("Data Analyst", "Data Scientist", "Data Engineer", "Machine Learning Engineer", "BI Developer"),
      raw_variants = c("Data Analyst (Power BI)", "Data Eng", "ML / AI Engineer", "Junior Data Analyst"),
      skills = list(
        list(raw = c("Python", "python", "Python 3"), name = "Python", cat = "Programming Language"),
        list(raw = c("SQL", "sql queries", "Advanced SQL"), name = "SQL", cat = "Database"),
        list(raw = c("Power BI", "PowerBI", "power bi"), name = "Power BI", cat = "Tool/Methodology"),
        list(raw = c("PySpark", "Spark", "Apache Spark"), name = "PySpark", cat = "Framework/Library"),
        list(raw = c("PyTorch", "pytorch"), name = "PyTorch", cat = "Framework/Library"),
        list(raw = c("TensorFlow", "tensorflow"), name = "TensorFlow", cat = "Framework/Library"),
        list(raw = c("Pandas", "pandas"), name = "Pandas", cat = "Framework/Library")
      )
    ),
    "Cyber Security" = list(
      standard_titles = c("Information Security Analyst", "Cyber Security Engineer", "SOC Analyst", "Security Consultant"),
      raw_variants = c("Cyber Security Specialist", "InfoSec Analyst", "SOC / SIEM Analyst"),
      skills = list(
        list(raw = c("SIEM", "Splunk", "QRadar"), name = "SIEM", cat = "Tool/Methodology"),
        list(raw = c("Vulnerability Assessment", "VAPT"), name = "Vulnerability Assessment", cat = "Domain/Other"),
        list(raw = c("Network Security", "Firewall Configuration"), name = "Network Security", cat = "Domain/Other"),
        list(raw = c("ISO 27001", "ISO27001"), name = "ISO 27001", cat = "Domain/Other"),
        list(raw = c("Linux", "linux"), name = "Linux", cat = "Tool/Methodology")
      )
    ),
    "UI/UX & Product Design" = list(
      standard_titles = c("UI/UX Designer", "Product Designer", "Senior UI/UX Designer", "UI/UX Intern"),
      raw_variants = c("UI Designer", "UX/UI Specialist", "Product Design Lead"),
      skills = list(
        list(raw = c("Figma", "figma", "FIGMA"), name = "Figma", cat = "Tool/Methodology"),
        list(raw = c("Wireframing", "wireframes"), name = "Wireframing", cat = "Tool/Methodology"),
        list(raw = c("User Research", "UX Research"), name = "User Research", cat = "Domain/Other"),
        list(raw = c("Design Systems", "Design Tokens"), name = "Design Systems", cat = "Tool/Methodology"),
        list(raw = c("Prototyping", "interactive prototypes"), name = "Prototyping", cat = "Tool/Methodology")
      )
    ),
    "IT Systems & Infrastructure" = list(
      standard_titles = c("Systems Administrator", "Network Engineer", "IT Support Specialist", "NOC Engineer"),
      raw_variants = c("IT Support Officer", "System Admin", "Help Desk Support"),
      skills = list(
        list(raw = c("Windows Server", "Active Directory"), name = "Windows Server", cat = "Tool/Methodology"),
        list(raw = c("Cisco Routing", "CCNA"), name = "Cisco", cat = "Tool/Methodology"),
        list(raw = c("Hardware Support", "Desktop Troubleshooting"), name = "Hardware", cat = "Domain/Other"),
        list(raw = c("Linux", "linux"), name = "Linux", cat = "Tool/Methodology"),
        list(raw = c("Networking", "TCP/IP"), name = "Networking", cat = "Domain/Other")
      )
    ),
    "Management & Business Analysis" = list(
      standard_titles = c("Business Analyst", "Senior Business Analyst", "Technical Project Manager", "Scrum Master"),
      raw_variants = c("BA - IT", "Technical PM", "Agile Project Manager", "Product Owner"),
      skills = list(
        list(raw = c("Business Analysis", "Requirements Analysis"), name = "Business Analysis", cat = "Domain/Other"),
        list(raw = c("Agile", "Scrum", "Agile/Scrum"), name = "Agile", cat = "Tool/Methodology"),
        list(raw = c("JIRA", "jira / confluence"), name = "JIRA", cat = "Tool/Methodology"),
        list(raw = c("SQL", "sql"), name = "SQL", cat = "Database"),
        list(raw = c("Project Management", "Sprint Planning"), name = "Project Management", cat = "Domain/Other")
      )
    )
  )
  
  companies <- c(
    "Sysco LABS Sri Lanka", "WSO2", "99x", "IFS Sri Lanka", "Virtusa Sri Lanka",
    "MillenniumIT ESP", "Pearson Lanka", "LSEG Sri Lanka", "Calcey Technologies",
    "Axiata Digital Labs", "Creative Software", "Zone24x7", "CodeGen International",
    "hSenid Mobile Solutions", "Rootcode", "Surge Global", "DirectFN", "gapstars",
    "Mitra Innovation", "Tiqri Sri Lanka", "Brandix IT", "Dialog Axiata", "Sampath Bank IT"
  )
  
  work_modes <- c("Hybrid", "On-site", "Remote")
  work_mode_probs <- c(0.55, 0.30, 0.15)
  
  locations <- c("Colombo", "Colombo", "Colombo", "Kandy", "Nawala", "Battaramulla", "Galle", "Remote")
  
  # Temporal generation 2016-2026
  start_date <- as.Date("2016-01-01")
  end_date <- as.Date("2026-08-20")
  total_days <- as.numeric(end_date - start_date)
  
  jobs_list <- vector("list", n_records)
  skills_list <- list()
  
  category_names <- names(categories)
  # Realistic category weights (SE dominates, followed by QA, Cloud, Data, etc.)
  cat_weights <- c(0.42, 0.16, 0.12, 0.10, 0.05, 0.05, 0.05, 0.05)
  
  for (i in seq_len(n_records)) {
    job_id <- sprintf("SYN_%05d", i)
    cat_idx <- sample(seq_along(category_names), size = 1, prob = cat_weights)
    cat_name <- category_names[cat_idx]
    cat_info <- categories[[cat_name]]
    
    # Seniority assignment
    seniority <- sample(c("Intern", "Junior", "Mid", "Senior", "Lead"), 
                        size = 1, 
                        prob = c(0.08, 0.22, 0.40, 0.22, 0.08))
    
    # Title selection (mix of clean and raw aliases)
    use_alias <- runif(1) < 0.40
    if (seniority == "Intern") {
      job_title <- sprintf("%s Intern", ifelse(cat_name == "Software Engineering", "Software Engineering", cat_name))
      orig_title <- if (use_alias) sprintf("%s - Trainee / Intern", job_title) else job_title
      exp_min <- 0
      exp_max <- 1
      orig_exp <- "0-1 year or Undergraduate"
      emp_type <- "Internship"
    } else if (seniority == "Junior") {
      job_title <- sprintf("Associate %s", sample(cat_info$standard_titles, 1))
      orig_title <- if (use_alias) sample(cat_info$raw_variants, 1) else job_title
      exp_min <- sample(c(0, 1), 1, prob = c(0.3, 0.7))
      exp_max <- exp_min + sample(1:2, 1)
      orig_exp <- sprintf("%d-%d years relevant experience", exp_min, exp_max)
      emp_type <- "Full-time"
    } else if (seniority == "Mid") {
      job_title <- sample(cat_info$standard_titles, 1)
      orig_title <- if (use_alias) sample(cat_info$raw_variants, 1) else job_title
      exp_min <- sample(2:3, 1)
      exp_max <- exp_min + sample(2:3, 1)
      orig_exp <- sprintf("Minimum %d+ years experience", exp_min)
      emp_type <- "Full-time"
    } else if (seniority == "Senior") {
      job_title <- sprintf("Senior %s", sample(cat_info$standard_titles, 1))
      orig_title <- if (use_alias) sprintf("Sr. %s", sample(cat_info$raw_variants, 1)) else job_title
      exp_min <- sample(4:6, 1)
      exp_max <- exp_min + sample(2:4, 1)
      orig_exp <- sprintf("%d to %d years commercial experience", exp_min, exp_max)
      emp_type <- "Full-time"
    } else {
      job_title <- sprintf("Lead %s", sample(cat_info$standard_titles, 1))
      orig_title <- if (use_alias) sprintf("Principal / Lead %s", sample(cat_info$raw_variants, 1)) else job_title
      exp_min <- sample(7:9, 1)
      exp_max <- NA
      orig_exp <- sprintf("%d+ years leadership experience", exp_min)
      emp_type <- "Full-time"
    }
    
    # Random date posted across 2016-2026
    date_offset <- runif(1, min = 0, max = total_days)
    date_posted <- start_date + date_offset
    col_date <- as.Date("2026-08-26")
    
    company <- sample(companies, 1)
    work_mode <- sample(work_modes, 1, prob = work_mode_probs)
    loc <- sample(locations, 1)
    
    # Salary generation (high non-disclosure: ~70% missing, matching Sri Lankan reality)
    disclose_salary <- runif(1) < 0.30
    if (disclose_salary) {
      is_usd <- runif(1) < 0.18
      if (is_usd) {
        currency <- "USD"
        base_sal <- switch(seniority,
                           "Intern" = 200,
                           "Junior" = sample(500:800, 1),
                           "Mid" = sample(900:1500, 1),
                           "Senior" = sample(1600:2500, 1),
                           "Lead" = sample(2600:3800, 1))
        sal_min <- base_sal
        sal_max <- round(base_sal * sample(seq(1.2, 1.5, by = 0.05), 1))
        orig_sal <- sprintf("USD %d - %d (Pegged)", sal_min, sal_max)
      } else {
        currency <- "LKR"
        base_sal <- switch(seniority,
                           "Intern" = sample(c(40000, 50000, 60000), 1),
                           "Junior" = sample(seq(100000, 180000, by = 10000), 1),
                           "Mid" = sample(seq(220000, 420000, by = 20000), 1),
                           "Senior" = sample(seq(450000, 750000, by = 50000), 1),
                           "Lead" = sample(seq(800000, 1200000, by = 50000), 1))
        sal_min <- base_sal
        sal_max <- round(base_sal * sample(seq(1.25, 1.45, by = 0.05), 1))
        orig_sal <- sprintf("LKR %s - %s", format(sal_min, big.mark = ","), format(sal_max, big.mark = ","))
      }
    } else {
      currency <- NA
      sal_min <- NA
      sal_max <- NA
      orig_sal <- sample(c("Negotiable", "Attractive Remuneration", "Market Competitive", "Best in Industry", "Competitive Package"), 1)
    }
    
    jobs_list[[i]] <- data.frame(
      job_id = job_id,
      source = "Synthetic_Generator_v1",
      source_url = NA_character_,
      collection_date = as.character(col_date),
      source_job_id = NA_character_,
      date_posted = as.character(date_posted),
      original_title = orig_title,
      job_title = job_title,
      career_category = cat_name,
      seniority_level = seniority,
      company = company,
      location = loc,
      work_mode = work_mode,
      employment_type = emp_type,
      original_experience = orig_exp,
      experience_min = exp_min,
      experience_max = ifelse(is.na(exp_max), NA, exp_max),
      original_salary = orig_sal,
      salary_min = ifelse(is.na(sal_min), NA, sal_min),
      salary_max = ifelse(is.na(sal_max), NA, sal_max),
      currency = ifelse(is.na(currency), NA_character_, currency),
      is_synthetic = TRUE,
      stringsAsFactors = FALSE
    )
    
    # Sample 3-6 skills for this job
    n_skills <- sample(3:6, 1)
    avail_skills <- cat_info$skills
    chosen_indices <- sample(seq_along(avail_skills), size = min(n_skills, length(avail_skills)))
    
    for (s_idx in chosen_indices) {
      sk_obj <- avail_skills[[s_idx]]
      sk_raw <- sample(sk_obj$raw, 1)
      sk_name <- sk_obj$name
      sk_cat <- sk_obj$cat
      is_req <- sample(c(TRUE, FALSE), 1, prob = c(0.8, 0.2))
      
      skills_list[[length(skills_list) + 1]] <- data.frame(
        job_id = job_id,
        skill_raw = sk_raw,
        skill_name = sk_name,
        skill_category = sk_cat,
        is_required = is_req,
        stringsAsFactors = FALSE
      )
    }
  }
  
  jobs_df <- do.call(rbind, jobs_list)
  skills_df <- do.call(rbind, skills_list)
  
  # Inject 2-3 duplicate job records at the end to test cleaning deduplication
  dup_rows <- jobs_df[sample(1:50, 3), ]
  dup_rows$job_id <- sprintf("SYN_%05d", (n_records + 1):(n_records + 3))
  jobs_df <- rbind(jobs_df, dup_rows)
  
  # Write CSV files
  write.csv(jobs_df, file = output_jobs_path, row.names = FALSE, na = "NA")
  write.csv(skills_df, file = output_skills_path, row.names = FALSE, na = "NA")
  
  message(sprintf("Successfully written %d synthetic job records to: %s", nrow(jobs_df), output_jobs_path))
  message(sprintf("Successfully written %d associated skills to: %s", nrow(skills_df), output_skills_path))
  
  invisible(list(jobs = jobs_df, skills = skills_df))
}

# Execute generation if called directly
if (sys.nframe() == 0) {
  generate_synthetic_dataset()
}
