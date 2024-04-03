<#
.SYNOPSIS
    This script installs OpenVPN client on a Windows system if it's not already installed or if the installed version is not 1.1.1.

.DESCRIPTION
    This script checks if OpenVPN client is installed on the system and checks installed version. 
    If OpenVPN is not installed or its version is not 1.1.1, then, it downloads the target version and installs it. 
    Otherwise it displays that OpenVPN is already installed and the installed version is displayed.

.PARAMETER targetVersion
    The default target version of OpenVPN for installing is "2.2.2".

.NOTES
    File Name: Install-OpenVPN.ps1
    Author: MMB
    Version: 1.0
    Date: April 2, 2024

#>

param (
    [string]$targetVersion = "2.2.2"
)

# Variables
# URL for downloading the OpenVPN installer
$openvpnUrl = "https://github.com/mmbazm/install_openvpn/blob/main/files/openvpn-$targetVersion-install.exe"

# path to store the installer
$InstallerPath = "$env:TEMP\openvpn-install.exe"



# Check if OpenVPN is installed and its version. If already installed return the version otherwise null value
function Get-OpenVPNVersion {
    
    $installedVersion = (Get-Package -Name OpenVPN* -ErrorAction SilentlyContinue).Version
    if ($installedVersion -eq $null) {
        return $null
    }
    return $installedVersion
}

# Check if OpenVPN is already installed and its version
$installedVersion = Get-OpenVPNVersion

# Check if OpenVPN is not installed or its version is 1.1.1
if ($installedVersion -eq $null -or $installedVersion -eq "1.1.1") {

    # Try downloading OpenVPN client installer
    try {
        Write-Host "Downloading OpenVPN installer version $targetVersion..."
        Invoke-WebRequest -Uri $openvpnUrl -OutFile $InstallerPath

        # Start the installer
        Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait -NoNewWindow

        # Clean up the downloaded installer
        Remove-Item $InstallerPath

        # Final message
        Write-Host "OpenVPN version $targetVersion has been successfully installed."
    }
    catch {
        Write-Host "Failed to download OpenVPN client installer: $_.Exception.Message"
    }

} else {
    Write-Host "OpenVPN client [$($installedVersion)] is already installed."
}