@echo off
echo ===== Mac Trackpad Test Runner =====
echo.
echo Running tests in mock mode (no hardware required)...
powershell -ExecutionPolicy Bypass -File "%~dp0RunAllMockTests.ps1"
