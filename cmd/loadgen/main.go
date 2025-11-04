package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/ParhamCh/loadgen/internal/config"
	"github.com/ParhamCh/loadgen/internal/server"
)

func main() {
	// Load .env file from project root
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Error loading config: %v", err)
	}

	srv := server.New(server.Options{
		Addr: cfg.Address(),
		// Optional: override timeouts here if needed
	})

	// Run server in background
	errCh := make(chan error, 1)
	go func() {
		errCh <- server.Start(srv)
	}()

	// Wait for interrupt (Ctrl+C) or SIGTERM
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-errCh:
		log.Fatalf("server error: %v", err)
	case sig := <-sigCh:
		log.Printf("signal recived: %s, shutting down ...", sig)
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := srv.Shutdown(ctx); err != nil {
			log.Printf("graceful shutdown failed: %v", err)
		} else {
			log.Printf("server stopped cleanly")
		}

	}
}
