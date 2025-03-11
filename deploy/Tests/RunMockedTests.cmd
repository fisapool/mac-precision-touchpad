@echo off
echo === MacTrackpad Tests (MOCK MODE) ===
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Change to the script directory
cd /d "%SCRIPT_DIR%"

echo Current directory: %CD%
echo.
echo Running tests with mock driver (no actual hardware needed)
echo.

REM Set environment variable to enable mock mode
set DOTNET_MOCK_DRIVER=true

REM Run tests with mock driver, excluding the original test classes
echo Running STANDALONE tests...
dotnet test --filter "TestCategory=Standalone" --logger "console;verbosity=detailed"
echo.

echo Running PERFORMANCE tests with adapter...
dotnet test --filter "FullyQualifiedName~MacTrackpadTest.Tests.PerformanceTestAdapter" --logger "console;verbosity=detailed"
echo.

echo Running INSTALLATION tests with adapter...
dotnet test --filter "FullyQualifiedName~MacTrackpadTest.Tests.InstallationTestAdapter" --logger "console;verbosity=detailed"
echo.

echo Running FUNCTIONALITY tests...
dotnet test --filter "TestCategory=Functionality" --logger "console;verbosity=detailed"
echo.

echo === All mock tests completed ===
pause
exit /b %ERRORLEVEL% 