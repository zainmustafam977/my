# Get auth key from environment
$authKey = $env:TAILSCALE_AUTH_KEY

# Debug output (remove in production)
Write-Output "Auth key: $($authKey ? '*****' + $authKey.Substring($authKey.Length - 4) : 'NOT FOUND')"

try {
    # 1. Verify Tailscale executable is available
    $tailscalePath = Get-Command tailscale -ErrorAction Stop | Select-Object -ExpandProperty Source
    Write-Output "[INFO] Tailscale found at: $tailscalePath"

    # 2. Validate auth key
    if (-not $authKey) {
        throw "TAILSCALE_AUTH_KEY environment variable not set"
    }
    if (-not $authKey.StartsWith("tskey-auth-")) {
        throw "Invalid Tailscale auth key format"
    }

    # 3. Connect to Tailscale network
    Write-Output "[INFO] Connecting to Tailscale network..."
    & tailscale up --auth-key=$authKey --unattended
    
    if ($LASTEXITCODE -ne 0) {
        throw "Tailscale connection failed with exit code $LASTEXITCODE"
    }

    # 4. Verify connection status
    $status = & tailscale status --json | ConvertFrom-Json
    if ($status.BackendState -ne "Running") {
        throw "Tailscale connection not active. Current state: $($status.BackendState)"
    }

    Write-Output "[SUCCESS] Tailscale connected successfully!"
    Write-Output "Tailscale IP: $($status.Self.TailscaleIPs[0])"
    Write-Output "Peer count: $(@($status.Peer).Count)"
}
catch {
    Write-Output "[ERROR] $_"
    
    # Diagnostic information
    Write-Output "`n[DIAGNOSTICS]"
    Write-Output "Current PATH:"
    $env:PATH -split ';' | Write-Output
    
    Write-Output "`nRunning processes:"
    Get-Process | Where-Object { $_.Name -like "*tailscale*" } | Select-Object Name, Path | Format-Table -AutoSize
    
    Write-Output "`nInstalled programs:"
    Get-ChildItem "$env:ProgramFiles\Tailscale", "${env:ProgramFiles(x86)}\Tailscale" -ErrorAction SilentlyContinue | 
        Select-Object FullName, LastWriteTime | Format-Table -AutoSize
    
    exit 1
}

exit 0
