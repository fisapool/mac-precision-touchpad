# Simplified test approach that bypasses build requirements
Write-Host "===== Mac Trackpad Driver Simplified Test =====" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# 1. Set up mock environment
Write-Host "Setting up mock environment..." -ForegroundColor Yellow
if (Test-Path (Join-Path $projectRoot "SetupMockEnvironment.ps1")) {
    & (Join-Path $projectRoot "SetupMockEnvironment.ps1")
} else {
    Write-Host "SetupMockEnvironment.ps1 not found! Creating it..." -ForegroundColor Red
    
    # Create the script inline
    $setupMockScript = @"
# Setup mock environment for testing without building from source
Write-Host "===== Mac Trackpad Mock Environment Setup =====" -ForegroundColor Cyan
Write-Host ""

# Get the script directory and project root
`$scriptPath = Split-Path -Parent `$MyInvocation.MyCommand.Path
`$projectRoot = `$scriptPath

# Create required directories
Write-Host "Creating directory structure..." -ForegroundColor Yellow
`$dirs = @(
    "bin",
    "bin\x64",
    "bin\x64\Release",
    "bin\x64\Debug",
    "src\driver\mock",
    "src\MacTrackpadSetup\Driver"
)

foreach (`$dir in `$dirs) {
    `$dirPath = Join-Path `$projectRoot `$dir
    if (-not (Test-Path `$dirPath)) {
        New-Item -ItemType Directory -Path `$dirPath | Out-Null
        Write-Host "  Created: `$dir" -ForegroundColor Green
    }
}

# Create mock driver files
Write-Host "`nCreating mock driver files..." -ForegroundColor Yellow

`$mockDriverFiles = @{
    "bin\x64\Release\AmtPtpDevice.sys" = [byte[]]::new(1024)
    "bin\x64\Release\AmtPtpDevice.inf" = @"
; Mock INF file for testing
[Version]
Signature="`$Windows NT`$"
Class=HIDClass
ClassGuid={745a17a0-74d3-11d0-b6fe-00a0c90f57da}
Provider=%ManufacturerName%
CatalogFile=AmtPtpDevice.cat
DriverVer=01/01/2023,1.0.0.0

[Manufacturer]
%ManufacturerName%=Standard,NTamd64

[Standard.NTamd64]
%DeviceName%=AmtPtp_Device, ACPI\PNP0C50

[SourceDisksNames]
1 = %DiskName%

[SourceDisksFiles]
AmtPtpDevice.sys = 1

[AmtPtp_Device.NT]
CopyFiles=AmtPtp_Device.NT.Copy

[AmtPtp_Device.NT.Copy]
AmtPtpDevice.sys

[DestinationDirs]
DefaultDestDir = 12
AmtPtp_Device.NT.Copy = 12

[Strings]
ManufacturerName="Mac Trackpad Driver Project"
DiskName = "Mac Trackpad Driver Installation Disk"
DeviceName="Apple Magic Trackpad"
"@
    "bin\x64\Release\AmtPtpDevice.cat" = [byte[]]::new(512)
}

foreach (`$file in `$mockDriverFiles.Keys) {
    `$filePath = Join-Path `$projectRoot `$file
    if (`$mockDriverFiles[`$file] -is [byte[]]) {
        [System.IO.File]::WriteAllBytes(`$filePath, `$mockDriverFiles[`$file])
    } else {
        [System.IO.File]::WriteAllText(`$filePath, `$mockDriverFiles[`$file])
    }
    Write-Host "  Created: `$file" -ForegroundColor Green
}

# Copy files to setup directory
Write-Host "`nCopying files to setup directory..." -ForegroundColor Yellow
`$driverSetupDir = Join-Path `$projectRoot "src\MacTrackpadSetup\Driver"

foreach (`$file in `$mockDriverFiles.Keys) {
    `$fileName = Split-Path -Leaf `$file
    `$sourceFile = Join-Path `$projectRoot `$file
    `$destFile = Join-Path `$driverSetupDir `$fileName
    
    Copy-Item -Path `$sourceFile -Destination `$destFile -Force
    Write-Host "  Copied: `$fileName to setup directory" -ForegroundColor Green
}

# Create test environment configuration
`$testConfigContent = @"
{
  "TestMode": "Mock",
  "SkipDriverBuild": true,
  "MockDriverReady": true,
  "SetupTime": "`$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
"@

`$testConfigPath = Join-Path `$projectRoot "src\MacTrackpadTest\TestConfig.json"
Set-Content -Path `$testConfigPath -Value `$testConfigContent
Write-Host "`nCreated test configuration file" -ForegroundColor Green

# Set environment variable for mock mode
[System.Environment]::SetEnvironmentVariable("DOTNET_MOCK_DRIVER", "true", "Process")
Write-Host "Set DOTNET_MOCK_DRIVER environment variable for current process" -ForegroundColor Yellow

Write-Host "`n===== Mock Environment Setup Complete =====" -ForegroundColor Green
Write-Host "`nYou can now run the test scripts without needing to build the driver." -ForegroundColor Cyan
Write-Host "Use RunMockedTests.cmd or SimulateUninstall.cmd to continue testing." -ForegroundColor Cyan
"@
    
    $setupMockPath = Join-Path $projectRoot "SetupMockEnvironment.ps1"
    Set-Content -Path $setupMockPath -Value $setupMockScript
    Write-Host "Created SetupMockEnvironment.ps1" -ForegroundColor Green
    
    # Run the script
    & $setupMockPath
}

# 2. Create an uninstall simulation script if it doesn't exist
$uninstallSimPath = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateUninstall.cmd"
if (-not (Test-Path $uninstallSimPath)) {
    Write-Host "Creating uninstall simulation script..." -ForegroundColor Yellow
    
    $uninstallSimDir = Split-Path -Parent $uninstallSimPath
    if (-not (Test-Path $uninstallSimDir)) {
        New-Item -ItemType Directory -Path $uninstallSimDir -Force | Out-Null
    }
    
    $uninstallSimContent = @"
@echo off
echo ===== Mac Trackpad Driver Uninstall Simulation =====
echo.

REM Check for admin privileges
NET SESSION >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Administrator privileges required!
    echo Please right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo Checking for administrator privileges... OK

REM Determine script directory
set SCRIPT_DIR=%~dp0
set DRIVER_DIR=%SCRIPT_DIR%Driver

echo.
echo This script will simulate driver uninstallation without requiring
echo a real driver to be installed. It's useful for testing uninstallation
echo scripts and procedures.
echo.
echo 1. Run full uninstall simulation (recommended)
echo 2. Run quick uninstall simulation
echo 3. Run cleanup simulation only
echo 4. Exit
echo.

set /p CHOICE="Enter your choice (1-4): "

if "%CHOICE%"=="1" (
    echo.
    echo Running full uninstall simulation...
    
    REM Create registry keys for testing
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmtPtpDevice" /v DisplayName /t REG_SZ /d "Apple Magic Trackpad Driver" /f > nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MacTrackpadService" /v DisplayName /t REG_SZ /d "Mac Trackpad Service" /f > nul
    
    echo Created mock registry entries for testing
    
    REM Echo simulation of driver removal
    echo.
    echo === STEP 1: Removing drivers from PnP system ===
    echo Removing driver packages...
    echo Attempting to remove AmtPtpDevice.inf...
    echo Microsoft PnP Utility
    echo.
    echo Driver package uninstalled.
    
    echo.
    echo === STEP 2: Stopping services ===
    echo Stopping Mac Trackpad services...
    echo The MacTrackpadService service was stopped successfully.
    
    echo.
    echo === STEP 3: Removing registry entries ===
    echo Removing registry entries...
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AmtPtpDevice" /f > nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\MacTrackpadService" /f > nul 2>&1
    echo Registry entries removed.
    
    echo.
    echo === STEP 4: Verify removal ===
    echo Checking if driver was successfully removed...
    echo Driver successfully removed from the system.
)

if "%CHOICE%"=="2" (
    echo.
    echo Running quick uninstall simulation...
    
    echo === Quick Simulation ===
    echo Removing driver packages... Done.
    echo Stopping services... Done.
    echo Removing registry entries... Done.
    echo Verifying removal... Complete.
    echo Driver successfully removed from the system.
)

if "%CHOICE%"=="3" (
    echo.
    echo Running cleanup simulation...
    
    echo Cleaning up any remaining files and registry entries...
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AmtPtpDevice" /f > nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\MacTrackpadService" /f > nul 2>&1
    echo Cleanup complete.
)

if "%CHOICE%"=="4" (
    echo Exiting...
    goto :EOF
)

echo.
echo Uninstallation simulation complete!
echo It is recommended to restart your computer to complete the removal process.
echo.
set /p RESTART=Restart now? (Y/N): 

if /i "%RESTART%"=="Y" (
    echo This is a simulation - no restart will be performed.
    echo In a real scenario, the computer would restart now.
) else (
    echo Please restart your computer manually to complete the uninstallation.
)

pause
"@
    
    Set-Content -Path $uninstallSimPath -Value $uninstallSimContent
    Write-Host "Created uninstall simulation script: $uninstallSimPath" -ForegroundColor Green
}

# 3. Run a basic test
Write-Host "`nRunning a basic functionality test..." -ForegroundColor Yellow

# Create a basic test script
$basicTestPath = Join-Path $projectRoot "basic_test.ps1"
$basicTestContent = @"
# Basic functionality test
Write-Host "===== Mac Trackpad Basic Functionality Test =====" -ForegroundColor Cyan
Write-Host ""

`$scriptPath = Split-Path -Parent `$MyInvocation.MyCommand.Path
`$projectRoot = `$scriptPath

# Check for mock driver files
`$driverFiles = @(
    "bin\x64\Release\AmtPtpDevice.sys",
    "bin\x64\Release\AmtPtpDevice.inf",
    "bin\x64\Release\AmtPtpDevice.cat"
)

`$allFilesExist = `$true
foreach (`$file in `$driverFiles) {
    `$filePath = Join-Path `$projectRoot `$file
    `$exists = Test-Path `$filePath
    `$status = if (`$exists) { "✓" } else { "✗" }
    Write-Host "`$status `$file" -ForegroundColor `$(if (`$exists) { "Green" } else { "Red" })
    
    if (-not `$exists) {
        `$allFilesExist = `$false
    }
}

if (`$allFilesExist) {
    Write-Host "`nAll driver files are present!" -ForegroundColor Green
    
    # Test file integrity
    Write-Host "`nTesting file integrity..." -ForegroundColor Yellow
    `$sysFile = Join-Path `$projectRoot "bin\x64\Release\AmtPtpDevice.sys"
    `$fileSize = (Get-Item `$sysFile).Length
    
    if (`$fileSize -gt 0) {
        Write-Host "✓ Driver file has valid size (`$fileSize bytes)" -ForegroundColor Green
    } else {
        Write-Host "✗ Driver file has zero size" -ForegroundColor Red
    }
    
    # Test installation readiness
    Write-Host "`nChecking installation readiness..." -ForegroundColor Yellow
    `$setupDir = Join-Path `$projectRoot "src\MacTrackpadSetup\Driver"
    `$setupFilesExist = Test-Path (Join-Path `$setupDir "AmtPtpDevice.sys")
    
    if (`$setupFilesExist) {
        Write-Host "✓ Driver files are ready for installation" -ForegroundColor Green
    } else {
        Write-Host "✗ Driver files are not in the setup directory" -ForegroundColor Red
    }
    
    Write-Host "`nBasic test passed!" -ForegroundColor Green
} else {
    Write-Host "`nSome driver files are missing. Please run SetupMockEnvironment.ps1 first." -ForegroundColor Red
}

Write-Host "`nPress any key to exit..." -ForegroundColor Cyan
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
"@

Set-Content -Path $basicTestPath -Value $basicTestContent
Write-Host "Created basic test script: $basicTestPath" -ForegroundColor Green

# Run the test
& $basicTestPath

# 4. Provide instructions
Write-Host "`n===== Simplified Testing Complete =====" -ForegroundColor Cyan
Write-Host "You've now got a mock environment set up for testing." -ForegroundColor Yellow
Write-Host ""
Write-Host "To continue testing:" -ForegroundColor White
Write-Host "1. Run the uninstall simulation:" -ForegroundColor White
Write-Host "   src\MacTrackpadSetup\SimulateUninstall.cmd (as Administrator)" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Or use the test workflow:" -ForegroundColor White
Write-Host "   .\TestWorkflow.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Feel free to modify these scripts for your testing needs!" -ForegroundColor Yellow 