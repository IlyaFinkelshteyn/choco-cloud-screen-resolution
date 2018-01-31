$ErrorActionPreference = 'Stop'; # stop on all errors

##
# Install Chocolatey - https://chocolatey.org
##

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


##
# Install Selenium-Grid Dependencies
##

choco install -y nssm --pre
choco install -y googlechrome --ignorechecksum
choco install -y jdk8 selenium-chrome-driver


##
# Install Selenium-Grid
##

choco install -y selenium --params "'/role:hub /service /autostart /log'"
$capabilitiesJson = "C:\tools\selenium\tn8-capabilities.json"
@'
[
  {
    "browserName": "chrome",
    "maxInstances": 5,
    "version": "autoversion",
    "seleniumProtocol": "WebDriver"
  }
]
'@ | New-Item $capabilitiesJson -Type file -Force
choco install -y selenium --params "'/role:node /capabilitiesJson:$capabilitiesJson /autostart /log'" --force


##
# Install Cloud Screen Resolution
##

choco pack C:\vagrant\cloud-screen-resolution.nuspec --outputdirectory C:\vagrant
choco install -y cloud-screen-resolution --params "'/width:1366 /height:768 /password:vagrant /rdpPassword:bfnhQ8UXRQ7R4eqb'" -d -s C:\vagrant --force


##
# Configure AutoLogon
##

# cleanup previous autologon vagrant setup
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonCount"

choco install -y autologon
autologon rdp_local $env:userdomain bfnhQ8UXRQ7R4eqb
