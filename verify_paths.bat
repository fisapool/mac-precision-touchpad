@echo off
setlocal

set WDK_ROOT=C:\Program Files (x86)\Windows Kits\10
set WDK_INC=%WDK_ROOT%\Include\10.0.22000.0

echo Checking WDK paths...

if not exist "%WDK_ROOT%" (
    echo ERROR: WDK not found at %WDK_ROOT%
    exit /b 1
)

if not exist "%WDK_INC%\km" (
    echo ERROR: WDK km headers not found at %WDK_INC%\km
    exit /b 1
)

if not exist "%WDK_INC%\shared" (
    echo ERROR: WDK shared headers not found at %WDK_INC%\shared
    exit /b 1
)

echo All paths verified successfully
exit /b 0 