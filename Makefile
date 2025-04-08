.PHONY: setup security-check test clean

setup:
	python -m pip install --upgrade pip
	pip install -r requirements.txt
	pre-commit install

security-check: ## Run all security checks
	@echo "Running security checks..."
	bandit -r . -f json -o security-reports/bandit-results.json
	safety check
	trivy fs .
	@echo "Security checks completed"

test: ## Run tests with security coverage
	pytest --cov=. --cov-report=xml

clean: ## Clean up temporary files and artifacts
	rm -rf security-reports/*
	rm -rf .coverage coverage.xml
	find . -type d -name "__pycache__" -exec rm -rf {} +

init-security: ## Initialize security tooling
	@echo "Initializing security tools..."
	mkdir -p security-reports
	touch security-reports/.gitkeep
	@echo "Security tools initialized"

scan-dependencies: ## Scan dependencies for vulnerabilities
	@echo "Scanning dependencies..."
	safety check
	pip-audit

container-scan: ## Scan container for vulnerabilities
	@echo "Scanning container..."
	trivy image app:latest

secrets-scan: ## Scan for secrets in codebase
	@echo "Scanning for secrets..."
	detect-secrets scan .

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)