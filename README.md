# loadgen

Lightweight Go HTTP service for generating controlled CPU, memory, and latency workload.  
Zero external dependencies — fast, portable, and container-friendly.

## Features
- Minimal REST API (`/`, `/healthz`, `/readyz`, `/version`)
- Configurable port via `.env` or environment variable `PORT`
- Graceful shutdown (SIGINT/SIGTERM)
- Build metadata via `ldflags`
- Multi-arch Docker image (amd64 / arm64)

---

## 📁 Project Structure
```

loadgen/
├── cmd/
│   └── loadgen/           # Application entrypoint (main.go)
├── internal/
│   ├── build/             # Build metadata (version, commit, time)
│   ├── config/            # Env and configuration loader
│   ├── handler/           # HTTP route handlers
│   └── server/            # HTTP server setup and route wiring
├── .env                   # Environment variables
├── Dockerfile             # Multi-stage Docker build
├── go.mod / go.sum        # Go module definitions
└── README.md              # Project documentation

````

---

## ⚙️ Build & Run (Local)
```bash
# Run directly
go run ./cmd/loadgen

# Build binary with version info
go build -o bin/loadgen \
  -ldflags "-s -w \
    -X github.com/ParhamCh/loadgen/internal/build.Version=v0.1.0 \
    -X github.com/ParhamCh/loadgen/internal/build.Commit=$(git rev-parse --short HEAD) \
    -X github.com/ParhamCh/loadgen/internal/build.BuiltAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  ./cmd/loadgen
````

---

## 🐳 Build & Run (Docker)

```bash
# Build image (single-arch)
docker buildx build \
  --platform linux/amd64 \
  --build-arg VERSION=v0.1.0 \
  --build-arg COMMIT=$(git rev-parse --short HEAD) \
  --build-arg BUILT_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  -t parhamch/loadgen:v0.1.0 .

# Run container
docker run --rm -p 8080:8080 -e PORT=8080 parhamch/loadgen:v0.1.0
```

---

## 🧭 API Endpoints

| Path       | Method | Description                                       |
| ---------- | ------ | ------------------------------------------------- |
| `/`        | GET    | Returns `"hello api"`                             |
| `/healthz` | GET    | Liveness probe                                    |
| `/readyz`  | GET    | Readiness probe                                   |
| `/version` | GET    | Build info (service, version, commit, build time) |

---

🛠 Built with **Go 1.22** — optimized for edge and containerized environments.
📦 Perfect base for custom workload generators or API performance testing.

```

---
