# Global variables and metadata

SERVICE     ?= loadgen
VERSION     ?= v0.1.0
COMMIT      ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
BUILT_AT    ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
MODULE_PATH ?= github.com/ParhamCh/$(SERVICE)

GO          ?= go
BUILD_DIR   ?= bin
CMD_PATH    ?= ./cmd/$(SERVICE)
BINARY      ?= $(BUILD_DIR)/$(SERVICE)

IMAGE_NAME  ?= parhamch/$(SERVICE)
PLATFORM    ?= linux/arm64

DOCKER      ?= docker

