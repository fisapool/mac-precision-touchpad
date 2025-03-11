Write-Host "=== MacTrackpad Test Suite (MOCK MODE) ===" -ForegroundColor Cyan
Write-Host ""

# Ensure we're using mock mode
$env:DOTNET_MOCK_DRIVER = "true"

# Define categories
$categories = @(
    "Standalone",
    "Verification",
    "Performance",
    "Functionality",
    "Installation"
)

# Set up results table
$results = [ordered]@{}
$allPassed = $true

# Run each category
foreach ($category in $categories) {
    Write-Host "Running $category tests..." -ForegroundColor Yellow
    
    $process = Start-Process -FilePath "dotnet" -ArgumentList "test --filter `"TestCategory=$category`"" -NoNewWindow -PassThru
    $process.WaitForExit()
    
    $passed = $process.ExitCode -eq 0
    $results[$category] = $passed
    
    if ($passed) {
        Write-Host "✓ $category tests PASSED" -ForegroundColor Green
    } else {
        Write-Host "✗ $category tests FAILED" -ForegroundColor Red
        $allPassed = $false
    }
    
    Write-Host ""
}

# Display results table
Write-Host "=== Test Results Summary ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Category       | Result" -ForegroundColor White
Write-Host "---------------|-------" -ForegroundColor White

foreach ($category in $results.Keys) {
    $status = if ($results[$category]) { "✓ PASS" } else { "✗ FAIL" }
    $color = if ($results[$category]) { "Green" } else { "Red" }
    Write-Host ("{0,-15} | {1}" -f $category, $status) -ForegroundColor $color
}

Write-Host ""
if ($allPassed) {
    Write-Host "All tests PASSED!" -ForegroundColor Green
} else {
    Write-Host "Some tests FAILED." -ForegroundColor Red
}

# Return result as exit code (0 = success, 1 = failure)
exit [int](!$allPassed) 