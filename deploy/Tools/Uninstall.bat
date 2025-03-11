@echo off
echo ===== Mac Trackpad Driver Uninstaller =====
echo.

echo Checking for administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo.
echo Uninstalling driver...
pnputil /delete-driver AmtPtpDevice.inf /uninstall /force

echo.
echo Uninstallation complete!
echo Please restart your computer to complete the uninstallation.
pause
