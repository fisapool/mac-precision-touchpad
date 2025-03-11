# Fixed script to launch tools
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Dashboard", "Install", "Uninstall", "Test")]
    [string]$Tool
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

switch($Tool) {
    "Dashboard" {
        $dashboardPath = Join-Path $projectRoot "src\MacTrackpadDashboard\dashboard.html"
        Start-Process $dashboardPath
        Write-Host "Launched dashboard" -ForegroundColor Green
    }
    "Install" {
        $installPath = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateInstall.cmd"
        # Fixed command with proper escaping
        Start-Process "cmd.exe" -ArgumentList "/c", $installPath
        Write-Host "Launched installation simulation" -ForegroundColor Green
    }
    "Uninstall" {
        $uninstallPath = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateUninstall.cmd"
        # Fixed command with proper escaping
        Start-Process "cmd.exe" -ArgumentList "/c", $uninstallPath
        Write-Host "Launched uninstallation simulation" -ForegroundColor Green
    }
    "Test" {
        $testPath = Join-Path $projectRoot "src\MacTrackpadTest\RunMockedTests.cmd"
        # Fixed command with proper escaping
        Start-Process "cmd.exe" -ArgumentList "/c", $testPath
        Write-Host "Launched tests" -ForegroundColor Green
    }
} 