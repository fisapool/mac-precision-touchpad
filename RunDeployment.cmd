@echo off
echo ===== Mac Trackpad Driver Deployment Launcher =====
echo.

echo Running PowerShell script with execution policy bypass...
powershell -ExecutionPolicy Bypass -File "%~dp0SetupDeployment.ps1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Setup completed successfully!
) else (
    echo.
    echo Setup failed with error code %ERRORLEVEL%
)

pause 