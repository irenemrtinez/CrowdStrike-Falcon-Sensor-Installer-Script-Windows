<#
 CrowdStrike Falcon Sensor - Windows Installation Script
 Supported: Windows 10 / 11 / Windows Server 2012+
#>
# --------------------------------------------------------------------------
-
# Configuration
# --------------------------------------------------------------------------
-
$InstallerPath = Join-Path $env:TEMP “FalconSensor_Windows.exe”
$CID = “PUT-YOUR-CID-HERE”
$SensorTags = “Lab”
$CSDomain = “falcon.eu-1.crowdstrike.com”
$LogFile = “.\FalconSensor_Windows_Install.log”
# --------------------------------------------------------------------------
-
# Logging helper
# --------------------------------------------------------------------------
-
function Write-Log {
 param([string]$Message)
 $line = “[{0}] {1}” -f (Get-Date -Format “yyyy-MM-dd HH:mm:ss”),
$Message
 Write-Host $line
 Add-Content -Path $LogFile -Value $line
}
Write-Log “===== Starting Falcon Sensor Windows Installation Script =====”
# --------------------------------------------------------------------------
-
# 1) Check required Windows services
# --------------------------------------------------------------------------
-
$RequiredServices = @(“lmhosts”,”nsi”,”bfe”)
$ServicesOK = $true
foreach ($svc in $RequiredServices) {
 try {
 $service = Get-Service -Name $svc -ErrorAction Stop
 if ($service.Status -ne “Running”) {
 Write-Log “Service ‘$svc’ not running. Attempting to start...”
 Start-Service -Name $svc -ErrorAction Stop
 Write-Log “Service ‘$svc’ started.”
 } else {
 Write-Log “Service ‘$svc’ is already running.”
 }
 }
 catch {
 Write-Log “ERROR: Required service ‘$svc’ is missing or cannot be
started.”
 $ServicesOK = $false
 }
}
if (-not $ServicesOK) {
 Write-Log “ERROR: Missing required services. Aborting installation.”
 exit 1
136
}
# --------------------------------------------------------------------------
-
# 2) Connectivity test to CrowdStrike Cloud (EU-1)
# --------------------------------------------------------------------------
-
Write-Log “Checking connectivity to CrowdStrike Cloud ($CSDomain:443)...”
$connection = Test-NetConnection -ComputerName $CSDomain -Port 443 -
WarningAction SilentlyContinue
if (-not $connection.TcpTestSucceeded) {
 Write-Log “ERROR: Cannot reach CrowdStrike Cloud. Check firewall or
proxy.”
 exit 1
}
Write-Log “Connectivity OK.”
# --------------------------------------------------------------------------
-
# 3) Verify installer presence
# --------------------------------------------------------------------------
-
if (-not (Test-Path $InstallerPath)) {
 Write-Log “ERROR: Installer not found at $InstallerPath”
 exit 1
}
# --------------------------------------------------------------------------
-
# 4) Install Falcon Sensor
# --------------------------------------------------------------------------
-
$Args = “/install /quiet /norestart CID=$CID GROUPING_TAGS=‘”$SensorTags‘””
Write-Log “Running installer with arguments: $Args”
$process = Start-Process -FilePath $InstallerPath -ArgumentList $Args -Wait
-PassThru
Write-Log “Installer finished with exit code: $($process.ExitCode)”
if ($process.ExitCode -ne 0) {
 Write-Log “ERROR: Falcon Sensor installation failed.”
 exit 1
}
# --------------------------------------------------------------------------
-
# 5) Verify Falcon service
# --------------------------------------------------------------------------
-
$csagent = Get-Service -Name csagent -ErrorAction SilentlyContinue
if ($csagent -and $csagent.Status -eq “Running”) {
 Write-Log “Falcon Sensor service is running.”
} else {
 Write-Log “WARNING: Falcon Sensor service is not running.”
}
Write-Log “===== Falcon Sensor Windows installation completed =====”
exit 0
