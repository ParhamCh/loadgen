# Kubernetes Manifests (k8s/)

This directory contains plain Kubernetes YAML manifests to deploy **loadgen**, a stateless Go HTTP service used for load generation and autoscaling experiments.

The manifests are intentionally **minimal** (no Helm, no Kustomize) and follow a clean, production-style layout.

## Contents

- `00-namespace.yaml`  
  Creates the `loadgen` namespace.

- `10-deployment.yaml`  
  Deploys the `loadgen` application (replicas, probes, resources, optional nodeSelector).

- `20-service.yaml`  
  Exposes the app internally via a `ClusterIP` Service on port `80` → container port `8080`.

- `30-ingress.yaml`  
  Exposes the app externally via NGINX Ingress. Optional TLS via cert-manager.

## Prerequisites

- A Kubernetes cluster with access to `kubectl`
- NGINX Ingress Controller installed (IngressClass name: `nginx`)
  - Verify:
    ```bash
    kubectl get ingressclass
    ```
- (Optional) cert-manager installed if you want automatic TLS
  - Verify:
    ```bash
    kubectl -n cert-manager get pods
    ```

## Quick Start

Apply all resources:

```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/10-deployment.yaml
kubectl apply -f k8s/20-service.yaml
kubectl apply -f k8s/30-ingress.yaml
````

Check status:

```bash
kubectl -n loadgen get deploy,rs,pods,svc,ingress -owide
kubectl -n loadgen rollout status deploy/loadgen
```

## Configuration (Minimal)

Only a few fields typically need adjustment depending on your environment:

### Deployment

* **Replicas**

  * File: `10-deployment.yaml`
  * Field: `spec.replicas`

* **Image and tag**

  * File: `10-deployment.yaml`
  * Field: `spec.template.spec.containers[0].image`

* **Optional nodeSelector**

  * File: `10-deployment.yaml`
  * Field: `spec.template.spec.nodeSelector`
  * Notes:

    * Keep it if your cluster uses labeled nodes (e.g., `role=workload`).
    * Remove the `nodeSelector` block if your cluster does not require scheduling constraints.

### Ingress

* **Hostname**

  * File: `30-ingress.yaml`
  * Field: `spec.rules[0].host` (and `spec.tls[0].hosts[0]` if TLS is enabled)

* **IngressClass**

  * File: `30-ingress.yaml`
  * Field: `spec.ingressClassName`
  * Must match your cluster’s IngressClass (commonly `nginx`).

## Access & Testing

### Service (inside the cluster)

The Service is `ClusterIP`, so it is reachable from within the cluster.

* From a node (if your cluster networking allows it):

  ```bash
  curl -i http://<CLUSTER_IP>:80/
  ```

* Standard method: from inside a temporary Pod:

  ```bash
  kubectl -n loadgen run curltest --rm -it --restart=Never --image=curlimages/curl:8.5.0 -- \
    curl -i http://loadgen/
  ```

### Ingress (from outside)

Once Ingress is applied, access depends on DNS/hosts configuration.

* If you do not have DNS for the host, you can test with a manual `Host` header:

  ```bash
  curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/
  ```

* Verify endpoints:

  ```bash
  curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/healthz
  curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/readyz
  curl -i -H "Host: loadgen.example.com" http://<INGRESS_EXTERNAL_IP>/version
  ```

## TLS (Optional, via cert-manager)

TLS is enabled in `30-ingress.yaml` using:

* `spec.tls[*].secretName: loadgen-tls`
* `cert-manager.io/cluster-issuer: your-ca-name`

To use cert-manager:

1. Replace `your-ca-name` with your actual `ClusterIssuer` name.
2. Ensure the host in `spec.rules[].host` matches the TLS host in `spec.tls[].hosts[]`.

Check certificate provisioning:

```bash
kubectl -n loadgen get certificate
kubectl -n loadgen get secret loadgen-tls
kubectl -n loadgen describe ingress loadgen
```

If you do not want TLS:

* Remove the entire `spec.tls:` block, and
* Remove the `cert-manager.io/cluster-issuer` annotation.

## Notes on Best Practices

* Readiness/liveness probes are configured for `/readyz` and `/healthz`.
* Requests/limits are intentionally small for a lightweight service.
* Manifests avoid embedding any Kubernetes Secrets (no private keys or tokens).

## Cleanup

```bash
kubectl delete -f k8s/30-ingress.yaml
kubectl delete -f k8s/20-service.yaml
kubectl delete -f k8s/10-deployment.yaml
kubectl delete -f k8s/00-namespace.yaml
```

