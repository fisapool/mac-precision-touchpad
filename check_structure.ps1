# Project structure diagnostic script
Write-Host "===== Mac Trackpad Driver Project Structure Check =====" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# Define expected directory structure
$expectedDirs = @(
    "src",
    "src\MacTrackpadSetup",
    "src\MacTrackpadTest",
    "src\MacTrackpadDashboard",
    "src\AmtPtpDevice",
    "bin",
    "bin\x64",
    "bin\x64\Release",
    "scripts"
)

# Define expected files
$expectedFiles = @(
    "src\MacTrackpadSetup\UninstallComplete.bat",
    "src\MacTrackpadTest\CompatibleTestUtils.cmd",
    "src\MacTrackpadTest\RunMockedTests.cmd",
    "SetupMockEnvironment.ps1",
    "TestWorkflow.ps1"
)

# Check directories
Write-Host "Checking directory structure:" -ForegroundColor Yellow
$missingDirs = @()

foreach ($dir in $expectedDirs) {
    $dirPath = Join-Path $projectRoot $dir
    $exists = Test-Path $dirPath -PathType Container
    $status = if ($exists) { "✓" } else { "✗" }
    Write-Host "  $status $dir" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
    
    if (-not $exists) {
        $missingDirs += $dir
    }
}

# Check files
Write-Host "`nChecking key files:" -ForegroundColor Yellow
$missingFiles = @()

foreach ($file in $expectedFiles) {
    $filePath = Join-Path $projectRoot $file
    $exists = Test-Path $filePath -PathType Leaf
    $status = if ($exists) { "✓" } else { "✗" }
    Write-Host "  $status $file" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
    
    if (-not $exists) {
        $missingFiles += $file
    }
}

# Check mock driver files if mock environment is supposed to be set up
$mockConfigPath = Join-Path $projectRoot "src\MacTrackpadTest\TestConfig.json"
$mockEnvSetup = Test-Path $mockConfigPath

if ($mockEnvSetup) {
    Write-Host "`nChecking mock driver files:" -ForegroundColor Yellow
    $mockFiles = @(
        "bin\x64\Release\AmtPtpDevice.sys",
        "bin\x64\Release\AmtPtpDevice.inf",
        "bin\x64\Release\AmtPtpDevice.cat",
        "src\MacTrackpadSetup\Driver\AmtPtpDevice.sys",
        "src\MacTrackpadSetup\Driver\AmtPtpDevice.inf",
        "src\MacTrackpadSetup\Driver\AmtPtpDevice.cat"
    )
    
    foreach ($file in $mockFiles) {
        $filePath = Join-Path $projectRoot $file
        $exists = Test-Path $filePath
        $status = if ($exists) { "✓" } else { "✗" }
        Write-Host "  $status $file" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
    }
}

# Summary and recommendations
Write-Host "`n===== Project Status Summary =====" -ForegroundColor Yellow

if ($missingDirs.Count -eq 0 -and $missingFiles.Count -eq 0) {
    Write-Host "✓ All expected directories and files are present." -ForegroundColor Green
} else {
    if ($missingDirs.Count -gt 0) {
        Write-Host "✗ Missing directories: $($missingDirs.Count)" -ForegroundColor Red
        Write-Host "  The following directories are missing:" -ForegroundColor White
        foreach ($dir in $missingDirs) {
            Write-Host "  - $dir" -ForegroundColor Red
        }
        
        Write-Host "`nTo create missing directories, run:" -ForegroundColor Yellow
        Write-Host ".\SetupMockEnvironment.ps1" -ForegroundColor White
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "`n✗ Missing files: $($missingFiles.Count)" -ForegroundColor Red
        Write-Host "  The following key files are missing:" -ForegroundColor White
        foreach ($file in $missingFiles) {
            Write-Host "  - $file" -ForegroundColor Red
        }
    }
}

# Check for TestWorkflow.ps1
$testWorkflowPath = Join-Path $projectRoot "TestWorkflow.ps1"
if (Test-Path $testWorkflowPath) {
    Write-Host "`n✓ TestWorkflow.ps1 is present. Run this script to navigate through testing options:" -ForegroundColor Green
    Write-Host "  .\TestWorkflow.ps1" -ForegroundColor White
} else {
    Write-Host "`n✗ TestWorkflow.ps1 is missing." -ForegroundColor Red
    Write-Host "  This is the main test workflow script. Please recreate it using the previous command." -ForegroundColor White
}

# Check PowerShell execution policy
$policy = Get-ExecutionPolicy
if ($policy -eq "Restricted") {
    Write-Host "`n⚠️ PowerShell execution policy is set to Restricted." -ForegroundColor Yellow
    Write-Host "  This may prevent scripts from running. To allow script execution, run:" -ForegroundColor White
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process" -ForegroundColor White
}

Write-Host "`n===== Project Structure Check Complete =====" -ForegroundColor Cyan
Write-Host "Run .\TestWorkflow.ps1 to begin testing your driver" -ForegroundColor Green 