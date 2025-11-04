package build

// Values are overridden via -ldflags at build time.
var (
	Service = "loadgen"
	Version = "dev"
	Commit  = "none"
	BuiltAt = "unknown"
)

