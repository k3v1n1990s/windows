$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force C:\AgentLab | Out-Null
Start-Transcript -Path C:\AgentLab\bootstrap.log -Append
# Firewall rule names are language independent.
Get-NetFirewallRule -Name 'RemoteDesktop*' | Enable-NetFirewallRule
Set-WinSystemLocale zh-CN
Set-TimeZone -Id 'China Standard Time'
$source = '\\host.lan\Data\launcher.exe'
for ($i=0; $i -lt 30 -and !(Test-Path $source); $i++) { Start-Sleep 2 }
if (Test-Path $source) {
    Copy-Item $source C:\AgentLab\launcher.exe -Force
    $w = New-Object -ComObject WScript.Shell
    $link=$w.CreateShortcut("$env:PUBLIC\Desktop\Mir Launcher.lnk")
    $link.TargetPath='C:\AgentLab\launcher.exe'
    $link.WorkingDirectory='C:\AgentLab'
    $link.Save()
    # Explicit task goal: launch the downloaded client in this guest only.
    Start-Process C:\AgentLab\launcher.exe -WorkingDirectory C:\AgentLab
}
Stop-Transcript
