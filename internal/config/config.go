package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds application configuration loaded from environment.
type Config struct {
	Port string // Port to listen on for HTTP server
}

// Address returns the address string for net/http server, e.g., ":8080".
func (c *Config) Address() string { return ":" + c.Port }

// Load attempts to read configuration from environment variables.
// It loads a .env file if present (from common locations) and applies defaults.
func Load() (Config, error) {
	// Load .env from project root; ignore error (Docker may inject envs).
	_ = godotenv.Load(".env")

	// Validate and load PORT
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // default port
	}
	if n, err := strconv.Atoi(port); err != nil || n < 1 || n > 65535 {
		return Config{}, fmt.Errorf("invalid PORT: %q", port)
	}
	return Config{Port: port}, nil
}
