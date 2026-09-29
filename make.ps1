<#
.SYNOPSIS
    TechScape PowerShell Task Runner for Windows environments
.DESCRIPTION
    Provides make-equivalent tasks without requiring GNU make on Windows.
.EXAMPLE
    .\make.ps1 setup
    .\make.ps1 test
    .\make.ps1 audit
    .\make.ps1 pipeline
#>

param (
    [Parameter(Position = 0)]
    [string]$Target = "help"
)

$Python = "python"
$Rscript = if (Get-Command Rscript -ErrorAction SilentlyContinue) { 
    "Rscript" 
} elseif (Test-Path "C:\Program Files\R\R-4.6.1\bin\Rscript.exe") { 
    "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" 
} else { 
    "Rscript" 
}

function Show-Help {
    Write-Host "TechScape PowerShell Automation System" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "  setup       - Install Python dependencies and verify R environment"
    Write-Host "  test        - Run both Python and R test suites"
    Write-Host "  test-python - Run Python unit tests via pytest"
    Write-Host "  test-r      - Run R data quality tests"
    Write-Host "  lint        - Check code hygiene and style via ruff"
    Write-Host "  audit       - Verify repo claims, table/figure counts, and links"
    Write-Host "  pipeline    - Run full hybrid Python + R analytical pipeline"
    Write-Host "  update-feed - Scrape fresh vacancies from live job portals"
    Write-Host "  db-seed     - Idempotently seed SQLite database with empirical baseline"
    Write-Host "  db-clean    - Remove SQLite database file"
    Write-Host "  run-api     - Start the FastAPI development server"
    Write-Host "  clean       - Clean temporary caches and bytecode"
}

switch ($Target.ToLower()) {
    "setup" {
        Write-Host ">>> Installing Python dependencies..." -ForegroundColor Green
        & $Python -m pip install --upgrade pip
        & $Python -m pip install -r requirements-dev.txt
        Write-Host ">>> Verifying R environment..." -ForegroundColor Green
        try { & $Rscript R/install_dependencies.R } catch { Write-Warning "Rscript not found on PATH or failed." }
    }
    "test" {
        Write-Host ">>> Running Python test suite (pytest)..." -ForegroundColor Green
        & $Python -m pytest tests/ -v --tb=short
        Write-Host ">>> Running R test suite..." -ForegroundColor Green
        try { & $Rscript tests/testthat.R } catch { Write-Warning "Rscript not found or failed." }
    }
    "test-python" {
        Write-Host ">>> Running Python tests..." -ForegroundColor Green
        & $Python -m pytest tests/ -v --tb=short
    }
    "test-r" {
        Write-Host ">>> Running R tests..." -ForegroundColor Green
        & $Rscript tests/testthat.R
    }
    "lint" {
        Write-Host ">>> Running ruff linter..." -ForegroundColor Green
        & $Python -m ruff check python/ tests/
    }
    "audit" {
        Write-Host ">>> Running repository claims & link audit..." -ForegroundColor Green
        & $Python -m python.audit
    }
    "pipeline" {
        Write-Host ">>> Running complete TechScape ecosystem..." -ForegroundColor Green
        & $Python python/runner.py
    }
    "update-feed" {
        Write-Host ">>> Executing live web scraping from TopJobs LK and ITPro LK..." -ForegroundColor Green
        & $Python python/live_updater.py --limit 20
    }
    "db-seed" {
        Write-Host ">>> Seeding SQLite database with baseline empirical corpus..." -ForegroundColor Green
        & $Python python/db/seed.py
    }
    "db-clean" {
        Write-Host ">>> Removing SQLite database file..." -ForegroundColor Green
        if (Test-Path "data/techscape.db") {
            Remove-Item "data/techscape.db" -Force
            Write-Host ">>> data/techscape.db removed." -ForegroundColor Green
        } else {
            Write-Host ">>> data/techscape.db does not exist." -ForegroundColor Yellow
        }
    }
    "run-api" {
        Write-Host ">>> Starting FastAPI server..." -ForegroundColor Green
        & $Python -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
    }
    "clean" {
        Write-Host ">>> Cleaning cache and temporary files..." -ForegroundColor Green
        Get-ChildItem -Path . -Include __pycache__, .pytest_cache, .ruff_cache -Recurse -Force | Remove-Item -Recurse -Force
        Get-ChildItem -Path . -Include *.pyc -Recurse -Force | Remove-Item -Force
        Write-Host ">>> Clean complete." -ForegroundColor Green
    }
    default {
        Show-Help
    }
}
