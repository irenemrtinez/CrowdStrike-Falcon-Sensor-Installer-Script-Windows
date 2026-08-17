
# CrowdStrike Falcon Sensor Installer Script

![App Screenshot](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/CrowdStrike_logo.svg/1280px-CrowdStrike_logo.svg.png)

This PowerShell script validates key CrowdStrike requirements for the **European cloud (EU-1)** and installs the CrowdStrike Falcon Sensor on a Windows endpoint when all prerequisites are satisfied. It performs basic environment validation, checks connectivity to the CrowdStrike cloud, and executes a silent installation of the Falcon Sensor using the provided installer. 

The script has been **tested in a Windows environment and successfully performed the installation process when all requirements were met**.

## Deployment

### Requirements

Before running the script, ensure the following:

- Windows system with **PowerShell**
- CrowdStrike installer with the name: `FalconSensor_Windows.exe`
- PowerShell script: `Installer_Windows.ps1` (or `Installer_Windows_Legacy.ps1` for legacy systems)
- Both files must be available on the system
- Permission to run PowerShell scripts

---

### Prepare the Environment

Enable PowerShell script execution for the current session if it's not currently enabled:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Copy Files to the TEMP Directory. For example, you can use:
```powershell
Copy-Item "$HOME\Downloads\Installer_Windows.ps1" -Destination $env:TEMP
Copy-Item "$HOME\Downloads\FalconSensor_Windows.exe" -Destination $env:TEMP
```
Navigate to the TEMP Directory
```powershell
Set-Location $env:TEMP
```
### Configure the CID
Before running the script, you must update the **Customer ID (CID)** inside the script.
To obtain the CID:

    1. Log in to the CrowdStrike Falcon Console
    2. Go to Host Setup and Management
    3. Select Sensor Downloads
    4. Copy the Customer ID (CID) shown on that page

Then open the script (Installer_Windows.ps1 or Installer_Windows_Legacy.ps1) and replace the placeholder value with your CID:

```powershell
# Your CID (Customer ID Checksum)
$CID = "PUT-YOUR-CID-HERE"
```
For example:
```powershell
# Your CID (Customer ID Checksum)
$CID = "1234567890ABCDEF1234567890ABCDEF-12"
```
### Run the script
```powershell
.\Installer_Windows.ps1
or
.\Installer_Windows_Legacy.ps1
```
## Authors
- [@irenemrtinez](https://github.com/irenemrtinez)

## Documentation
The information used in this script regarding required services, system prerequisites, and installation requirements is based on the official CrowdStrike documentation for Falcon Sensor deployment.

[Falcon Sensor Deployment for Windows](https://falcon.eu-1.crowdstrike.com/documentation/page/ecc97e75/falcon-sensor-for-windows-deployment)

[CrowdStrike Cloud IP Addresses and FQDNs](https://falcon.eu-1.crowdstrike.com/documentation/page/e87d1418/cloud-ip-addresses)
