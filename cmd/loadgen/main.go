package main

import (
	"log"

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

	if err := server.Start(srv); err != nil {
		log.Fatalf("server error: %v", err)
	}}

