
# Get the auth key from environment variable (which GitHub will populate from secrets)
$authKey = $env:TAILSCALE_AUTH_KEY

# Check if auth key is available
if (-not $authKey) {
    Write-Error "Tailscale auth key not found in environment variables"
    exit 1
}

# Run tailscale command with the auth key
try {
    & tailscale up --auth-key=$authKey --unattended
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tailscale command failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
    Write-Output "Tailscale connected successfully"
}
catch {
    Write-Error "Error executing Tailscale command: $_"
    exit 1
}
