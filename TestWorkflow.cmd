@echo off
echo ===== Mac Trackpad Driver Testing Workflow =====
echo.
echo This script will guide you through the testing process.
echo.
echo 1. Set up mock environment
echo 2. Run basic tests
echo 3. Test uninstallation
echo 4. Generate test report
echo 5. Create dashboard
echo 6. Exit
echo.

:MENU
set /p CHOICE="Enter your choice (1-6): "

if "%CHOICE%"=="1" (
    echo.
    echo Setting up mock environment...
    powershell -ExecutionPolicy Bypass -File "setup_build_env.ps1"
    goto MENU
)

if "%CHOICE%"=="2" (
    echo.
    echo Running basic tests...
    call "src\MacTrackpadTest\RunMockedTests.cmd"
    goto MENU
)

if "%CHOICE%"=="3" (
    echo.
    echo Testing uninstallation...
    call "src\MacTrackpadSetup\SimulateUninstall.cmd"
    goto MENU
)

if "%CHOICE%"=="4" (
    echo.
    echo Generating test report...
    powershell -ExecutionPolicy Bypass -File "generate_test_report.ps1"
    goto MENU
)

if "%CHOICE%"=="5" (
    echo.
    echo Creating dashboard...
    powershell -ExecutionPolicy Bypass -File "create_dashboard.ps1"
    goto MENU
)

if "%CHOICE%"=="6" (
    echo.
    echo Exiting...
    exit /b
)

echo.
echo Invalid choice. Please try again.
goto MENU 