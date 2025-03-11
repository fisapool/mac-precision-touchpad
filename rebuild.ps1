# PowerShell script to build Mac Trackpad driver without relying directly on MSBuild
Write-Host "===== Mac Trackpad Driver Build Script =====" -ForegroundColor Cyan
Write-Host ""

# Get the script directory and project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# Create required directories
Write-Host "Creating build directories..." -ForegroundColor Yellow
$buildDirs = @(
    "bin",
    "bin\x64",
    "bin\x64\Release",
    "bin\x64\Debug"
)

foreach ($dir in $buildDirs) {
    $dirPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    }
}

# Try to find MSBuild in common locations
$msbuildPaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
)

$msbuildPath = $null
foreach ($path in $msbuildPaths) {
    if (Test-Path $path) {
        $msbuildPath = $path
        break
    }
}

if ($msbuildPath) {
    Write-Host "Found MSBuild at: $msbuildPath" -ForegroundColor Green
    
    # Build the project
    Write-Host "`nBuilding driver project..." -ForegroundColor Yellow
    $driverProject = Join-Path $projectRoot "src\driver\AmtPtpDeviceUsbKm.vcxproj"
    
    if (Test-Path $driverProject) {
        Write-Host "Found driver project at: $driverProject" -ForegroundColor Green
        
        try {
            & $msbuildPath $driverProject /p:Configuration=Release /p:Platform=x64
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`nBuild completed successfully!" -ForegroundColor Green
                
                $outputDir = Join-Path $projectRoot "bin\x64\Release"
                Write-Host "Output files should be in: $outputDir" -ForegroundColor Cyan
                
                # List the files in the output directory
                Write-Host "`nOutput directory contents:" -ForegroundColor Yellow
                Get-ChildItem $outputDir | Format-Table Name, Length -AutoSize
            } else {
                Write-Host "`nBuild failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            }
        } catch {
            Write-Host "`nBuild failed with error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "ERROR: Driver project not found at: $driverProject" -ForegroundColor Red
        Write-Host "Please ensure you're running this script from the project root directory." -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: MSBuild not found. Please ensure Visual Studio is installed." -ForegroundColor Red
    Write-Host "`nAlternative build methods:" -ForegroundColor Yellow
    Write-Host "1. Open the project in Visual Studio and build from there" -ForegroundColor White
    Write-Host "2. Install Visual Studio Build Tools" -ForegroundColor White
    Write-Host "3. Use Developer Command Prompt for Visual Studio and run build.bat" -ForegroundColor White
}

Write-Host "`nPress any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")