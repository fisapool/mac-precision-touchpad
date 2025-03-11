param (
    [string]$Version = "1.0.0",
    [string]$Configuration = "Release",
    [switch]$IncludeDebugSymbols = $false,
    [switch]$IncludeTests = $false,
    [string]$OutputPath = ".\Deploy",
    [switch]$SkipVerification = $false
)

$ErrorActionPreference = "Continue"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath

Write-Host "===== Mac Trackpad Driver Deployment Package Builder =====" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Configuration: $Configuration" -ForegroundColor Yellow
Write-Host "Include Debug Symbols: $IncludeDebugSymbols" -ForegroundColor Yellow
Write-Host "Include Tests: $IncludeTests" -ForegroundColor Yellow
Write-Host "Output Path: $OutputPath" -ForegroundColor Yellow
Write-Host ""

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    Write-Host "Creating output directory: $OutputPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Clean output directory
Write-Host "Cleaning output directory..." -ForegroundColor Green
if (Test-Path $OutputPath) {
    Get-ChildItem -Path $OutputPath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Create deployment directories
$driverDir = Join-Path $OutputPath "Driver"
$dashboardDir = Join-Path $OutputPath "Dashboard"
$docsDir = Join-Path $OutputPath "Documentation"
$toolsDir = Join-Path $OutputPath "Tools"

New-Item -ItemType Directory -Path $driverDir | Out-Null
New-Item -ItemType Directory -Path $dashboardDir | Out-Null
New-Item -ItemType Directory -Path $docsDir | Out-Null
New-Item -ItemType Directory -Path $toolsDir | Out-Null

if ($IncludeTests) {
    $testsDir = Join-Path $OutputPath "Tests"
    New-Item -ItemType Directory -Path $testsDir | Out-Null
}

# Copy files from src directory if they exist
$srcDir = Join-Path $rootPath "src"
if (Test-Path $srcDir) {
    Write-Host "Copying source files..." -ForegroundColor Green
    
    # Copy driver files
    $driverSrcDir = Join-Path $srcDir "driver"
    if (Test-Path $driverSrcDir) {
        Copy-Item -Path "$driverSrcDir\*.inf" -Destination $driverDir -ErrorAction SilentlyContinue
        Copy-Item -Path "$driverSrcDir\*.cat" -Destination $driverDir -ErrorAction SilentlyContinue
        Copy-Item -Path "$driverSrcDir\*.sys" -Destination $driverDir -ErrorAction SilentlyContinue
        
        if ($IncludeDebugSymbols) {
            Copy-Item -Path "$driverSrcDir\*.pdb" -Destination $driverDir -ErrorAction SilentlyContinue
        }
    }
    
    # Copy documentation
    $docsSrcDir = Join-Path $rootPath "docs"
    if (Test-Path $docsSrcDir) {
        Copy-Item -Path "$docsSrcDir\*" -Destination $docsDir -Recurse -ErrorAction SilentlyContinue
    }
    
    # Copy tests
    if ($IncludeTests) {
        $testsSrcDir = Join-Path $srcDir "MacTrackpadTest"
        if (Test-Path $testsSrcDir) {
            Copy-Item -Path "$testsSrcDir\*.cs" -Destination $testsDir -ErrorAction SilentlyContinue
            Copy-Item -Path "$testsSrcDir\*.ps1" -Destination $testsDir -ErrorAction SilentlyContinue
            Copy-Item -Path "$testsSrcDir\*.cmd" -Destination $testsDir -ErrorAction SilentlyContinue
            Copy-Item -Path "$testsSrcDir\*.bat" -Destination $testsDir -ErrorAction SilentlyContinue
            
            # Create a simple test runner
            $testRunnerContent = @"
@echo off
echo ===== Mac Trackpad Test Runner =====
echo.
echo Running tests in mock mode (no hardware required)...
powershell -ExecutionPolicy Bypass -File "%~dp0RunAllMockTests.ps1"
"@
            Set-Content -Path (Join-Path $toolsDir "RunTests.bat") -Value $testRunnerContent
        }
    }
}

# Create installer script
$installerContent = @"
@echo off
echo ===== Mac Trackpad Driver Installer =====
echo.

echo Checking for administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Installing driver...
pnputil /add-driver "%~dp0..\Driver\*.inf" /install

echo.
echo Installation complete!
echo Please restart your computer to complete the installation.
pause
"@

Set-Content -Path (Join-Path $toolsDir "Install.bat") -Value $installerContent

# Create uninstaller script
$uninstallerContent = @"
@echo off
echo ===== Mac Trackpad Driver Uninstaller =====
echo.

echo Checking for administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Uninstalling driver...
pnputil /delete-driver AmtPtpDevice.inf /uninstall /force

echo.
echo Uninstallation complete!
echo Please restart your computer to complete the uninstallation.
pause
"@

Set-Content -Path (Join-Path $toolsDir "Uninstall.bat") -Value $uninstallerContent

# Create README file
$readmeContent = @"
# Mac Trackpad Driver for Windows

Version: $Version
Build Date: $(Get-Date -Format "yyyy-MM-dd")
Configuration: $Configuration

## Quick Start

1. Run the installer: `Tools\Install.bat` (as Administrator)
2. Restart your computer

## Contents

- `Driver\` - Driver files
- `Documentation\` - User guides and technical documentation
- `Tools\` - Installation and maintenance utilities

## Support

For support, please visit the project repository.
"@

Set-Content -Path (Join-Path $OutputPath "README.txt") -Value $readmeContent

Write-Host ""
Write-Host "===== Deployment Package Created Successfully =====" -ForegroundColor Green
Write-Host "Package: $OutputPath" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host ""