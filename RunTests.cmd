@echo off
echo === MacTrackpad Test Runner ===
echo.

REM Change to the test project directory
cd /d "%~dp0src\MacTrackpadTest"

if not exist "RunStandaloneTest.cmd" (
    echo ERROR: Test scripts not found in %CD%
    exit /b 1
)

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