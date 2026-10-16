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
    # Some launchers relocate themselves. Resolve the actual installed target.
    $target = 'C:\AgentLab\launcher.exe'
    for ($i=0; $i -lt 30; $i++) {
        Start-Sleep 2
        $links = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter *.lnk | ForEach-Object { $w.CreateShortcut($_.FullName) }
        $installed = $links | Where-Object { $_.TargetPath -notmatch 'Program Files' -and (Test-Path -LiteralPath $_.TargetPath) } | Select-Object -First 1
        if ($installed) { $target=$installed.TargetPath; break }
    }
    New-Item -ItemType Directory -Force '\\host.lan\Data\evidence' | Out-Null
    $target | Set-Content '\\host.lan\Data\evidence\launcher-target.txt' -Encoding UTF8
}
Stop-Transcript
