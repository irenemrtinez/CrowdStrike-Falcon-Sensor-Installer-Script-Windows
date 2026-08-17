<#
 CrowdStrike Falcon Sensor - Windows 7 / Server 2008 R2 Installation Script
#>
# Configuration
$InstallerPath = Join-Path $env:TEMP “WindowsSensor.LionLanner.exe”
$CID = “PUT-YOUR-CID-HERE”
$SensorTags = “Lab”
$CSDomain = “falcon.eu-1.crowdstrike.com”
$LogFile = “.\FalconSensor_WindowsLegacy_Install.log”
$RequiredKBs = @(“KB3033929”,”KB3063858”)
function Write-Log {
 param([string]$Message)
 $line = “[{0}] {1}” -f (Get-Date -Format “yyyy-MM-dd HH:mm:ss”), $Message
 Write-Host $line
 Add-Content -Path $LogFile -Value $line
}
Write-Log “===== Starting Falcon Sensor Windows legacy Installation =====”
# 1) Check SHA-2 prerequisites
foreach ($kb in $RequiredKBs) {
 if (-not (Get-HotFix -Id $kb -ErrorAction SilentlyContinue)) {
 Write-Log “ERROR: Missing required update $kb”
 exit 1
 }
 Write-Log “$kb is installed.”
}
# 2) Check required services
$RequiredServices = @(“lmhosts”,”nsi”,”bfe”)
foreach ($svc in $RequiredServices) {
 try {
 $service = Get-Service -Name $svc -ErrorAction Stop
 if ($service.Status -ne “Running”) {
 Start-Service -Name $svc -ErrorAction Stop
 Write-Log “Service ‘$svc’ started.”
 }
 }
 catch {
 Write-Log “ERROR: Required service ‘$svc’ is missing.”
 exit 1
 }
}
# 3) Connectivity test (Windows 7 and windows 2008 compatible)
function Test-TCP443 {
 param([string]$TargetHost)
 try {
 $ip = [System.Net.Dns]::GetHostAddresses($TargetHost)[0]
 $client = New-Object System.Net.Sockets.TcpClient
 $res = $client.BeginConnect($ip,443,$null,$null)
 $ok = $res.AsyncWaitHandle.WaitOne(4000,$false)
 $client.Close()
 return $ok
 }
 catch {
 return $false
 }
}
Write-Log “Checking connectivity to CrowdStrike Cloud...”
if (-not (Test-TCP443 $CSDomain)) {
 Write-Log “ERROR: Cannot reach CrowdStrike Cloud.”
 exit 1
}
138
# 4) Install Falcon Sensor (official installer syntax)
if (-not (Test-Path $InstallerPath)) {
 Write-Log “ERROR: Installer not found at $InstallerPath”
 exit 1
}
$Args = “/install /quiet /norestart CID=$CID GROUPING_TAGS=‘”$SensorTags‘””
Write-Log “Running installer with arguments: $Args”
$process = Start-Process -FilePath $InstallerPath -ArgumentList $Args -Wait -
PassThru
Write-Log “Installer finished with exit code: $($process.ExitCode)”
if ($process.ExitCode -ne 0) {
 Write-Log “ERROR: Falcon Sensor installation failed.”
 exit 1
}
# 5) Verify Falcon Sensor service (csagent)
Write-Log “Verifying Falcon Sensor service status...”
$FalconService = Get-Service -Name csagent -ErrorAction SilentlyContinue
if ($FalconService -and $FalconService.Status -eq “Running”) {
 Write-Log “Falcon Sensor service is running.”
} else {
 Write-Log “WARNING: Falcon Sensor service is not running.”
}
Write-Log “===== Falcon Sensor Windows legacy installation completed =====”
exit 0 
