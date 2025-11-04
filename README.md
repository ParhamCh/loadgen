# loadgen

Lightweight Go HTTP service for generating controlled CPU, memory, and latency workload.  
Zero external dependencies — fast, portable, and container-friendly.

## ✨ Features
- Minimal REST API (`/`, `/healthz`, `/readyz`, `/version`)
- Configurable port via `.env` or environment variable `PORT`
- Graceful shutdown (SIGINT/SIGTERM)
- Build metadata via `ldflags`
- Modular `Makefile` system for Go and Docker builds

---

## 📁 Project Structure
```

loadgen/
├── cmd/
│   └── loadgen/           # Application entrypoint (main.go)
├── internal/
│   ├── build/             # Build metadata (service, version, commit, built_at)
│   ├── config/            # Env and configuration loader
│   ├── handler/           # HTTP route handlers
│   └── server/            # HTTP server setup and route wiring
├── mk/
│   ├── vars.mk            # Global variables, loaded from .env if present
│   ├── go.mk              # Go build/test workflow
│   └── docker.mk          # Docker build/push/run workflow
├── .env.example           # Example environment template
├── Dockerfile             # Multi-stage Docker build
├── Makefile               # Entrypoint, includes mk/*.mk
├── go.mod / go.sum        # Go module definitions
└── README.md              # Project documentation

````

---

## ⚙️ Build & Run (Local)

### Run directly
```bash
go run ./cmd/loadgen
````

### Build binary with version info

```bash
go build -o bin/loadgen \
  -ldflags "-s -w \
    -X github.com/ParhamCh/loadgen/internal/build.Version=v0.1.0 \
    -X github.com/ParhamCh/loadgen/internal/build.Commit=$(git rev-parse --short HEAD) \
    -X github.com/ParhamCh/loadgen/internal/build.BuiltAt=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  ./cmd/loadgen
```

### Using Makefile

```bash
make build       # build Go binary
make run         # run locally
make test        # run tests
make tidy        # tidy go modules
make fmt         # format code
```

---

## 🐳 Build & Run (Docker)

### Build image

```bash
# Single-architecture
make docker-build
# or manually:
docker buildx build \
  --platform linux/amd64 \
  --build-arg VERSION=v0.1.0 \
  --build-arg COMMIT=$(git rev-parse --short HEAD) \
  --build-arg BUILT_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  -t parhamch/loadgen:v0.1.0 .
```

### Run container

```bash
# Automatically loads .env if present
make docker-run
# or manually:
docker run --rm -p 8080:8080 --env-file .env parhamch/loadgen:v0.1.0
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
📦 Perfect base for custom workload generators, performance benchmarks, and API stress testing.
