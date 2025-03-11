# PowerShell script for running MacTrackpad tests from the repository root
Write-Host "=== MacTrackpad Test Runner (Root) ===" -ForegroundColor Cyan
Write-Host ""

# Navigate to the test directory
$testDir = Join-Path $PSScriptRoot "src\MacTrackpadTest"
Set-Location $testDir

if (-not (Test-Path "RunTests.ps1")) {
    Write-Host "ERROR: Test scripts not found in $testDir" -ForegroundColor Red
    exit 1
}

# Run the test script
& "$testDir\RunTests.ps1" 