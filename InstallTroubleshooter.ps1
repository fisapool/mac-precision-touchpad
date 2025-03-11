# Mac Trackpad Driver Installation Troubleshooter
Write-Host "===== Mac Trackpad Driver Installation Troubleshooter =====" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️ Not running as Administrator. Some checks may be limited." -ForegroundColor Yellow
    Write-Host "   Restart this script with administrator privileges for complete diagnostics." -ForegroundColor Yellow
    Write-Host ""
}

# 1. Check for driver files
Write-Host "Checking driver files..." -ForegroundColor Yellow
$setupDir = Join-Path $projectRoot "src\MacTrackpadSetup\Driver"
$requiredDriverFiles = @(
    "AmtPtpDevice.sys",
    "AmtPtpDevice.inf",
    "AmtPtpDevice.cat"
)

$missingFiles = @()
foreach ($file in $requiredDriverFiles) {
    $filePath = Join-Path $setupDir $file
    if (-not (Test-Path $filePath)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "❌ Missing driver files in $setupDir:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "   - $file" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "   Solution: Run setup_build_env.ps1 to recreate mock driver files." -ForegroundColor White
} else {
    Write-Host "✓ All driver files present in setup directory." -ForegroundColor Green
}

# 2. Check for Setup scripts
Write-Host "
Checking for installation scripts..." -ForegroundColor Yellow
$installScript = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateInstall.cmd"
if (-not (Test-Path $installScript)) {
    Write-Host "❌ Installation script missing: $installScript" -ForegroundColor Red
    
    # Create the script if missing
    Write-Host "   Creating installation script..." -ForegroundColor Yellow
    $installContent = @'
@echo off
echo ===== Mac Trackpad Driver Installation =====
echo.
echo Preparing to install driver...
echo Copying driver files...
echo Registering driver in the system...
echo.
echo Installation completed successfully!
echo.
pause
'@
    Set-Content -Path $installScript -Value $installContent
    Write-Host "✓ Created installation script: $installScript" -ForegroundColor Green
} else {
    Write-Host "✓ Installation script exists: $installScript" -ForegroundColor Green
}

# 3. Check for common Windows issues
Write-Host "
Checking Windows driver installation prerequisites..." -ForegroundColor Yellow

# Check if device installation is allowed
$testPolicyValue = $null
try {
    $testPolicyValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall" -Name "DisableDIFunction" -ErrorAction SilentlyContinue
} catch {
    # Policy might not exist, which is fine
}

if ($testPolicyValue -ne $null -and $testPolicyValue.DisableDIFunction -eq 1) {
    Write-Host "❌ Device installation is disabled by policy!" -ForegroundColor Red
    Write-Host "   Solution: Enable device installation in Group Policy or Registry." -ForegroundColor White
} else {
    Write-Host "✓ Device installation is allowed by policy." -ForegroundColor Green
}

Write-Host "
===== Troubleshooting Complete =====" -ForegroundColor Cyan
Write-Host "If you still have installation issues, try the following:" -ForegroundColor White
Write-Host "1. Run setup_build_env.ps1 to recreate all mock files" -ForegroundColor White
Write-Host "2. Ensure you're running scripts as Administrator" -ForegroundColor White
Write-Host "3. Check Windows Event Viewer for driver installation errors" -ForegroundColor White
Write-Host "4. Try running master_test.ps1 -RunAllTests to automate the entire process" -ForegroundColor White
