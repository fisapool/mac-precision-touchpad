@echo off
echo ===== Building Mac Trackpad Driver =====
echo Configuration: %1

REM Set default configuration to Debug if not specified
if "%1" == "" set CONFIG=Debug
if not "%1" == "" set CONFIG=%1

echo Building in %CONFIG% mode...

REM Build the driver project
msbuild /p:Configuration=%CONFIG% /p:Platform=x64 src\driver\AmtPtpDeviceUsbKm.vcxproj
if %ERRORLEVEL% neq 0 (
    echo Driver build failed!
    exit /b 1
)

REM Build the test project
msbuild /p:Configuration=%CONFIG% /p:Platform=AnyCPU src\MacTrackpadTest\MacTrackpadTest.csproj
if %ERRORLEVEL% neq 0 (
    echo Test project build failed!
    exit /b 1
)

echo Build completed successfully! 