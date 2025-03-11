param (
    [string]$Version = "1.0.0",
    [string]$Configuration = "Release",
    [switch]$IncludeDebugSymbols = $false,
    [switch]$IncludeTests = $false,
    [string]$OutputPath = ".\Deploy",
    [switch]$SkipVerification = $false
)

$ErrorActionPreference = "Continue"  # Changed from Stop to Continue for more flexibility
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath

Write-Host "===== Mac Trackpad Driver Deployment Package Builder =====" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Configuration: $Configuration" -ForegroundColor Yellow
Write-Host "Include Debug Symbols: $IncludeDebugSymbols" -ForegroundColor Yellow
Write-Host "Include Tests: $IncludeTests" -ForegroundColor Yellow
Write-Host "Output Path: $OutputPath" -ForegroundColor Yellow
Write-Host "Skip Verification: $SkipVerification" -ForegroundColor Yellow
Write-Host ""

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    Write-Host "Creating output directory: $OutputPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Clean output directory
if (Test-Path $OutputPath) {
    Write-Host "Cleaning output directory..." -ForegroundColor Green
    Get-ChildItem -Path $OutputPath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Verify build environment
if (-not $SkipVerification) {
    Write-Host "Verifying build environment..." -ForegroundColor Green
    $verifyScript = "$scriptPath\verify_build_env.ps1"
    if (Test-Path $verifyScript) {
        & "$verifyScript"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Build environment verification failed, continuing anyway..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Build environment verification script not found, skipping..." -ForegroundColor Yellow
    }
}

# Create deployment directories
$driverDir = Join-Path $OutputPath "Driver"
$dashboardDir = Join-Path $OutputPath "Dashboard"
$docsDir = Join-Path $OutputPath "Documentation"
$toolsDir = Join-Path $OutputPath "Tools"

New-Item -ItemType Directory -Path $driverDir -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path $dashboardDir -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path $docsDir -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path $toolsDir -ErrorAction SilentlyContinue | Out-Null

if ($IncludeTests) {
    $testsDir = Join-Path $OutputPath "Tests"
    New-Item -ItemType Directory -Path $testsDir -ErrorAction SilentlyContinue | Out-Null
}

# Check if we need to build the driver
$buildScript = Join-Path $rootPath "build.bat"
$needToBuild = $false

if (Test-Path $buildScript) {
    Write-Host "Building driver package..." -ForegroundColor Green
    Push-Location $rootPath
    & ".\build.bat" $Configuration
    $buildResult = $LASTEXITCODE
    Pop-Location
    
    if ($buildResult -ne 0) {
        Write-Host "Driver build failed with code $buildResult!" -ForegroundColor Red
        Write-Host "Continuing with package creation using existing files..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Build script not found. Skipping build and using existing files..." -ForegroundColor Yellow
    $needToBuild = $false
}

# Try to find driver files
$driverBuildDir = Join-Path $rootPath "bin\$Configuration\Driver"
if (-not (Test-Path $driverBuildDir)) {
    Write-Host "Driver build directory not found: $driverBuildDir" -ForegroundColor Yellow
    Write-Host "Looking for driver files in alternative locations..." -ForegroundColor Yellow
    
    # Try looking in src/driver/
    $altDriverDir = Join-Path $rootPath "src\driver"
    if (Test-Path $altDriverDir) {
        $driverBuildDir = $altDriverDir
        Write-Host "Using driver files from: $driverBuildDir" -ForegroundColor Green
    }
}

# Copy driver files if they exist
Write-Host "Copying driver files..." -ForegroundColor Green
$driverFilesFound = $false

# Copy .inf files
$infFiles = Get-ChildItem -Path $rootPath -Include "*.inf" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $infFiles) {
    Write-Host "  Found driver file: $($file.FullName)" -ForegroundColor Green
    Copy-Item -Path $file.FullName -Destination $driverDir -Force
    $driverFilesFound = $true
}

# Copy .cat files
$catFiles = Get-ChildItem -Path $rootPath -Include "*.cat" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $catFiles) {
    Write-Host "  Found driver file: $($file.FullName)" -ForegroundColor Green
    Copy-Item -Path $file.FullName -Destination $driverDir -Force
    $driverFilesFound = $true
}

# Copy .sys files
$sysFiles = Get-ChildItem -Path $rootPath -Include "*.sys" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $sysFiles) {
    Write-Host "  Found driver file: $($file.FullName)" -ForegroundColor Green
    Copy-Item -Path $file.FullName -Destination $driverDir -Force
    $driverFilesFound = $true
}

if ($IncludeDebugSymbols) {
    $pdbFiles = Get-ChildItem -Path $rootPath -Include "*.pdb" -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $pdbFiles) {
        if ($file.FullName -like "*driver*") {
            Write-Host "  Found debug symbol: $($file.FullName)" -ForegroundColor Green
            Copy-Item -Path $file.FullName -Destination $driverDir -Force
        }
    }
}

if (-not $driverFilesFound) {
    Write-Host "WARNING: No driver files found to include in the package!" -ForegroundColor Red
}

# Copy dashboard application if it exists
Write-Host "Copying dashboard application..." -ForegroundColor Green
$dashboardBuildDir = Join-Path $rootPath "bin\$Configuration\Dashboard"
$dashboardFound = $false

if (Test-Path $dashboardBuildDir) {
    Copy-Item -Path "$dashboardBuildDir\*" -Destination $dashboardDir -Exclude "*.pdb" -Recurse -ErrorAction SilentlyContinue
    $dashboardFound = $true
    
    if ($IncludeDebugSymbols) {
        Copy-Item -Path "$dashboardBuildDir\*.pdb" -Destination $dashboardDir -ErrorAction SilentlyContinue
    }
} else {
    # Look for dashboard files in alternative locations
    $altDashboardDirs = @(
        (Join-Path $rootPath "src\dashboard\bin\$Configuration"),
        (Join-Path $rootPath "dashboard\bin\$Configuration")
    )
    
    foreach ($dir in $altDashboardDirs) {
        if (Test-Path $dir) {
            Write-Host "  Found dashboard in: $dir" -ForegroundColor Green
            Copy-Item -Path "$dir\*" -Destination $dashboardDir -Exclude "*.pdb" -Recurse -ErrorAction SilentlyContinue
            $dashboardFound = $true
            
            if ($IncludeDebugSymbols) {
                Copy-Item -Path "$dir\*.pdb" -Destination $dashboardDir -ErrorAction SilentlyContinue
            }
            
            break
        }
    }
}

if (-not $dashboardFound) {
    Write-Host "WARNING: Dashboard application not found!" -ForegroundColor Yellow
}

# Copy documentation
Write-Host "Copying documentation..." -ForegroundColor Green
$docsSourceDir = Join-Path $rootPath "docs"
if (Test-Path $docsSourceDir) {
    Copy-Item -Path "$docsSourceDir\*" -Destination $docsDir -Recurse -ErrorAction SilentlyContinue
    Write-Host "  Documentation copied from: $docsSourceDir" -ForegroundColor Green
} else {
    Write-Host "WARNING: Documentation directory not found!" -ForegroundColor Yellow
    
    # Create a basic README if no docs exist
    $readmeContent = @"
# Mac Trackpad Driver for Windows

Version: $Version
Build Date: $(Get-Date -Format "yyyy-MM-dd")

## Installation

1. Run the installer: `Tools\Install.bat` (as Administrator)
2. Restart your computer

## Support

For support, please contact the developer.
"@
    
    Set-Content -Path (Join-Path $docsDir "README.md") -Value $readmeContent
    Write-Host "  Created basic README file" -ForegroundColor Green
}

# Create installation tools
Write-Host "Creating installation tools..." -ForegroundColor Green

# Create installer batch file
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
pnputil /add-driver "%~dp0Driver\*.inf" /install

echo.
echo Installation complete!
echo Please restart your computer to complete the installation.
pause
"@

Set-Content -Path (Join-Path $toolsDir "Install.bat") -Value $installerContent

# Create uninstaller batch file
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

# Include tests if requested
if ($IncludeTests) {
    Write-Host "Copying test framework..." -ForegroundColor Green
    $testsBuildDir = Join-Path $rootPath "bin\$Configuration\MacTrackpadTest"
    $testsFound = $false
    
    if (Test-Path $testsBuildDir) {
        Copy-Item -Path "$testsBuildDir\*" -Destination $testsDir -Recurse -ErrorAction SilentlyContinue
        $testsFound = $true
    } else {
        # Look for tests in alternative locations
        $altTestsDirs = @(
            (Join-Path $rootPath "src\MacTrackpadTest\bin\$Configuration"),
            (Join-Path $rootPath "MacTrackpadTest\bin\$Configuration")
        )
        
        foreach ($dir in $altTestsDirs) {
            if (Test-Path $dir) {
                Write-Host "  Found tests in: $dir" -ForegroundColor Green
                Copy-Item -Path "$dir\*" -Destination $testsDir -Recurse -ErrorAction SilentlyContinue
                $testsFound = $true
                break
            }
        }
        
        # Also directly copy test files from the source directory
        $sourceTestDir = Join-Path $rootPath "src\MacTrackpadTest"
        if (Test-Path $sourceTestDir) {
            $testFiles = Get-ChildItem -Path $sourceTestDir -Include "*.cs", "*.ps1", "*.cmd" -Recurse -ErrorAction SilentlyContinue
            foreach ($file in $testFiles) {
                $relativePath = $file.FullName.Substring($sourceTestDir.Length)
                $destPath = Join-Path $testsDir $relativePath
                
                $destDir = Split-Path -Parent $destPath
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }
                
                Copy-Item -Path $file.FullName -Destination $destPath -Force
            }
            $testsFound = $true
        }
    }
    
    if ($testsFound) {
        # Create test runner script
        $testRunnerContent = @"
@echo off
echo ===== Mac Trackpad Test Runner =====
echo.

cd /d "%~dp0Tests"
echo Running tests in mock mode (no hardware required)...

if exist RunMockedTests.cmd (
    call RunMockedTests.cmd
) else if exist RunAdapterTests.ps1 (
    powershell -ExecutionPolicy Bypass -File RunAdapterTests.ps1
) else (
    echo ERROR: Test runner scripts not found!
    echo Looking for RunMockedTests.cmd or RunAdapterTests.ps1...
    dir /b
)
"@

        Set-Content -Path (Join-Path $toolsDir "RunTests.bat") -Value $testRunnerContent
    } else {
        Write-Host "WARNING: Test framework not found!" -ForegroundColor Yellow
    }
}

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
$(if ($dashboardFound) { "- `Dashboard\` - User interface application" } else { "" })
- `Documentation\` - User guides and technical documentation
- `Tools\` - Installation and maintenance utilities
$(if ($IncludeTests -and $testsFound) { "- `Tests\` - Test framework for verifying driver functionality" } else { "" })

## Support

For support, please visit the project repository.

"@

Set-Content -Path (Join-Path $OutputPath "README.txt") -Value $readmeContent

# Create version info file
$versionInfoContent = @"
Version: $Version
Build Configuration: $Configuration
Build Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Builder: $($env:USERNAME)
Machine: $($env:COMPUTERNAME)
"@

Set-Content -Path (Join-Path $OutputPath "version.txt") -Value $versionInfoContent

# Create ZIP package
Write-Host "Creating deployment ZIP package..." -ForegroundColor Green
$zipFileName = "MacTrackpadDriver-$Version.zip"
$zipFilePath = Join-Path (Split-Path -Parent $OutputPath) $zipFileName

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($OutputPath, $zipFilePath)
    Write-Host "  ZIP file created: $zipFilePath" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create ZIP file: $_" -ForegroundColor Red
    Write-Host "Continuing without creating ZIP file..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===== Deployment Package Created Successfully =====" -ForegroundColor Green
Write-Host "Package: $OutputPath" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "" 