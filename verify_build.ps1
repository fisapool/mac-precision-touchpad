# Run as Administrator
$ErrorActionPreference = "Stop"

$rootDir = $PSScriptRoot
$buildDir = Join-Path $rootDir "build\x64\Release"

Write-Host "Verifying build environment..." -ForegroundColor Yellow

# Check build directory
if (-not (Test-Path $buildDir)) {
    Write-Host "Error: Build directory not found at: $buildDir" -ForegroundColor Red
    Write-Host "Please run build_driver.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Check required files
$requiredFiles = @(
    "AmtPtpDevice.sys",
    "AmtPtpDevice.inf",
    "AmtPtpDevice.cat"
)

$allFilesPresent = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $buildDir $file
    if (-not (Test-Path $filePath)) {
        Write-Host "Error: Missing required file: $file" -ForegroundColor Red
        $allFilesPresent = $false
    }
}

if (-not $allFilesPresent) {
    Write-Host "Build verification failed. Please rebuild the driver." -ForegroundColor Red
    exit 1
}

Write-Host "Build verification successful!" -ForegroundColor Green
Write-Host "Ready to install driver from: $buildDir" -ForegroundColor Green 