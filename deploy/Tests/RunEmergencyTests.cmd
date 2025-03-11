@echo off
echo === MacTrackpad Emergency Tests ===
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory
cd /d "%SCRIPT_DIR%"

echo Current directory: %CD%

REM Try to build with minimal requirements
echo Building only essential files...
dotnet build /p:DefineConstants="EMERGENCY_BUILD"

echo.
echo === Running Emergency Tests ===
echo.

REM Run only emergency tests
dotnet test --filter "TestCategory=Emergency" --logger "console;verbosity=detailed"

echo.
if %ERRORLEVEL% EQU 0 (
    echo === Emergency tests completed ===
) else (
    echo === Emergency tests failed ===
)

pause
exit /b %ERRORLEVEL% 