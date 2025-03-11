#Requires -RunAsAdministrator

param (
    [switch]$CollectLogs = $true,
    [switch]$FixCommonIssues = $false,
    [string]$LogPath = ".\MacTrackpadDiagnostics"
)

$ErrorActionPreference = "Continue"

Write-Host "===== Mac Trackpad Driver Diagnostic Tool =====" -ForegroundColor Cyan
Write-Host ""

# Create log directory
if ($CollectLogs) {
    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $sessionLogPath = Join-Path $LogPath "DiagnosticSession_$timestamp"
    New-Item -ItemType Directory -Path $sessionLogPath | Out-Null
    
    Write-Host "Logs will be saved to: $sessionLogPath" -ForegroundColor Yellow
    Write-Host ""
}

# Function to log diagnostic information
function Log-Diagnostic {
    param (
        [string]$Section,
        [string]$Result,
        [string]$Details,
        [string]$Status
    )
    
    switch ($Status) {
        "OK" { $color = "Green" }
        "Warning" { $color = "Yellow" }
        "Error" { $color = "Red" }
        default { $color = "White" }
    }
    
    Write-Host "[$Section] " -NoNewline -ForegroundColor Cyan
    Write-Host "$Result" -NoNewline -ForegroundColor $color
    
    if (-not [string]::IsNullOrEmpty($Details)) {
        Write-Host ": $Details"
    } else {
        Write-Host ""
    }
    
    if ($CollectLogs) {
        $logEntry = "[$Section] [$Status] $Result"
        if (-not [string]::IsNullOrEmpty($Details)) {
            $logEntry += ": $Details"
        }
        
        Add-Content -Path (Join-Path $sessionLogPath "diagnostic.log") -Value $logEntry
    }
}

# Check driver installation
Write-Host "Checking driver installation..." -ForegroundColor Green

$driverPresent = $false
$driverInfo = pnputil /enum-drivers | Select-String -Pattern "AmtPtpDevice"

if ($driverInfo) {
    $driverPresent = $true
    Log-Diagnostic -Section "Driver" -Result "Driver is installed" -Status "OK"
    
    # Extract driver version and date
    $driverVersion = ($driverInfo -split "`n" | Select-String -Pattern "Driver Version") -replace ".*Driver Version: ", ""
    Log-Diagnostic -Section "Driver" -Result "Driver version: $driverVersion" -Status "OK"
} else {
    Log-Diagnostic -Section "Driver" -Result "Driver is not installed" -Status "Error" -Details "The Mac Trackpad driver is not installed on this system"
}

# Check device presence
Write-Host "`nChecking for Mac Trackpad devices..." -ForegroundColor Green

$deviceFound = $false
$deviceInfo = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Trackpad*" -or $_.FriendlyName -like "*Apple*" -or $_.HardwareID -like "*APPLE*" }

if ($deviceInfo) {
    $deviceFound = $true
    foreach ($device in $deviceInfo) {
        $status = $device.Status
        $statusText = if ($status -eq "OK") { "Working properly" } else { $status }
        $statusLevel = if ($status -eq "OK") { "OK" } else { "Error" }
        
        Log-Diagnostic -Section "Device" -Result "Device found: $($device.FriendlyName)" -Status $statusLevel -Details $statusText
    }
} else {
    Log-Diagnostic -Section "Device" -Result "No Mac Trackpad devices found" -Status "Warning" -Details "Connect your Mac Trackpad and ensure it's powered on"
}

# Check dashboard installation
Write-Host "`nChecking dashboard installation..." -ForegroundColor Green

$dashboardInstalled = $false
$dashboardInfo = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*Mac Trackpad Dashboard*" }

if ($dashboardInfo) {
    $dashboardInstalled = $true
    Log-Diagnostic -Section "Dashboard" -Result "Dashboard is installed" -Status "OK" -Details "Version: $($dashboardInfo.DisplayVersion)"
} else {
    Log-Diagnostic -Section "Dashboard" -Result "Dashboard is not installed" -Status "Warning" -Details "Consider installing the dashboard for better trackpad control"
}

# Check system configuration
Write-Host "`nChecking system configuration..." -ForegroundColor Green

# Check Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osVersion = "$($osInfo.Caption) (Version: $($osInfo.Version))"
Log-Diagnostic -Section "System" -Result "Operating System: $osVersion" -Status "OK"

# Check for Windows updates related to HID
$hidUpdates = Get-HotFix | Where-Object { $_.Description -like "*update*" -and $_.HotFixID -like "*KB*" } | Sort-Object -Property InstalledOn -Descending | Select-Object -First 5
if ($hidUpdates) {
    Log-Diagnostic -Section "System" -Result "Recent Windows updates found" -Status "OK" -Details "$($hidUpdates.Count) updates"
    
    if ($CollectLogs) {
        $hidUpdates | Format-Table -AutoSize | Out-File -FilePath (Join-Path $sessionLogPath "recent_updates.txt")
    }
} else {
    Log-Diagnostic -Section "System" -Result "No recent Windows updates found" -Status "Warning" -Details "Check for Windows updates"
}

# Check USB controllers
$usbControllers = Get-PnpDevice -Class USB | Where-Object { $_.Status -ne "OK" }
if ($usbControllers) {
    Log-Diagnostic -Section "System" -Result "USB controller issues found" -Status "Warning" -Details "$($usbControllers.Count) controllers with issues"
    
    if ($CollectLogs) {
        $usbControllers | Format-Table -AutoSize | Out-File -FilePath (Join-Path $sessionLogPath "usb_issues.txt")
    }
} else {
    Log-Diagnostic -Section "System" -Result "USB controllers working properly" -Status "OK"
}

# Check HID devices
$hidDevices = Get-PnpDevice -Class HIDClass | Where-Object { $_.Status -ne "OK" }
if ($hidDevices) {
    Log-Diagnostic -Section "System" -Result "HID device issues found" -Status "Warning" -Details "$($hidDevices.Count) devices with issues"
    
    if ($CollectLogs) {
        $hidDevices | Format-Table -AutoSize | Out-File -FilePath (Join-Path $sessionLogPath "hid_issues.txt")
    }
} else {
    Log-Diagnostic -Section "System" -Result "HID devices working properly" -Status "OK"
}

# Collect event logs
if ($CollectLogs) {
    Write-Host "`nCollecting event logs..." -ForegroundColor Green
    
    # System logs
    Get-WinEvent -LogName System -MaxEvents 100 | Where-Object { $_.Message -like "*driver*" -or $_.Message -like "*HID*" -or $_.Message -like "*USB*" -or $_.Message -like "*trackpad*" } | 
    Export-Csv -Path (Join-Path $sessionLogPath "system_events.csv") -NoTypeInformation
    
    # Application logs
    Get-WinEvent -LogName Application -MaxEvents 100 | Where-Object { $_.Message -like "*trackpad*" -or $_.Message -like "*dashboard*" } | 
    Export-Csv -Path (Join-Path $sessionLogPath "application_events.csv") -NoTypeInformation
    
    # Export device information
    Get-PnpDevice | Export-Csv -Path (Join-Path $sessionLogPath "all_devices.csv") -NoTypeInformation
    
    # Export driver information
    $driverOutput = pnputil /enum-drivers
    Set-Content -Path (Join-Path $sessionLogPath "all_drivers.txt") -Value $driverOutput
    
    Log-Diagnostic -Section "Logs" -Result "Event logs collected" -Status "OK" -Details "Saved to $sessionLogPath"
}

# Fix common issues if requested
if ($FixCommonIssues) {
    Write-Host "`nAttempting to fix common issues..." -ForegroundColor Green
    
    # Restart HID service
    Restart-Service -Name "HidServ" -Force
    Log-Diagnostic -Section "Fix" -Result "HID service restarted" -Status "OK"
    
    # Scan for hardware changes
    pnputil /scan-devices
    Log-Diagnostic -Section "Fix" -Result "Scanned for hardware changes" -Status "OK"
    
    # Restart services
    Restart-Service -Name "MacTrackpadService" -ErrorAction SilentlyContinue
    if ($?) {
        Log-Diagnostic -Section "Fix" -Result "Mac Trackpad service restarted" -Status "OK"
    }
}

# Generate summary
Write-Host "`n===== Diagnostic Summary =====" -ForegroundColor Cyan

if ($driverPresent) {
    Write-Host "✓ Driver: " -NoNewline -ForegroundColor Green
    Write-Host "Installed"
} else {
    Write-Host "✗ Driver: " -NoNewline -ForegroundColor Red
    Write-Host "Not installed"
}

if ($deviceFound) {
    Write-Host "✓ Device: " -NoNewline -ForegroundColor Green
    Write-Host "Detected"
} else {
    Write-Host "✗ Device: " -NoNewline -ForegroundColor Red
    Write-Host "Not detected"
}

if ($dashboardInstalled) {
    Write-Host "✓ Dashboard: " -NoNewline -ForegroundColor Green
    Write-Host "Installed"
} else {
    Write-Host "! Dashboard: " -NoNewline -ForegroundColor Yellow
    Write-Host "Not installed"
}

# Recommendation
Write-Host "`nRecommendation:" -ForegroundColor Cyan

if (-not $driverPresent) {
    Write-Host "Please install the Mac Trackpad driver using the installer package." -ForegroundColor Yellow
} elseif (-not $deviceFound) {
    Write-Host "Please connect your Mac Trackpad and ensure it's powered on." -ForegroundColor Yellow
} elseif ($deviceInfo.Status -ne "OK") {
    Write-Host "The trackpad device is detected but not working properly. Try reinstalling the driver." -ForegroundColor Yellow
} else {
    Write-Host "The Mac Trackpad driver appears to be working correctly." -ForegroundColor Green
}

if ($CollectLogs) {
    Write-Host "`nDiagnostic logs saved to: $sessionLogPath" -ForegroundColor Cyan
    Write-Host "Please include these logs when contacting support." -ForegroundColor Cyan
}

Write-Host "`n===== Diagnostic Complete =====" -ForegroundColor Cyan 