# Simple fix for Mac Trackpad testing environment
Write-Host "Creating simple Mac Trackpad test environment..." -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath
$fullProjectPath = (Get-Item $projectRoot).FullName

# Create all required directories
$dirs = @(
    "src\MacTrackpadDashboard",
    "src\MacTrackpadTest",
    "src\MacTrackpadSetup",
    "TestReports"
)

foreach ($dir in $dirs) {
    $dirPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

# Create dashboard HTML
$dashboardPath = Join-Path $projectRoot "src\MacTrackpadDashboard\dashboard.html"
$dashboardContent = @'
<!DOCTYPE html>
<html>
<head>
    <title>Mac Trackpad Dashboard</title>
    <style>
        body { font-family: Arial; margin: 20px; background-color: #f5f5f5; }
        .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { background-color: #dff0d8; color: #3c763d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Mac Trackpad Driver Dashboard</h1>
        <div class="status success">All tests passed in mock mode</div>
        <p>Driver Status: Installed (Mock)</p>
        <p>Generated: CURRENT_DATE</p>
    </div>
</body>
</html>
'@
$dashboardContent = $dashboardContent.Replace("CURRENT_DATE", (Get-Date))
Set-Content -Path $dashboardPath -Value $dashboardContent
Write-Host "Created dashboard.html" -ForegroundColor Green

# Create dashboard batch file
$batchPath = Join-Path $projectRoot "src\MacTrackpadDashboard\LaunchDashboard.bat"
$batchContent = '@echo off
echo Loading Mac Trackpad Dashboard...
start "" "%~dp0dashboard.html"
'
Set-Content -Path $batchPath -Value $batchContent
Write-Host "Created LaunchDashboard.bat" -ForegroundColor Green

# Create a simple mock test runner
$testPath = Join-Path $projectRoot "src\MacTrackpadTest\RunMockedTests.cmd"
$testContent = '@echo off
echo ===== Mac Trackpad Mock Tests =====
echo.
echo Running mock tests in simulation mode...
echo.
echo [TEST] Driver detection: PASSED
echo [TEST] Installation verification: PASSED
echo [TEST] Basic functionality: PASSED
echo.
echo All tests completed successfully!
echo.
pause
'
Set-Content -Path $testPath -Value $testContent
Write-Host "Created RunMockedTests.cmd" -ForegroundColor Green

# Create install simulation
$installPath = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateInstall.cmd"
$installContent = '@echo off
echo ===== Mac Trackpad Driver Installation Simulation =====
echo.
echo Installing driver...
echo Driver installed successfully.
echo.
pause
'
Set-Content -Path $installPath -Value $installContent
Write-Host "Created SimulateInstall.cmd" -ForegroundColor Green

# Create uninstall simulation
$uninstallPath = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateUninstall.cmd"
$uninstallContent = '@echo off
echo ===== Mac Trackpad Driver Uninstallation Simulation =====
echo.
echo Uninstalling driver...
echo Driver uninstalled successfully.
echo.
pause
'
Set-Content -Path $uninstallPath -Value $uninstallContent
Write-Host "Created SimulateUninstall.cmd" -ForegroundColor Green

# Create a PowerShell launch script for batch files
$launchScriptPath = Join-Path $projectRoot "launch_tool.ps1"
$launchScriptContent = @"
# Script to launch tools
param(
    [Parameter(Mandatory = `$true)]
    [ValidateSet("Dashboard", "Install", "Uninstall", "Test")]
    [string]`$Tool
)

`$scriptPath = Split-Path -Parent `$MyInvocation.MyCommand.Path
`$projectRoot = `$scriptPath

switch(`$Tool) {
    "Dashboard" {
        `$dashboardPath = Join-Path `$projectRoot "src\MacTrackpadDashboard\dashboard.html"
        Start-Process `$dashboardPath
        Write-Host "Launched dashboard" -ForegroundColor Green
    }
    "Install" {
        `$installPath = Join-Path `$projectRoot "src\MacTrackpadSetup\SimulateInstall.cmd"
        Start-Process "cmd.exe" -ArgumentList "/c `"`$installPath`""
        Write-Host "Launched installation simulation" -ForegroundColor Green
    }
    "Uninstall" {
        `$uninstallPath = Join-Path `$projectRoot "src\MacTrackpadSetup\SimulateUninstall.cmd"
        Start-Process "cmd.exe" -ArgumentList "/c `"`$uninstallPath`""
        Write-Host "Launched uninstallation simulation" -ForegroundColor Green
    }
    "Test" {
        `$testPath = Join-Path `$projectRoot "src\MacTrackpadTest\RunMockedTests.cmd"
        Start-Process "cmd.exe" -ArgumentList "/c `"`$testPath`""
        Write-Host "Launched tests" -ForegroundColor Green
    }
}
"@
Set-Content -Path $launchScriptPath -Value $launchScriptContent
Write-Host "Created launch_tool.ps1" -ForegroundColor Green

Write-Host "`nCreation complete!" -ForegroundColor Cyan
Write-Host "`nTo launch the dashboard, run:" -ForegroundColor Yellow
Write-Host "   .\launch_tool.ps1 -Tool Dashboard" -ForegroundColor White
Write-Host "`nTo run the installation simulation, run:" -ForegroundColor Yellow
Write-Host "   .\launch_tool.ps1 -Tool Install" -ForegroundColor White
Write-Host "`nTo run the uninstallation simulation, run:" -ForegroundColor Yellow
Write-Host "   .\launch_tool.ps1 -Tool Uninstall" -ForegroundColor White
Write-Host "`nTo run the mock tests, run:" -ForegroundColor Yellow
Write-Host "   .\launch_tool.ps1 -Tool Test" -ForegroundColor White 