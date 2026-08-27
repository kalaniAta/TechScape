# ==============================================================================
# TechScape: Interactive Analytical Dashboard (dashboard/app.R)
# ==============================================================================
# PROVENANCE NOTICE:
# R Shiny Application for interactive exploration of verified Sri Lankan IT
# labour market data (n=80 postings) and official macroeconomic indicators.
# ==============================================================================

# Check if shiny is available; if not, print user-friendly instructions
if (!requireNamespace("shiny", quietly = TRUE)) {
  cat("\n--------------------------------------------------------------------\n")
  cat("TechScape Shiny Dashboard Notice:\n")
  cat("The package 'shiny' is not installed in the current environment.\n")
  cat("To run this R Shiny app, install it using: install.packages('shiny')\n")
  cat("Alternatively, use the standalone interactive dashboard in `dashboard/index.html`!\n")
  cat("--------------------------------------------------------------------\n\n")
} else {
  library(shiny)

  # Load datasets
  jobs <- read.csv("../data/processed/jobs_real_transformed.csv", stringsAsFactors = FALSE)
  skills <- read.csv("../data/processed/job_skills_real_transformed.csv", stringsAsFactors = FALSE)
  macro <- read.csv("../data/processed/macro_labour_indicators.csv", stringsAsFactors = FALSE)

  # UI Definition
  ui <- fluidPage(
    titlePanel("TechScape: Sri Lankan IT Labour Market Analytics (Empirical Sample)"),
    sidebarLayout(
      sidebarPanel(
        selectInput("career_filter", "Career Track:", choices = c("All", unique(jobs$career_category))),
        selectInput("seniority_filter", "Seniority Tier:", choices = c("All", unique(jobs$seniority_level))),
        selectInput("work_mode_filter", "Work Mode:", choices = c("All", unique(jobs$work_mode))),
        hr(),
        helpText("VERIFIED REAL SRI LANKAN IT DATA — EMPIRICAL SAMPLE (n=80)"),
        helpText("Sources: TopJobs LK, LinkedIn LK, ITPro LK, DCS, CBSL")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Overview",
            h3("Empirical Career Track Distribution"),
            plotOutput("career_plot"),
            h3("Top Demanded Technical Skills"),
            plotOutput("skills_plot")
          ),
          tabPanel("Compensation",
            h3("Disclosed LKR Monthly Salary Distribution"),
            plotOutput("salary_plot")
          ),
          tabPanel("Macroeconomic Context",
            h3("National & Youth Unemployment (DCS LFS)"),
            plotOutput("macro_plot")
          ),
          tabPanel("Job Postings Registry",
            h3("Empirical Observations with Provenance"),
            tableOutput("jobs_table")
          )
        )
      )
    )
  )

  # Server Logic
  server <- function(input, output, session) {
    filtered_jobs <- reactive({
      df <- jobs
      if (input$career_filter != "All") df <- subset(df, career_category == input$career_filter)
      if (input$seniority_filter != "All") df <- subset(df, seniority_level == input$seniority_filter)
      if (input$work_mode_filter != "All") df <- subset(df, work_mode == input$work_mode_filter)
      df
    })

    output$career_plot <- renderPlot({
      df <- filtered_jobs()
      tab <- sort(table(df$career_category), decreasing = TRUE)
      par(mar = c(4, 10, 2, 2))
      barplot(rev(tab), horiz = TRUE, col = "#1b9e77", las = 1, xlab = "Postings")
    })

    output$skills_plot <- renderPlot({
      df <- filtered_jobs()
      sub_skills <- subset(skills, job_id %in% df$job_id)
      sk_tab <- head(sort(table(sub_skills$skill_name), decreasing = TRUE), 10)
      par(mar = c(4, 8, 2, 2))
      barplot(rev(sk_tab), horiz = TRUE, col = "#3b528b", las = 1, xlab = "Occurrences")
    })

    output$salary_plot <- renderPlot({
      df <- subset(filtered_jobs(), currency == "LKR" & !is.na(salary_midpoint))
      if (nrow(df) > 0) {
        hist(df$salary_midpoint / 1000, breaks = 8, col = "#7570b3", xlab = "Salary (Thousand LKR)", main = "")
      }
    })

    output$macro_plot <- renderPlot({
      unemp <- subset(macro, indicator_name == "National Unemployment Rate" & quarter == "Annual")
      plot(unemp$year, unemp$value, type = "b", pch = 19, col = "#d95f02", ylab = "Unemployment Rate (%)", xlab = "Year")
    })

    output$jobs_table <- renderTable({
      head(filtered_jobs()[, c("job_id", "original_title", "company", "career_category", "seniority_level", "work_mode", "source")], 20)
    })
  }

  shinyApp(ui = ui, server = server)
}
