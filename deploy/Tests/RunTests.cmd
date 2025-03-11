@echo off
echo === MacTrackpad Test Runner ===
echo.

REM Ensure we have the right environment for .NET tests
where dotnet >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: .NET SDK not found in PATH
    echo Please install the .NET SDK from https://dotnet.microsoft.com/download
    exit /b 1
)

REM Change to project directory
cd %~dp0

echo Building test project...
dotnet build MacTrackpadTest.csproj

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed
    exit /b %ERRORLEVEL%
)

echo.
echo === Running Tests ===
echo.

REM Run the tests using MSTest (not pytest)
dotnet test MacTrackpadTest.csproj --logger "console;verbosity=detailed"

echo.
if %ERRORLEVEL% EQU 0 (
    echo === All tests passed successfully ===
) else (
    echo === Some tests failed ===
)

exit /b %ERRORLEVEL% 