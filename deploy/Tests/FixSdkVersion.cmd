@echo off
echo === Fixing .NET SDK Version ===
echo.

echo Looking for global.json...
if exist "global.json" (
    echo Found global.json file
    echo Do you want to:
    echo 1. Remove global.json file (recommended)
    echo 2. Skip this step
    echo.
    
    set /p CHOICE="Enter your choice (1-2): "
    
    if "%CHOICE%"=="1" (
        del /f /q global.json
        echo Removed global.json file
    ) else (
        echo Skipping global.json removal
    )
) else (
    echo No global.json file found, no action needed
)

echo.
echo SDK version fix complete
echo Try running your tests again
echo.

pause 