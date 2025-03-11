param (
    [string]$Category = "Standalone",
    [switch]$UseMockDriver = $true
)

Write-Host "=== Running MacTrackpad Tests: $Category ===" -ForegroundColor Cyan
Write-Host ""

# Set environment variable for mock mode
if ($UseMockDriver) {
    $env:DOTNET_MOCK_DRIVER = "true"
    Write-Host "Using mock driver (no hardware needed)" -ForegroundColor Yellow
} else {
    $env:DOTNET_MOCK_DRIVER = "false"
    Write-Host "Using real driver (hardware required)" -ForegroundColor Red
}

# Run the specified test category
Write-Host "Running tests for category: $Category" -ForegroundColor Green
dotnet test --filter "TestCategory=$Category" --logger "console;verbosity=detailed"

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ $Category tests PASSED" -ForegroundColor Green
} else {
    Write-Host "`n✗ $Category tests FAILED" -ForegroundColor Red
} 