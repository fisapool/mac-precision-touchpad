# PowerShell script for running diagnostic tests
Write-Host "=== MacTrackpad Test Diagnostics ===" -ForegroundColor Cyan
Write-Host ""

# Navigate to the correct directory (the directory containing this script)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "Building test project..." -ForegroundColor Yellow
dotnet build

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "=== Running Diagnostic Tests ===" -ForegroundColor Cyan
Write-Host ""

# Run only the diagnostic tests
dotnet test --filter "TestCategory=Diagnostics" --logger "console;verbosity=detailed"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== All diagnostic tests passed successfully ===" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "=== Some tests failed ===" -ForegroundColor Red
}

exit $LASTEXITCODE 