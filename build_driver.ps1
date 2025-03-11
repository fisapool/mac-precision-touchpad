# Run as Administrator
$ErrorActionPreference = "Stop"

# Define paths
$rootDir = $PSScriptRoot
Write-Host "Root directory: $rootDir" -ForegroundColor Yellow

# Find the solution file
$slnFile = Get-ChildItem -Path $rootDir -Recurse -Filter "*.sln" | Select-Object -First 1
if (-not $slnFile) {
    Write-Host "Error: Could not find solution file!" -ForegroundColor Red
    exit 1
}

Write-Host "Found solution: $($slnFile.FullName)" -ForegroundColor Green

# Setup build paths
$buildDir = Join-Path $rootDir "build"
$outputDir = Join-Path $buildDir "x64\Release"

# Create build directory
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Write-Host "Created build directory: $outputDir" -ForegroundColor Green

try {
    # Find Visual Studio installation
    $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
    if (-not $vsPath) {
        throw "Visual Studio not found. Please install Visual Studio 2022 with Windows SDK."
    }

    # Setup Visual Studio environment
    $devEnvCmd = Join-Path $vsPath "Common7\Tools\VsDevCmd.bat"
    if (-not (Test-Path $devEnvCmd)) {
        throw "VsDevCmd.bat not found at: $devEnvCmd"
    }

    Write-Host "Setting up Visual Studio environment..." -ForegroundColor Yellow

    # Create a temporary batch file to run both VsDevCmd and MSBuild
    $tempBatch = Join-Path $env:TEMP "build_driver.bat"
    @"
@echo off
call "$devEnvCmd" -no_logo -arch=amd64
msbuild.exe "$($slnFile.FullName)" /p:Configuration=Release /p:Platform=x64 /p:OutDir="$outputDir\" /t:Rebuild /m /nologo /verbosity:detailed
exit /b %ERRORLEVEL%
"@ | Out-File -FilePath $tempBatch -Encoding ASCII

    # Execute the batch file
    Write-Host "`nStarting build..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempBatch`"" -NoNewWindow -Wait -PassThru

    # Clean up
    Remove-Item $tempBatch -Force

    if ($process.ExitCode -ne 0) {
        throw "Build failed with exit code $($process.ExitCode)"
    }

    Write-Host "`nBuild completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Build failed: $_" -ForegroundColor Red
    exit 1
}

# Verify build outputs
$requiredFiles = @(
    "AmtPtpDevice.sys",
    "AmtPtpDevice.inf",
    "AmtPtpDevice.cat"
)

Write-Host "`nChecking build outputs..." -ForegroundColor Yellow
$missingFiles = @()
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $outputDir $file
    if (-not (Test-Path $filePath)) {
        $missingFiles += $file
        Write-Host "Missing: $file" -ForegroundColor Red
    } else {
        Write-Host "Found: $file" -ForegroundColor Green
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "`nError: Missing required files!" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuild successful!" -ForegroundColor Green
Write-Host "Output directory: $outputDir" -ForegroundColor Green
Write-Host "`nTo install the driver, run:" -ForegroundColor Yellow
Write-Host "cd `"$outputDir`"" -ForegroundColor Cyan
Write-Host "pnputil /add-driver AmtPtpDevice.inf /install" -ForegroundColor Cyan 