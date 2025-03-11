# Master script to guide through the entire testing process
Write-Host "===== Mac Trackpad Driver Testing Workflow =====" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# Check if mock environment is already set up
$mockConfigPath = Join-Path $projectRoot "src\MacTrackpadTest\TestConfig.json"
$mockEnvSetup = Test-Path $mockConfigPath

Write-Host "Step 1: Environment Setup" -ForegroundColor Yellow
if (-not $mockEnvSetup) {
    Write-Host "  Mock environment not detected - setting up now..." -ForegroundColor White
    & (Join-Path $projectRoot "SetupMockEnvironment.ps1")
} else {
    Write-Host "  Mock environment already set up - skipping." -ForegroundColor Green
    Write-Host "  (Delete src\MacTrackpadTest\TestConfig.json to force setup)" -ForegroundColor Gray
}

function Show-Menu {
    Write-Host "`n===== Testing Workflow Menu =====" -ForegroundColor Yellow
    Write-Host "1. Run Basic Driver Tests" -ForegroundColor White
    Write-Host "2. Test Uninstallation Process" -ForegroundColor White
    Write-Host "3. Test Installation Process" -ForegroundColor White
    Write-Host "4. Test Full Workflow (Install → Test → Uninstall)" -ForegroundColor White
    Write-Host "5. Run Test Diagnostics" -ForegroundColor White
    Write-Host "6. Re-setup Mock Environment" -ForegroundColor White
    Write-Host "7. Exit" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-7)"
    return $choice
}

function Run-BasicTests {
    Write-Host "`n===== Running Basic Driver Tests =====" -ForegroundColor Yellow
    
    # Try to find and run the standalone tests first
    $runStandaloneScript = Join-Path $projectRoot "src\MacTrackpadTest\RunStandaloneTest.cmd"
    if (Test-Path $runStandaloneScript) {
        Write-Host "Running standalone tests..." -ForegroundColor Cyan
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$runStandaloneScript`"" -Wait
    } else {
        # Fall back to mock tests
        $runMockedScript = Join-Path $projectRoot "src\MacTrackpadTest\RunMockedTests.cmd"
        if (Test-Path $runMockedScript) {
            Write-Host "Running mocked tests..." -ForegroundColor Cyan
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$runMockedScript`"" -Wait
        } else {
            Write-Host "ERROR: Test scripts not found. Make sure you're in the correct directory." -ForegroundColor Red
        }
    }
}

function Test-Uninstallation {
    Write-Host "`n===== Testing Uninstallation Process =====" -ForegroundColor Yellow
    
    $simulateUninstallScript = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateUninstall.cmd"
    if (Test-Path $simulateUninstallScript) {
        Write-Host "Running uninstallation simulation..." -ForegroundColor Cyan
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$simulateUninstallScript`"" -Wait -Verb RunAs
    } else {
        Write-Host "ERROR: Uninstallation simulation script not found." -ForegroundColor Red
        Write-Host "Expected at: $simulateUninstallScript" -ForegroundColor Red
    }
}

function Test-Installation {
    Write-Host "`n===== Testing Installation Process =====" -ForegroundColor Yellow
    
    # Check for Install.bat or create a simulation if it doesn't exist
    $installScript = Join-Path $projectRoot "src\MacTrackpadSetup\Install.bat"
    if (Test-Path $installScript) {
        Write-Host "Found installation script. Would you like to:" -ForegroundColor White
        Write-Host "1. Run the actual Install.bat (with administrator privileges)" -ForegroundColor White
        Write-Host "2. Create and run a simulated installation" -ForegroundColor White
        $installChoice = Read-Host "Enter your choice (1-2)"
        
        if ($installChoice -eq "1") {
            Write-Host "Running installation script with administrator privileges..." -ForegroundColor Yellow
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$installScript`"" -Wait -Verb RunAs
        } else {
            Create-InstallSimulator
        }
    } else {
        Write-Host "Installation script not found. Creating simulator..." -ForegroundColor Yellow
        Create-InstallSimulator
    }
}

function Create-InstallSimulator {
    # Create a simple installation simulator
    $simulateInstallPath = Join-Path $projectRoot "src\MacTrackpadSetup\SimulateInstall.cmd"
    
    $installSimulator = @"
@echo off
echo ===== Mac Trackpad Driver Install Simulation =====
echo.

REM Check for admin privileges
NET SESSION >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Administrator privileges required!
    echo Please right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

echo Checking for administrator privileges... OK

REM Determine the installer directory
set INSTALLER_DIR=%~dp0
set DRIVER_DIR=%INSTALLER_DIR%Driver

echo.
echo This script will simulate driver installation without actually
echo installing a real driver. This is useful for testing.
echo.
echo 1. Run full installation simulation
echo 2. Run quick installation simulation
echo 3. Exit
echo.

set /p CHOICE="Enter your choice (1-3): "

if "%CHOICE%"=="1" (
    echo.
    echo Running full installation simulation...
    
    echo === STEP 1: Checking system requirements ===
    echo Checking Windows version... Windows 10/11 detected.
    echo Checking for conflicting drivers... None found.
    
    echo.
    echo === STEP 2: Installing driver files ===
    echo Copying driver files to system...
    echo Registering driver in the system...
    echo.
    
    echo === STEP 3: Registering device ===
    echo Creating driver service...
    echo Starting driver service...
    
    echo.
    echo === STEP 4: Setting up autostart ===
    echo Configuring services to start automatically...
    
    echo.
    echo === STEP 5: Verification ===
    echo Checking if driver was successfully installed...
    echo Driver successfully installed.
    echo Creating mock registry entries for testing...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmtPtpDevice" /v DisplayName /t REG_SZ /d "Apple Magic Trackpad Driver" /f > nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MacTrackpadService" /v DisplayName /t REG_SZ /d "Mac Trackpad Service" /f > nul
)

if "%CHOICE%"=="2" (
    echo.
    echo Running quick installation simulation...
    
    echo === Quick Installation Simulation ===
    echo Checking requirements... Done.
    echo Installing driver files... Done.
    echo Registering device... Done.
    echo Setting up autostart... Done.
    echo Verification... Complete.
    echo Driver successfully installed in simulation mode.
    
    echo Creating mock registry entries for testing...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmtPtpDevice" /v DisplayName /t REG_SZ /d "Apple Magic Trackpad Driver" /f > nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MacTrackpadService" /v DisplayName /t REG_SZ /d "Mac Trackpad Service" /f > nul
)

if "%CHOICE%"=="3" (
    echo Exiting...
    goto :EOF
)

echo.
echo Installation simulation complete!
echo It is recommended to restart your computer to complete the installation.
echo.
set /p RESTART=Restart now? (Y/N): 

if /i "%RESTART%"=="Y" (
    echo This is a simulation - no restart will be performed.
    echo In a real scenario, the computer would restart now.
) else (
    echo Please restart your computer manually to complete the installation.
)

pause
"@

    Set-Content -Path $simulateInstallPath -Value $installSimulator
    Write-Host "Created installation simulator at: $simulateInstallPath" -ForegroundColor Green
    
    # Run the installation simulator
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$simulateInstallPath`"" -Wait -Verb RunAs
}

function Test-FullWorkflow {
    Write-Host "`n===== Testing Full Workflow =====" -ForegroundColor Yellow
    Write-Host "This will simulate the entire process: installation → testing → uninstallation" -ForegroundColor White
    
    $proceed = Read-Host "Do you want to proceed? (Y/N)"
    if ($proceed -ne "Y" -and $proceed -ne "y") {
        return
    }
    
    # Step 1: Installation
    Write-Host "`nStep 1: Installation" -ForegroundColor Cyan
    Test-Installation
    
    # Step 2: Testing
    Write-Host "`nStep 2: Driver Testing" -ForegroundColor Cyan
    Run-BasicTests
    
    # Step 3: Uninstallation
    Write-Host "`nStep 3: Uninstallation" -ForegroundColor Cyan
    Test-Uninstallation
    
    Write-Host "`nFull workflow testing completed!" -ForegroundColor Green
}

function Run-TestDiagnostics {
    Write-Host "`n===== Running Test Diagnostics =====" -ForegroundColor Yellow
    
    # Try to run standalone diagnostics first
    $diagnosticScript = Join-Path $projectRoot "src\MacTrackpadTest\RunDiagnosticTests.cmd"
    if (Test-Path $diagnosticScript) {
        Write-Host "Running diagnostic tests..." -ForegroundColor Cyan
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$diagnosticScript`"" -Wait
    } else {
        # Try to run simple verification
        $verifyScript = Join-Path $projectRoot "src\MacTrackpadTest\VerifyEnvironment.ps1"
        if (Test-Path $verifyScript) {
            Write-Host "Running environment verification..." -ForegroundColor Cyan
            & $verifyScript
        } else {
            Write-Host "ERROR: Diagnostic scripts not found." -ForegroundColor Red
            
            # Create a simple diagnostic checker
            Write-Host "Creating a basic diagnostic check..." -ForegroundColor Yellow
            Write-Host "`n--- Basic Diagnostic Information ---" -ForegroundColor White
            Write-Host "OS Version: $([System.Environment]::OSVersion.Version)" -ForegroundColor White
            Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
            Write-Host "Mock environment setup: $mockEnvSetup" -ForegroundColor White
            
            # Check directory structure
            $expectedDirs = @(
                "bin\x64\Release",
                "src\MacTrackpadSetup\Driver",
                "src\MacTrackpadTest"
            )
            
            Write-Host "`nChecking directory structure:" -ForegroundColor White
            foreach ($dir in $expectedDirs) {
                $dirPath = Join-Path $projectRoot $dir
                $exists = Test-Path $dirPath
                $status = if ($exists) { "✓" } else { "✗" }
                Write-Host "  $status $dir" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
            }
            
            # Check mock driver files
            Write-Host "`nChecking mock driver files:" -ForegroundColor White
            $mockFiles = @(
                "bin\x64\Release\AmtPtpDevice.sys",
                "bin\x64\Release\AmtPtpDevice.inf",
                "bin\x64\Release\AmtPtpDevice.cat"
            )
            
            foreach ($file in $mockFiles) {
                $filePath = Join-Path $projectRoot $file
                $exists = Test-Path $filePath
                $status = if ($exists) { "✓" } else { "✗" }
                Write-Host "  $status $file" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
            }
        }
    }
}

# Main menu loop
while ($true) {
    $choice = Show-Menu
    
    switch ($choice) {
        "1" { Run-BasicTests }
        "2" { Test-Uninstallation }
        "3" { Test-Installation }
        "4" { Test-FullWorkflow }
        "5" { Run-TestDiagnostics }
        "6" { 
            # Remove the TestConfig to force re-setup
            if (Test-Path $mockConfigPath) {
                Remove-Item $mockConfigPath -Force
            }
            & (Join-Path $projectRoot "SetupMockEnvironment.ps1")
        }
        "7" { 
            Write-Host "Exiting workflow..." -ForegroundColor Cyan
            exit 
        }
        default { Write-Host "Invalid choice. Please enter a number between 1 and 7." -ForegroundColor Red }
    }
} 