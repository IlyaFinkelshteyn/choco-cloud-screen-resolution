﻿$ErrorActionPreference = 'Stop'; # stop on all errors

$toolsDir      = Split-Path $MyInvocation.MyCommand.Definition
$packageName   = $env:ChocolateyPackageName
$pp            = Get-PackageParameters
$name          = "Cloud Screen Resolution"
$toolsLocation = Get-ToolsLocation
$displayDir    = "$toolsLocation\$packageName"


if (!$pp["username"]) { $pp["username"] = "$env:UserName" }
if (!$pp['password']) { throw "Package requires parameter 'password' to install." }

if (!$pp["rdpUsername"]) { $pp["rdpUsername"] = 'rdp_local' }
if (!$pp['rdpPassword']) { $pp['rdpPassword'] = $pp['password'] }

if (!$pp["width"]) { $pp["width"] = 1920 }
if (!$pp["height"]) { $pp["height"] = 1080 }

if (!$pp["rdpGroups"]) { $pp["rdpGroups"] = @('Administrators', 'Remote Desktop Users') }

if (!(Test-Path $displayDir)) {
  New-Item $displayDir -ItemType directory -Force
}

$ErrorActionPreference = "SilentlyContinue"

$secRdpPassword = ConvertTo-SecureString -String $pp['rdpPassword'] -AsPlainText -Force
New-LocalUser $pp["rdpUsername"] -Password $secRdpPassword -PasswordNeverExpires -UserMayNotChangePassword

ForEach ($group In $pp["rdpGroups"]) {
	Add-LocalGroupMember -Group "$group" -Member $pp["rdpUsername"]
}

$ErrorActionPreference = "Stop";

$TaskName = "CreateRdpHome"
$Action = New-ScheduledTaskAction -Execute "cmdkey.exe" -Argument "/add:localhost /user:$($pp["username"]) /pass:$($pp["password"])"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $TaskName -User $pp["rdpUsername"] -Password $pp['rdpPassword'] -Action $Action -Settings $Settings -RunLevel Highest -Force
Start-ScheduledTask -TaskName $TaskName

$timer =  [Diagnostics.Stopwatch]::StartNew()
while (((Get-ScheduledTask -TaskName $TaskName).State -ne  'Ready') -and  ($timer.Elapsed.TotalSeconds -lt 90)) {
  Write-Debug -Message "Waiting on scheduled task..."
  Start-Sleep -Seconds  3
}
$timer.Stop()

Unregister-ScheduledTask -TaskName $TaskName

$cmdName = "RDP-to-$($pp["username"])-at-res$($pp["width"])x$($pp["height"])"
$cmdPath = "$displayDir\$cmdName.cmd"

Write-Debug "$name - command path: $cmdPath"

$cmd = "mstsc.exe /v localhost /w:$($pp["width"]) /h:$($pp["height"])"
$cmd | Set-Content $cmdPath


$startupDir = "C:\Users\$($pp["rdpUsername"])\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

if (!(Test-Path $startupDir)) {
  New-Item $startupDir -ItemType Directory -Force
}

$shortcutArgs = @{
  shortcutFilePath = "$startupDir\$cmdName.lnk"
  targetPath       = "$cmdPath"
  iconLocation     = "$toolsDir\icon.ico"
  workDirectory    = $displayDir
}
Install-ChocolateyShortcut @shortcutArgs

# required by uninstaller to remove startup script
"rdpUsername=$($pp["rdpUsername"])" | Set-Content $toolsDir\uninstall.parameters

Write-Debug "$name - autostart: $startupDir\$cmdName.lnk"

# https://technet.microsoft.com/en-us/library/cc722151%28v=ws.10%29.aspx
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0

# http://www.mytecbits.com/microsoft/windows/rdp-identity-of-the-remote-computer
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Terminal Server Client" -Name "AuthenticationLevelOverride" -Type DWord -Value 0

$rules = Get-NetFirewallRule
$par = @{
  DisplayName   = "$name"
  LocalPort     = 3389
  LocalAddress  = "any"
  RemoteAddress = "LocalSubnet"
  Profile       = "Public"
  Direction     = "Inbound"
  Protocol      = "TCP"
  Action        = "Allow"
}
if (-not $rules.DisplayName.Contains($par.DisplayName)) {
  New-NetFirewallRule @par
  Write-Debug "$name - firewall: $par"
}
