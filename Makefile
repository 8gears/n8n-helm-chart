# Variables
CHART_DIR = charts/n8n
CHART_NAME = n8n
IMAGE_NAME = n8n-hook

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Linting
.PHONY: lint
lint: ## Lint the chart
	@echo "Running Artifact Hub lint..."
	@(cd $(CHART_DIR) && ah lint)
	@echo "Running Helm lint..."
	helm lint $(CHART_DIR)
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

## -------------------- APOLO APP-TYPES HOOK SECTION
.PHONY: hook-install hook-setup
hook-install hook-setup: poetry.lock
	poetry config virtualenvs.in-project true
	poetry install --with dev
	poetry run pre-commit install;

.PHONY: hook-install-app-types
hook-install-app-types:
	poetry run pip install --force-reinstall -U git+https://${APOLO_GITHUB_TOKEN}@github.com/neuro-inc/app-types.git@${APP_TYPES_REVISION}

.PHONY: hook-format
hook-format:
ifdef CI
	poetry run pre-commit run --all-files --show-diff-on-failure
else
	# automatically fix the formatting issues and rerun again
	poetry run pre-commit run --all-files || poetry run pre-commit run --all-files
endif

.PHONY: hook-lint
hook-lint: hook-format
	poetry run mypy .apolo

.PHONY: hook-test-unit
hook-test-unit:
	poetry run pytest -vvs --cov=.apolo --cov-report xml:.coverage.unit.xml .apolo/tests/unit

.PHONY: hook-test-integration
hook-test-integration:
	poetry run pytest -vv --cov=.apolo --cov-report xml:.coverage.integration.xml .apolo/tests/integration


.PHONY: hook-build-image
hook-build-image:
	docker build \
		-t $(IMAGE_NAME):latest \
		-f hooks.Dockerfile \
		.;

.PHONY: hook-push-image
hook-push-image:
	docker tag $(IMAGE_NAME):latest ghcr.io/neuro-inc/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push ghcr.io/neuro-inc/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: hook-gen-types-schemas
hook-gen-types-schemas:
	app-types dump-types-schema .apolo/src/apolo_apps_n8n N8nAppInputs .apolo/src/apolo_apps_n8n/schemas/N8nAppInputs.json
	app-types dump-types-schema .apolo/src/apolo_apps_n8n N8nAppOutputs .apolo/src/apolo_apps_n8n/schemas/N8nAppOutputs.json
