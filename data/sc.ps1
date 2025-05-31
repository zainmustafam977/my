
$authKey = $env:TAILSCALE_AUTH_KEY
Write-Host $authKey
tailscale up --authkey $env:TAILSCALE_AUTH_KEY --verbose
tailscale status
