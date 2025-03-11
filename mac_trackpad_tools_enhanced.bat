@echo off
color 1F
cls
echo =======================================
echo   Mac Trackpad Driver - Control Panel
echo =======================================
echo.
echo   1. Open HTML Dashboard
echo   2. Open C# Dashboard (if built)
echo   3. Run Installation Simulation
echo   4. Run Uninstallation Simulation
echo   5. Run Mock Tests
echo   ------------------------------
echo   6. System Check
echo   7. Status Monitor
echo   8. Help Documentation
echo   9. Verify and Repair
echo   0. Exit
echo.
echo =======================================
echo.

set /p choice=Enter your choice (0-9): 

if "%choice%"=="1" (
    call open_dashboard.bat
    goto menu
)

if "%choice%"=="2" (
    call launch_dashboard.bat
    goto menu
)

if "%choice%"=="3" (
    call run_install.bat
    goto menu
)

if "%choice%"=="4" (
    call run_uninstall.bat
    goto menu
)

if "%choice%"=="5" (
    call run_tests.bat
    goto menu
)

if "%choice%"=="6" (
    call system_check.bat
    goto menu
)

if "%choice%"=="7" (
    call monitor_status.bat
    goto menu
)

if "%choice%"=="8" (
    call show_help.bat
    goto menu
)

if "%choice%"=="9" (
    call verify_and_repair.bat
    goto menu
)

if "%choice%"=="0" (
    echo.
    echo Exiting...
    exit /b
)

echo.
echo Invalid choice. Please try again.
echo.
pause
goto menu

:menu
cls
echo =======================================
echo   Mac Trackpad Driver - Control Panel
echo =======================================
echo.
echo   1. Open HTML Dashboard
echo   2. Open C# Dashboard (if built)
echo   3. Run Installation Simulation
echo   4. Run Uninstallation Simulation
echo   5. Run Mock Tests
echo   ------------------------------
echo   6. System Check
echo   7. Status Monitor
echo   8. Help Documentation
echo   9. Verify and Repair
echo   0. Exit
echo.
echo =======================================
echo.

set /p choice=Enter your choice (0-9): 

if "%choice%"=="1" (
    call open_dashboard.bat
    goto menu
)

if "%choice%"=="2" (
    call launch_dashboard.bat
    goto menu
)

if "%choice%"=="3" (
    call run_install.bat
    goto menu
)

if "%choice%"=="4" (
    call run_uninstall.bat
    goto menu
)

if "%choice%"=="5" (
    call run_tests.bat
    goto menu
)

if "%choice%"=="6" (
    call system_check.bat
    goto menu
)

if "%choice%"=="7" (
    call monitor_status.bat
    goto menu
)

if "%choice%"=="8" (
    call show_help.bat
    goto menu
)

if "%choice%"=="9" (
    call verify_and_repair.bat
    goto menu
)

if "%choice%"=="0" (
    echo.
    echo Exiting...
    exit /b
)

echo.
echo Invalid choice. Please try again.
echo.
pause
goto menu 