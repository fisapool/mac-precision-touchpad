@echo off
echo === MacTrackpad Standalone Tests ===
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory
cd /d "%SCRIPT_DIR%"

echo Current directory: %CD%

REM Build with minimal requirements and specific files only
echo Building standalone test...
dotnet build /p:DefineConstants="STANDALONE_BUILD" /p:WarningLevel=0

echo.
echo === Running Standalone Tests ===
echo.

REM Run only standalone tests
dotnet test --filter "TestCategory=Standalone" --logger "console;verbosity=detailed"

echo.
if %ERRORLEVEL% EQU 0 (
    echo === Standalone tests completed successfully ===
) else (
    echo === Standalone tests failed ===
)

pause
exit /b %ERRORLEVEL% 