# Generate a comprehensive test report
param (
    [switch]$UseMockDriver = $true,
    [string]$OutputFormat = "markdown"
)

Write-Host "=== MacTrackpad Test Report Generator ===" -ForegroundColor Cyan
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = "TestReport_$timestamp.$OutputFormat"

# Set environment variable for mock mode
if ($UseMockDriver) {
    $env:DOTNET_MOCK_DRIVER = "true"
    Write-Host "Running tests with mock driver (no hardware needed)" -ForegroundColor Yellow
} else {
    $env:DOTNET_MOCK_DRIVER = "false"
    Write-Host "Running tests with real driver (hardware required)" -ForegroundColor Yellow
}

# Run all test categories 
$testCategories = @(
    "Standalone",
    "Verification",
    "Performance",
    "Functionality",
    "Installation"
)

$results = @{}

foreach ($category in $testCategories) {
    Write-Host "Running tests for category: $category" -ForegroundColor Green
    
    $output = dotnet test --filter "TestCategory=$category" --logger "console;verbosity=detailed" 2>&1
    $success = $LASTEXITCODE -eq 0
    
    $results[$category] = @{
        "Success" = $success
        "Output" = $output
    }
    
    if ($success) {
        Write-Host "✓ $category tests passed" -ForegroundColor Green
    } else {
        Write-Host "✗ $category tests failed" -ForegroundColor Red
    }
}

# Generate report
Write-Host "`nGenerating test report: $reportFile" -ForegroundColor Cyan

$report = "# MacTrackpad Test Report`n`n"
$report += "Generated: $(Get-Date)`n`n"
$report += "Using mock driver: $UseMockDriver`n`n"
$report += "## Test Results Summary`n`n"
$report += "| Category | Result |`n"
$report += "|----------|--------|`n"

foreach ($category in $testCategories) {
    $status = if ($results[$category].Success) { "✓ PASS" } else { "✗ FAIL" }
    $report += "| $category | $status |`n"
}

$report += "`n## Detailed Results`n`n"

foreach ($category in $testCategories) {
    $report += "### $category Tests`n`n"
    $status = if ($results[$category].Success) { "PASSED" } else { "FAILED" }
    $report += "Status: $status`n`n"
    $report += "````n"
    $report += $results[$category].Output
    $report += "`n````n`n"
}

# Save the report
Set-Content -Path $reportFile -Value $report
Write-Host "Test report generated: $reportFile" -ForegroundColor Green 