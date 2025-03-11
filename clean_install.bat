@echo off
color 1F
cls
echo ===== Mac Trackpad Complete Reinstallation =====
echo.
echo This script will completely remove all existing Mac Trackpad
echo components and reinstall them from scratch.
echo.
echo Press any key to continue, or CTRL+C to cancel...
pause >nul

echo.
echo Step 1: Removing existing components...
if exist "src" (
    rmdir /s /q src
    echo - Removed src directory and all contents
)

echo.
echo Step 2: Removing existing batch files...
if exist "open_dashboard.bat" del "open_dashboard.bat"
if exist "run_install.bat" del "run_install.bat" 
if exist "run_uninstall.bat" del "run_uninstall.bat"
if exist "run_tests.bat" del "run_tests.bat"
if exist "mac_trackpad_tools.bat" del "mac_trackpad_tools.bat"
if exist "mac_trackpad_tools_enhanced.bat" del "mac_trackpad_tools_enhanced.bat"
if exist "monitor_status.bat" del "monitor_status.bat"
if exist "system_check.bat" del "system_check.bat"
if exist "show_help.bat" del "show_help.bat"
echo - Removed all batch files

echo.
echo Step 3: Recreating directory structure...
mkdir src\MacTrackpadDashboard
mkdir src\MacTrackpadSetup
mkdir src\MacTrackpadTest
echo - Created fresh directory structure

echo.
echo Step 4: Running repair script to create all required files...
call verify_and_repair.bat

echo.
echo Step 5: Creating enhanced dashboard...
call create_enhanced_dashboard.bat

echo.
echo Installation complete!
echo.
echo You can now run mac_trackpad_tools_enhanced.bat to begin testing.
echo.
pause