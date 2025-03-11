@echo off
echo === MacTrackpad Test Diagnostics ===
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory
cd /d "%SCRIPT_DIR%"

echo Building test project from: %CD%
dotnet build

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed
    exit /b %ERRORLEVEL%
)

echo.
echo === Running Diagnostic Tests ===
echo.

REM Run only the diagnostic tests
dotnet test --filter "TestCategory=Diagnostics" --logger "console;verbosity=detailed"

echo.
if %ERRORLEVEL% EQU 0 (
    echo === All diagnostic tests passed successfully ===
) else (
    echo === Some tests failed ===
)

exit /b %ERRORLEVEL% 