@echo off
echo ===== Fixing VSCode C/C++ Configuration =====
echo.

echo Creating simplified c_cpp_properties.json file...
if not exist ".vscode" mkdir ".vscode"

echo {> ".vscode\c_cpp_properties.json"
echo     "configurations": [>> ".vscode\c_cpp_properties.json"
echo         {>> ".vscode\c_cpp_properties.json"
echo             "name": "Win32",>> ".vscode\c_cpp_properties.json"
echo             "includePath": [>> ".vscode\c_cpp_properties.json"
echo                 "${workspaceFolder}/**",>> ".vscode\c_cpp_properties.json"
echo                 "C:/Program Files (x86)/Windows Kits/10/Include/10.0.22621.0/um",>> ".vscode\c_cpp_properties.json"
echo                 "C:/Program Files (x86)/Windows Kits/10/Include/10.0.22621.0/ucrt",>> ".vscode\c_cpp_properties.json"
echo                 "C:/Program Files (x86)/Windows Kits/10/Include/10.0.22621.0/shared">> ".vscode\c_cpp_properties.json"
echo             ],>> ".vscode\c_cpp_properties.json"
echo             "defines": [>> ".vscode\c_cpp_properties.json"
echo                 "_DEBUG",>> ".vscode\c_cpp_properties.json"
echo                 "UNICODE",>> ".vscode\c_cpp_properties.json"
echo                 "_UNICODE">> ".vscode\c_cpp_properties.json"
echo             ],>> ".vscode\c_cpp_properties.json"
echo             "windowsSdkVersion": "10.0.22621.0",>> ".vscode\c_cpp_properties.json"
echo             "compilerPath": "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.37.32822/bin/Hostx64/x64/cl.exe",>> ".vscode\c_cpp_properties.json"
echo             "cStandard": "c17",>> ".vscode\c_cpp_properties.json"
echo             "cppStandard": "c++17",>> ".vscode\c_cpp_properties.json"
echo             "intelliSenseMode": "windows-msvc-x64">> ".vscode\c_cpp_properties.json"
echo         }>> ".vscode\c_cpp_properties.json"
echo     ],>> ".vscode\c_cpp_properties.json"
echo     "version": 4>> ".vscode\c_cpp_properties.json"
echo }>> ".vscode\c_cpp_properties.json"

echo.
echo Configuration file updated successfully!
echo.
echo Note: This simplified configuration removes Windows Driver Kit (WDK) paths
echo that were required for building the actual driver but aren't needed
echo for your testing environment.
echo.
pause 