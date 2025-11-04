package server

import (
	"log"
	"net/http"
	"time"

	"github.com/ParhamCh/loadgen/internal/handler"
)

// Options holds HTTP server configuration such as address and timeouts.
type Options struct {
	Addr              string
	ReadTimeout       time.Duration
	WriteTimeout      time.Duration
	IdleTimeout       time.Duration
	ReadHeaderTimeout time.Duration
}

// New creates a new *http.Server with sane defaults and registered routes.
func New(opts Options) *http.Server {
	// Fallbacks for zero values
	if opts.Addr == "" {
		opts.Addr = ":8080"
	}
	if opts.ReadTimeout == 0 {
		opts.ReadTimeout = 5 * time.Second
	}
	if opts.WriteTimeout == 0 {
		opts.WriteTimeout = 10 * time.Second
	}
	if opts.IdleTimeout == 0 {
		opts.IdleTimeout = 60 * time.Second
	}
	if opts.ReadHeaderTimeout == 0 {
		opts.ReadHeaderTimeout = 2 * time.Second
	}

	mux := http.NewServeMux()
	registerRoutes(mux)

	srv := &http.Server{
		Addr:              opts.Addr,
		Handler:           loggingMiddleware(mux),
		ReadTimeout:       opts.ReadTimeout,
		WriteTimeout:      opts.WriteTimeout,
		IdleTimeout:       opts.IdleTimeout,
		ReadHeaderTimeout: opts.ReadHeaderTimeout,
	}
	return srv
}

// Start runs the HTTP server and returns any error from ListenAndServe.
func Start(srv *http.Server) error {
	log.Printf("http server listening on %s", srv.Addr)
	return srv.ListenAndServe()
}

// registerRoutes wires the base routes. In step 3, move handlers to internal/handler.
func registerRoutes(mux *http.ServeMux) {
	// Root: returns "hello api"
	mux.HandleFunc("/", handler.Root)
	// Liveness probe
	mux.HandleFunc("/healthz", handler.Healthz)
	// Readiness probe
	mux.HandleFunc("/readyz", handler.Readyz)
	// Version info
	mux.HandleFunc("/version", handler.Version)
}

// loggingMiddleware is a tiny access log; can be swapped with structured logging later.
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
	})
}
