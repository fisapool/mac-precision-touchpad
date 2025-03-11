# Simple direct launcher for Mac Trackpad tools
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Dashboard", "Install", "Uninstall", "Test")]
    [string]$Tool
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

switch($Tool) {
    "Dashboard" {
        # Open dashboard directly
        Invoke-Item "$scriptPath\src\MacTrackpadDashboard\dashboard.html"
        Write-Host "Opening dashboard..." -ForegroundColor Green
    }
    "Install" {
        # Run install script directly
        $proc = Start-Process "cmd.exe" -ArgumentList "/c $scriptPath\src\MacTrackpadSetup\SimulateInstall.cmd" -PassThru
        Write-Host "Running installation simulation..." -ForegroundColor Green
    }
    "Uninstall" {
        # Run uninstall script directly
        $proc = Start-Process "cmd.exe" -ArgumentList "/c $scriptPath\src\MacTrackpadSetup\SimulateUninstall.cmd" -PassThru
        Write-Host "Running uninstallation simulation..." -ForegroundColor Green
    }
    "Test" {
        # Run test script directly
        $proc = Start-Process "cmd.exe" -ArgumentList "/c $scriptPath\src\MacTrackpadTest\RunMockedTests.cmd" -PassThru
        Write-Host "Running tests..." -ForegroundColor Green
    }
} 