
$authKey = "tskey-auth-k4C5uZBb9g11CNTRL-u6sSeAruD9WPFuC4nMBL9WGAQsguN7T1"
Write-Host $authKey
tailscale up --authkey $env:TAILSCALE_AUTH_KEY --verbose
tailscale status
