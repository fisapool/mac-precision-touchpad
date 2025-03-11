# Enhanced test runner with detailed reporting
param (
    [switch]$InstallationTests,
    [switch]$DriverTests,
    [switch]$PerformanceTests,
    [switch]$WindowsVersionTests,
    [switch]$All,
    [switch]$CI,
    [string]$OutputFormat = "text" # Options: text, xml, json
)

$ErrorActionPreference = "Stop"
$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$currentDir = Get-Location

# Fix test discovery if needed
if (Test-Path (Join-Path $testDir "fix-test-discovery.ps1")) {
    & (Join-Path $testDir "fix-test-discovery.ps1")
}

# Results directory setup
$resultsDir = Join-Path $testDir "TestResults"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = Join-Path $resultsDir "TestRun_$timestamp.log"
$summaryFile = Join-Path $resultsDir "Summary_$timestamp.$OutputFormat"

# Start detailed logging
Start-Transcript -Path $logFile -Append

# Test execution function with detailed progress
function Invoke-TestCategory {
    param (
        [string]$Category,
        [string]$DisplayName,
        [string]$Arguments
    )
    
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  RUNNING $DisplayName TESTS" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    
    Push-Location $testDir
    $testCommand = "dotnet test --filter ""Category=$Category"" $Arguments"
    
    if ($CI) {
        # Add CI-specific options
        $testCommand += " --logger ""trx;LogFileName=TestResults_$Category.trx"""
    }
    
    Write-Host "Executing: $testCommand" -ForegroundColor DarkGray
    $result = Invoke-Expression $testCommand
    Pop-Location
    
    return $LASTEXITCODE -eq 0
}

# Execute the test categories
$testResults = @()
$allPassed = $true

try {
    # Environment info
    Write-Host "Testing on: $((Get-WmiObject -Class Win32_OperatingSystem).Caption) (Build $([System.Environment]::OSVersion.Version.Build))"
    Write-Host "Machine: $env:COMPUTERNAME"
    Write-Host "Test directory: $testDir"
    
    # Installation tests
    if ($All -or $InstallationTests) {
        $success = Invoke-TestCategory -Category "Installation" -DisplayName "DRIVER INSTALLATION" -Arguments "--blame"
        $testResults += @{Category="Installation"; Success=$success; Timestamp=(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")}
        $allPassed = $allPassed -and $success
    }
    
    # Driver functionality tests
    if ($All -or $DriverTests) {
        $success = Invoke-TestCategory -Category "Driver" -DisplayName "DRIVER FUNCTIONALITY" -Arguments ""
        $testResults += @{Category="Driver"; Success=$success; Timestamp=(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")}
        $allPassed = $allPassed -and $success
    }
    
    # Performance tests
    if ($All -or $PerformanceTests) {
        $success = Invoke-TestCategory -Category "Performance" -DisplayName "PERFORMANCE" -Arguments ""
        $testResults += @{Category="Performance"; Success=$success; Timestamp=(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")}
        $allPassed = $allPassed -and $success
    }
    
    # Windows version compatibility tests
    if ($All -or $WindowsVersionTests) {
        $isWindows11 = [System.Environment]::OSVersion.Version.Build -ge 22000
        $winVersionCategory = if ($isWindows11) { "Windows11" } else { "Windows10" }
        
        $success = Invoke-TestCategory -Category $winVersionCategory -DisplayName "WINDOWS VERSION COMPATIBILITY" -Arguments ""
        $testResults += @{Category="WindowsVersion"; Success=$success; Timestamp=(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")}
        $allPassed = $allPassed -and $success
    }
    
    # Generate test summary in the requested format
    switch ($OutputFormat) {
        "xml" {
            $testResults | ConvertTo-Xml -As String -NoTypeInformation | Set-Content -Path $summaryFile
        }
        "json" {
            $testResults | ConvertTo-Json | Set-Content -Path $summaryFile
        }
        default {
            $summaryContent = "# MacTrackpad Test Results`n"
            $summaryContent += "Run Date: $(Get-Date)`n`n"
            $summaryContent += "| Test Category | Status | Timestamp |`n"
            $summaryContent += "|--------------|--------|-----------|`n"
            
            foreach ($result in $testResults) {
                $status = if ($result.Success) { "PASSED" } else { "FAILED" }
                $summaryContent += "| $($result.Category) | $status | $($result.Timestamp) |`n"
            }
            
            $summaryContent += "`nOverall Result: $(if ($allPassed) { 'PASSED' } else { 'FAILED' })`n"
            Set-Content -Path $summaryFile -Value $summaryContent
        }
    }
    
    # Print summary
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  TEST SUMMARY" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    
    foreach ($result in $testResults) {
        $statusColor = if ($result.Success) { "Green" } else { "Red" }
        $statusText = if ($result.Success) { "PASSED" } else { "FAILED" }
        Write-Host "$($result.Category): " -NoNewline
        Write-Host $statusText -ForegroundColor $statusColor
    }
    
    Write-Host "`nOverall Result: " -NoNewline
    if ($allPassed) {
        Write-Host "PASSED" -ForegroundColor Green
    } else {
        Write-Host "FAILED" -ForegroundColor Red
    }
    
    Write-Host "`nDetailed logs: $logFile"
    Write-Host "Summary file: $summaryFile"
    
} finally {
    # Ensure we stop the transcript
    Stop-Transcript
}

# Return appropriate exit code
exit [int](!$allPassed)

# PowerShell script for running MacTrackpad tests
Write-Host "=== MacTrackpad Test Runner (PowerShell) ===" -ForegroundColor Cyan
Write-Host ""

# Get the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "Located test directory at: $PWD" -ForegroundColor Yellow
Write-Host ""
Write-Host "=== Available Test Runners ===" -ForegroundColor Cyan
Write-Host "1. Run Standalone Tests (most reliable)" -ForegroundColor White
Write-Host "2. Run Minimal Tests" -ForegroundColor White
Write-Host "3. Run Diagnostic Tests" -ForegroundColor White
Write-Host "4. Run All Tests (may fail if there are issues)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "`nRunning Standalone Tests..." -ForegroundColor Green
        & "$scriptDir\RunStandaloneTest.cmd"
    }
    "2" {
        Write-Host "`nRunning Minimal Tests..." -ForegroundColor Green
        & "$scriptDir\RunMinimalTest.cmd"
    }
    "3" {
        Write-Host "`nRunning Diagnostic Tests..." -ForegroundColor Green
        & "$scriptDir\RunDiagnosticTests.cmd"
    }
    "4" {
        Write-Host "`nRunning All Tests..." -ForegroundColor Green
        dotnet test
    }
    default {
        Write-Host "Invalid choice. Please enter a number between 1 and 4." -ForegroundColor Red
    }
} 