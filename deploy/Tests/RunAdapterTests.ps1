param (
    [switch]$UseMockDriver = $true
)

Write-Host "=== Running Adapter Tests (Mock Mode) ===" -ForegroundColor Cyan
Write-Host ""

# Set environment variable for mock mode
if ($UseMockDriver) {
    $env:DOTNET_MOCK_DRIVER = "true"
}

# Run the specific adapter tests
Write-Host "Running PerformanceTestAdapter tests..." -ForegroundColor Yellow
dotnet test --filter "FullyQualifiedName~PerformanceTestAdapter" --logger "console;verbosity=detailed"

Write-Host "`nRunning InstallationTestAdapter tests..." -ForegroundColor Yellow
dotnet test --filter "FullyQualifiedName~InstallationTestAdapter" --logger "console;verbosity=detailed"

Write-Host "`nAdapter tests complete" -ForegroundColor Green 