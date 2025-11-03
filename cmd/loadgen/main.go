package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

func main() {
	// Load .env file from project root
	err := godotenv.Load(".env")
	if err != nil {
		log.Printf("Warning: could not load .env file: %v", err)
	}

	// Read port from environment variable
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port if not set
	}

	// Define handler for root path
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Set content type to text/plain
		w.Header().Set("Content-Type", "text/plain")
		// Write response
		fmt.Fprintln(w, "hello api")
	})

	// Start HTTP server
	addr := fmt.Sprintf(":%s", port)
	fmt.Printf("Server is running on http://localhost%s\n", addr)

	if err := http.ListenAndServe(addr, nil); err != nil {
		fmt.Println("Error starting server:", err)
	}
}

