
$authKey = $env:TAILSCALE_AUTH_KEY
#tailscale up --auth-key=tskey-auth-kn8TU1m4GE11CNTRL-RWL3PgUvAtGbFetLC6N8tG7RLQkk6hSy --unattended
tailscale up --authkey=$authKey
tailscale status
