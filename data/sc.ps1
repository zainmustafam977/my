<#
.SYNOPSIS
    Connects to Tailscale using auth key from environment variables
.DESCRIPTION
    This script connects the machine to Tailscale using an authentication key
    stored in GitHub secrets. It includes extensive error checking and logging.
#>

try {
    # 1. Verify Tailscale executable is available
    try {
        $tailscalePath = Get-Command tailscale -ErrorAction Stop | Select-Object -ExpandProperty Source
        Write-Output "[INFO] Tailscale found at: $tailscalePath"
    } catch {
        throw "Tailscale CLI not found. Please ensure Tailscale is installed and in PATH. Original error: $_"
    }

    # 2. Validate auth key from environment
    $authKey = $env:TAILSCALE_AUTH_KEY
    if (-not $authKey) {
        throw "TAILSCALE_AUTH_KEY environment variable not set. Check GitHub secrets."
    }
    
    if (-not $authKey.StartsWith("tskey-auth-")) {
        throw "Invalid Tailscale auth key format. Key should start with 'tskey-auth-'"
    }

    # 3. Connect to Tailscale network
    Write-Output "[INFO] Connecting to Tailscale network..."
    & tailscale up --auth-key=$authKey --unattended --reset
    
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
    
    exit 0
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
