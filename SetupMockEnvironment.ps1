# Setup mock environment for testing without building from source
Write-Host "===== Mac Trackpad Mock Environment Setup =====" -ForegroundColor Cyan
Write-Host ""

# Get the script directory and project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# Create required directories
Write-Host "Creating directory structure..." -ForegroundColor Yellow
$dirs = @(
    "bin",
    "bin\x64",
    "bin\x64\Release",
    "bin\x64\Debug",
    "src\driver\mock",
    "src\MacTrackpadSetup\Driver"
)

foreach ($dir in $dirs) {
    $dirPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    }
}

# Create mock driver files
Write-Host "`nCreating mock driver files..." -ForegroundColor Yellow

$mockDriverFiles = @{
    "bin\x64\Release\AmtPtpDevice.sys" = [byte[]]::new(1024)
    "bin\x64\Release\AmtPtpDevice.inf" = @"
; Mock INF file for testing
[Version]
Signature="$Windows NT$"
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

foreach ($file in $mockDriverFiles.Keys) {
    $filePath = Join-Path $projectRoot $file
    if ($mockDriverFiles[$file] -is [byte[]]) {
        [System.IO.File]::WriteAllBytes($filePath, $mockDriverFiles[$file])
    } else {
        [System.IO.File]::WriteAllText($filePath, $mockDriverFiles[$file])
    }
    Write-Host "  Created: $file" -ForegroundColor Green
}

# Copy files to setup directory
Write-Host "`nCopying files to setup directory..." -ForegroundColor Yellow
$driverSetupDir = Join-Path $projectRoot "src\MacTrackpadSetup\Driver"

foreach ($file in $mockDriverFiles.Keys) {
    $fileName = Split-Path -Leaf $file
    $sourceFile = Join-Path $projectRoot $file
    $destFile = Join-Path $driverSetupDir $fileName
    
    Copy-Item -Path $sourceFile -Destination $destFile -Force
    Write-Host "  Copied: $fileName to setup directory" -ForegroundColor Green
}

# Create test environment configuration
$testConfigContent = @"
{
  "TestMode": "Mock",
  "SkipDriverBuild": true,
  "MockDriverReady": true,
  "SetupTime": "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
"@

$testConfigPath = Join-Path $projectRoot "src\MacTrackpadTest\TestConfig.json"
Set-Content -Path $testConfigPath -Value $testConfigContent
Write-Host "`nCreated test configuration file" -ForegroundColor Green

# Set environment variable for mock mode
[System.Environment]::SetEnvironmentVariable("DOTNET_MOCK_DRIVER", "true", "Process")
Write-Host "Set DOTNET_MOCK_DRIVER environment variable for current process" -ForegroundColor Yellow

Write-Host "`n===== Mock Environment Setup Complete =====" -ForegroundColor Green
Write-Host "`nYou can now run the test scripts without needing to build the driver." -ForegroundColor Cyan
Write-Host "Use RunMockedTests.cmd or ConfigureTestMode.cmd to continue testing." -ForegroundColor Cyan

Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")