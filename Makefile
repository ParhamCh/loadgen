# ──────────────────────────────────────────────
# Loadgen - Makefile
# ──────────────────────────────────────────────

# --- Metadata ---
SERVICE     := loadgen
VERSION     := v0.1.0
COMMIT      := $(shell git rev-parse --short HEAD)
BUILT_AT    := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
MODULE_PATH := github.com/ParhamCh/$(SERVICE)

# --- Go build options ---
GO          := go
BUILD_DIR   := bin
CMD_PATH    := ./cmd/$(SERVICE)
BINARY      := $(BUILD_DIR)/$(SERVICE)

# --- Docker options ---
IMAGE_NAME  := parhamch/$(SERVICE)
PLATFORM    := linux/arm64
DOCKER      := docker

# ──────────────────────────────────────────────
# Targets
# ──────────────────────────────────────────────

.PHONY: all build run test clean docker-build docker-run tidy fmt

all: build

## Build Go binary with version metadata
build:
	@echo "→ Building $(BINARY)..."
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 $(GO) build -o $(BINARY) \
	  -ldflags "-s -w \
	    -X $(MODULE_PATH)/internal/build.Service=$(SERVICE) \
	    -X $(MODULE_PATH)/internal/build.Version=$(VERSION) \
	    -X $(MODULE_PATH)/internal/build.Commit=$(COMMIT) \
	    -X $(MODULE_PATH)/internal/build.BuiltAt=$(BUILT_AT)" \
	  $(CMD_PATH)
	@echo "✔ Built $(BINARY)"

## Run app locally
run: build
	@echo "→ Running $(SERVICE)..."
	./$(BINARY)

## Run unit tests
test:
	@echo "→ Running tests..."
	$(GO) test -v ./...

## Format & tidy modules
fmt:
	$(GO) fmt ./...
tidy:
	$(GO) mod tidy

## Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

## Build Docker image
docker-build:
	@echo "→ Building Docker image $(IMAGE_NAME):$(VERSION)"
	$(DOCKER) buildx build \
	  --platform $(PLATFORM) \
	  --build-arg VERSION=$(VERSION) \
	  --build-arg COMMIT=$(COMMIT) \
	  --build-arg BUILT_AT=$(BUILT_AT) \
	  -t $(IMAGE_NAME):$(VERSION) .

## Run Docker container
docker-run:
	@echo "→ Running Docker container on port 8080..."
	$(DOCKER) run --rm -p 8080:8080 -e PORT=8080 $(IMAGE_NAME):$(VERSION)

