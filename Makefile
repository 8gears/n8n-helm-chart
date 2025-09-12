# Variables
CHART_DIR = charts/n8n
CHART_NAME = n8n

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Linting
.PHONY: lint
lint: ## Lint the chart
	@echo "Running ArtifactHub lint..."
	ah lint
	@echo "Running Chart-Testing lint..."
	ct lint --chart-dirs charts/n8n --charts charts/n8n --validate-maintainers=false

# Templating
.PHONY: template
template: ## Generate template output for the chart
	@echo "Generating Helm template..."
	helm template $(CHART_NAME) $(CHART_DIR)

.PHONY: template-debug
template-debug: ## Generate template with debug output
	@echo "Generating Helm template with debug..."
	helm template $(CHART_NAME) $(CHART_DIR) --debug

.PHONY: dry-run
dry-run: ## Perform a dry-run installation
	@echo "Performing dry-run installation..."
	helm install $(CHART_NAME) $(CHART_DIR) --dry-run --debug

# Local installation
.PHONY: install
install: ## Install the chart locally
	@echo "Installing chart locally..."
	helm install $(CHART_NAME) $(CHART_DIR)

.PHONY: upgrade
upgrade: ## Upgrade the installed chart
	@echo "Upgrading chart..."
	helm upgrade $(CHART_NAME) $(CHART_DIR)

.PHONY: uninstall
uninstall: ## Uninstall the chart
	@echo "Uninstalling chart..."
	helm uninstall $(CHART_NAME)

.PHONY: test
test: lint template dry-run ## Run all tests (lint, template, dry-run)

.PHONY: clean
clean: ## Clean up any generated files
	@echo "Cleaning up..."
	@rm -f *.tgz
