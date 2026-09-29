# TechScape: Cross-Platform Project Task Runner
# Usage: make <target>

PYTHON ?= python
RSCRIPT ?= Rscript

.PHONY: help setup test test-python test-r lint audit pipeline update-feed db-seed db-clean run-api clean

help:  ## Display available targets
	@echo "TechScape Build & Automation System"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup:  ## Install Python dependencies and verify R environment
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements-dev.txt
	-$(RSCRIPT) R/install_dependencies.R

test: test-python test-r  ## Run both Python and R automated test suites

test-python:  ## Run Python unit and integration tests via pytest
	$(PYTHON) -m pytest tests/ -v --tb=short

test-r:  ## Run R data quality and provenance tests
	-$(RSCRIPT) tests/testthat.R

lint:  ## Check code hygiene and style using ruff
	$(PYTHON) -m ruff check python/ tests/

audit:  ## Verify repo claims, table/figure counts, and file link integrity
	$(PYTHON) -m python.audit

pipeline:  ## Run full hybrid Python + R end-to-end analytical pipeline
	$(PYTHON) python/runner.py

update-feed:  ## Scrape fresh vacancies from live job portals
	$(PYTHON) python/live_updater.py --limit 20

db-seed:  ## Idempotently seed SQLite relational database with baseline empirical corpus
	$(PYTHON) python/db/seed.py

db-clean:  ## Remove SQLite database file
	-rm -f data/techscape.db

run-api:  ## Start the FastAPI development server with hot-reload
	$(PYTHON) -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000

clean:  ## Clean temporary caches, bytecode, and test artifacts
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
