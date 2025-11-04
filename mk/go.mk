# Go build/test workflow

.PHONY: build run test clean fmt tidy

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

run: build
	@echo "→ Running $(SERVICE)..."
	./$(BINARY)

test:
	@echo "→ Running tests..."
	$(GO) test -v ./...

fmt:
	$(GO) fmt ./...

tidy:
	$(GO) mod tidy

clean:
	rm -rf $(BUILD_DIR)

