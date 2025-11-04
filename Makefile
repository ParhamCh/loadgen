include mk/vars.mk
include mk/go.mk
include mk/docker.mk

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Targets:"
	@echo "  build           Build Go binary with version metadata"
	@echo "  run             Run app locally"
	@echo "  test            Run unit tests"
	@echo "  fmt             Format Go code"
	@echo "  tidy            Tidy Go modules"
	@echo "  clean           Remove build artifacts"
	@echo "  docker-build    Build Docker image"
	@echo "  docker-run      Run Docker image locally"
	@echo "  docker-push     Push image to registry"

