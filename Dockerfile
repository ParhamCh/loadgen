# --- Build stage ---
FROM golang:1.22-alpine AS build
WORKDIR /src

# Enable Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy sources
COPY . .

# Build-time metadata (override via --build-arg)
ARG VERSION=dev
ARG COMMIT=none
ARG BUILT_AT=unknown

# BuildKit provides these when you pass --platform
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# Produce a static, OS/Arch-specific binary
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH:-amd64} GOARM= \
    go build -o /out/loadgen \
      -ldflags "-s -w \
        -X github.com/ParhamCh/loadgen/internal/build.Service=loadgen \
        -X github.com/ParhamCh/loadgen/internal/build.Version=${VERSION} \
        -X github.com/ParhamCh/loadgen/internal/build.Commit=${COMMIT} \
        -X github.com/ParhamCh/loadgen/internal/build.BuiltAt=${BUILT_AT}" \
      ./cmd/loadgen

# --- Runtime stage ---
FROM alpine:3.20
# If you call external HTTPS endpoints, uncomment certs:
# RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=build /out/loadgen /usr/local/bin/loadgen

EXPOSE 8080
ENV PORT=8080
ENTRYPOINT ["/usr/local/bin/loadgen"]

