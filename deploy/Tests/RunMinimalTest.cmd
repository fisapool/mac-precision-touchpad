@echo off
echo === MacTrackpad Minimal Test ===
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory
cd /d "%SCRIPT_DIR%"

echo Current directory: %CD%

REM Build only the minimal required files
echo Building minimal test...
dotnet build /p:DefineConstants="EMERGENCY_BUILD;MINIMAL_ONLY" /p:WarningLevel=0

echo.
echo === Running Minimal Test ===
echo.

REM Run only the simplest diagnostic test
dotnet test --filter "FullyQualifiedName=MacTrackpadTest.SimpleDiagnosticTest.TestBasicFunctionality" --logger "console;verbosity=detailed"

echo.
if %ERRORLEVEL% EQU 0 (
    echo === Minimal test completed successfully ===
) else (
    echo === Minimal test failed ===
)

pause
exit /b %ERRORLEVEL% 