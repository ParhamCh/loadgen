package handler

import "net/http"

// Healthz is a basic liveness probe.
func Healthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

// Readyz is a basic readiness probe (extend later if needed).
func Readyz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}
