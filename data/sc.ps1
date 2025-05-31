
$authKey = $env:TAILSCALE_AUTH_KEY
tailscale up --authkey $authKey
tailscale status
