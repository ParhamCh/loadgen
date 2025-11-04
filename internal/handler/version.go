package handler

import (
	"encoding/json"
	"net/http"

	"github.com/ParhamCh/loadgen/internal/build"
)

type versionPayload struct {
	Service string `json:"service"`
	Version string `json:"version"`
	Commit  string `json:"commit"`
	BuiltAt string `json:"built_at"`
}

func Version(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(versionPayload{
		Service: build.Service,
		Version: build.Version,
		Commit:  build.Commit,
		BuiltAt: build.BuiltAt,
	})
}

