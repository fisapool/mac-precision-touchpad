@echo off
echo === MacTrackpad Tests (Root Runner) ===
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory - no need for complex path calculations
cd /d "%SCRIPT_DIR%"

echo Located test directory at: %CD%
echo.
echo === Available Test Runners ===
echo 1. Run Standalone Tests (most reliable)
echo 2. Run Minimal Tests
echo 3. Run Diagnostic Tests
echo 4. Run All Tests (may fail if there are issues)
echo.

:PROMPT
set /p CHOICE="Enter your choice (1-4): "

if "%CHOICE%"=="1" (
    echo.
    echo Running Standalone Tests...
    call RunStandaloneTest.cmd
    goto END
)

if "%CHOICE%"=="2" (
    echo.
    echo Running Minimal Tests...
    call RunMinimalTest.cmd
    goto END
)

if "%CHOICE%"=="3" (
    echo.
    echo Running Diagnostic Tests...
    call RunDiagnosticTests.cmd
    goto END
)

if "%CHOICE%"=="4" (
    echo.
    echo Running All Tests...
    dotnet test
    goto END
)

echo Invalid choice. Please enter a number between 1 and 4.
goto PROMPT

:END
exit /b %ERRORLEVEL% 