# --- Build stage ---
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG VERSION=dev
ARG COMMIT=none
ARG BUILT_AT=unknown
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o /out/loadgen \
    -ldflags "-s -w \
      -X github.com/ParhamCh/loadgen/internal/build.Service=loadgen \
      -X github.com/ParhamCh/loadgen/internal/build.Version=${VERSION} \
      -X github.com/ParhamCh/loadgen/internal/build.Commit=${COMMIT} \
      -X github.com/ParhamCh/loadgen/internal/build.BuiltAt=${BUILT_AT}" \
    ./cmd/loadgen

# --- Runtime stage ---
FROM alpine:3.20
WORKDIR /app
COPY --from=build /out/loadgen /usr/local/bin/loadgen
EXPOSE 8080
ENV PORT=8080
ENTRYPOINT ["/usr/local/bin/loadgen"]

