$ErrorActionPreference = 'Stop'; # stop on all errors
$Password = 'vagrant'
$RdpPassword = 'bfnhQ8UXRQ7R4eqb'


##
# Install Chocolatey - https://chocolatey.org
##

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


##
# Install Cloud Screen Resolution
##

choco pack C:\vagrant\cloud-screen-resolution.nuspec --outputdirectory C:\vagrant
choco install -y cloud-screen-resolution --params "'/width:1366 /height:768 /password:$Password /rdpPassword:$RdpPassword'" -d -s C:\vagrant --force


##
# Configure AutoLogon
##

# cleanup previous autologon vagrant setup
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonCount"

choco install -y autologon
autologon rdp_local $env:userdomain $RdpPassword
