@echo off
echo ===== Mac Trackpad Driver Installer =====
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
echo Installing driver...
pnputil /add-driver "%~dp0..\Driver\*.inf" /install

echo.
echo Installation complete!
echo Please restart your computer to complete the installation.
pause
