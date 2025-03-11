@echo off
echo Running Mac Trackpad Dashboard...

REM Check if the dashboard was built
if not exist "Dashboard\MacTrackpadDashboard\bin\Debug\net6.0-windows\MacTrackpadDashboard.exe" (
    echo Dashboard not built yet. Building now...
    cd Dashboard
    dotnet build
    cd ..
)

REM Launch the dashboard
start "" "Dashboard\MacTrackpadDashboard\bin\Debug\net6.0-windows\MacTrackpadDashboard.exe" 