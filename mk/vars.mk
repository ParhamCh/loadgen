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
PLATFORM    ?= linux/amd64

DOCKER      ?= docker

# --- Load .env if present (export keys) ---
PORT        ?= 8080
ifneq (,$(wildcard .env))
include .env
# export all keys defined in .env (KEY=VALUE lines)
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' .env)
endif
