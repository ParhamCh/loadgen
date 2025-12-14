# Docker build/push workflow

.PHONY: docker-build docker-run docker-push

docker-build:
	@echo "→ Building Docker image $(IMAGE_NAME):$(VERSION) for $(PLATFORM) (PORT=$(PORT))"
	$(DOCKER) buildx build \
	  --platform $(PLATFORM) \
	  --build-arg VERSION=$(VERSION) \
	  --build-arg COMMIT=$(COMMIT) \
	  --build-arg BUILT_AT=$(BUILT_AT) \
	  --build-arg PORT=$(PORT) \
	  -t $(IMAGE_NAME):$(VERSION) .

docker-run:
	@echo "→ Running Docker container on (PORT=$(PORT))..."
	@if [ -f .env ]; then \
	  echo "    using --env-file .env"; \
	  $(DOCKER) run --rm -it -p $(PORT):$(PORT) --env-file .env $(IMAGE_NAME):$(VERSION); \
	else \
	  echo "    .env not found; using -e PORT=$(PORT)"; \
	  $(DOCKER) run --rm -it -p $(PORT):$(PORT) -e PORT=$(PORT) $(IMAGE_NAME):$(VERSION); \
	fi

docker-push:
	@echo "→ Pushing $(IMAGE_NAME):$(VERSION)"
	$(DOCKER) push $(IMAGE_NAME):$(VERSION)

