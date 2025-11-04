# Docker build/push workflow

.PHONY: docker-build docker-run docker-push

docker-build:
	@echo "→ Building Docker image $(IMAGE_NAME):$(VERSION) for $(PLATFORM)"
	$(DOCKER) buildx build \
	  --platform $(PLATFORM) \
	  --build-arg VERSION=$(VERSION) \
	  --build-arg COMMIT=$(COMMIT) \
	  --build-arg BUILT_AT=$(BUILT_AT) \
	  -t $(IMAGE_NAME):$(VERSION) .

docker-run:
	@echo "→ Running Docker container on port 8080..."
	$(DOCKER) run --rm -p 8080:8080 -e PORT=8080 $(IMAGE_NAME):$(VERSION)

docker-push:
	@echo "→ Pushing $(IMAGE_NAME):$(VERSION)"
	$(DOCKER) push $(IMAGE_NAME):$(VERSION)

