package handler

import (
	"fmt"
	"net/http"
)

// Root responds with a simple hello text.
func Root(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprintln(w, "hello api")
}

