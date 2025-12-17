# loadgen

Lightweight Go HTTP service for generating controlled CPU, memory, and latency workload.  
Zero external dependencies — fast, portable, and container-friendly.

## ✨ Features
- Minimal REST API (`/`, `/healthz`, `/readyz`, `/version`)
- Configurable port via `.env` or environment variable `PORT`
- Graceful shutdown (SIGINT/SIGTERM)
- Build metadata via `ldflags`
- Modular `Makefile` system for Go and Docker builds
- Kubernetes-ready: probes, resource requests/limits, Service and Ingress manifests

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
├── k8s/                   # Plain Kubernetes manifests (no Helm/Kustomize)
│   ├── 00-namespace.yaml
│   ├── 10-deployment.yaml
│   ├── 20-service.yaml
│   ├── 30-ingress.yaml
│   └── README.md          # Kubernetes apply/config/TLS notes
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

## ☸️ Kubernetes Deployment (Plain Manifests)

This repository includes plain Kubernetes YAML manifests under `k8s/` for a clean, production-style deployment:

* `Deployment` with readiness/liveness probes and resource requests/limits
* `ClusterIP` `Service` (port 80 → container port 8080)
* `Ingress` for NGINX Ingress Controller
* Optional TLS integration via cert-manager (cluster issuer)

### Prerequisites

* Kubernetes cluster access via `kubectl`
* NGINX Ingress Controller (IngressClass: `nginx`)
* Optional: cert-manager for automated TLS

### Apply

```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/10-deployment.yaml
kubectl apply -f k8s/20-service.yaml
kubectl apply -f k8s/30-ingress.yaml
```

### Verify

```bash
kubectl -n loadgen get deploy,rs,pods,svc,ingress -owide
kubectl -n loadgen rollout status deploy/loadgen
```

### Test (Ingress)

If DNS is not configured for the ingress host, you can test via `Host` header:

```bash
curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/
curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/healthz
curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/readyz
curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/version
```

### TLS (Optional)

The Ingress manifest supports TLS using:

* `cert-manager.io/cluster-issuer` (set your issuer name)
* `spec.tls.secretName` (e.g., `loadgen-tls`)
* host in `spec.rules[].host` must match `spec.tls[].hosts[]`

For detailed Kubernetes notes, see: `k8s/README.md`.

---

🛠 Built with **Go 1.22** — optimized for edge and containerized environments.
📦 Perfect base for custom workload generators, performance benchmarks, and API stress testing.
