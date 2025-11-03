package main

import (
	"fmt"
	"net/http"
)

func main() {
	// Define handler for root path
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Set content type to text/plain
		w.Header().Set("Content-Type", "text/plain")
		// Write response
		fmt.Fprintln(w, "hello api")
	})

	// Start HTTP server on port 8080
	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Println("Error starting server:", err)
	}
}

