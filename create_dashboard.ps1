# Create a simple dashboard for the Mac Trackpad driver
Write-Host "Creating Mac Trackpad Dashboard..." -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = $scriptPath

# Create dashboard directory
$dashboardDir = Join-Path $projectRoot "src\MacTrackpadDashboard"
if (-not (Test-Path $dashboardDir)) {
    New-Item -ItemType Directory -Path $dashboardDir -Force | Out-Null
    Write-Host "Created dashboard directory" -ForegroundColor Green
}

# Create a simple HTML dashboard
$dashboardContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Mac Trackpad Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }
        .status {
            margin: 20px 0;
            padding: 15px;
            border-radius: 5px;
        }
        .status.good {
            background-color: #dff0d8;
            color: #3c763d;
        }
        .status.warning {
            background-color: #fcf8e3;
            color: #8a6d3b;
        }
        .status.error {
            background-color: #f2dede;
            color: #a94442;
        }
        .action-button {
            display: inline-block;
            margin: 10px 5px;
            padding: 10px 15px;
            background-color: #337ab7;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        .action-button:hover {
            background-color: #286090;
        }
        .settings {
            margin-top: 20px;
            padding: 15px;
            background-color: #e8e8e8;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Mac Trackpad Driver Dashboard</h1>
        
        <div class="status good">
            <strong>Status:</strong> The trackpad driver is functioning properly.
        </div>
        
        <div>
            <a href="#" class="action-button">Install Driver</a>
            <a href="#" class="action-button">Uninstall Driver</a>
            <a href="#" class="action-button">Run Tests</a>
            <a href="#" class="action-button">Check for Updates</a>
        </div>
        
        <h2>Driver Information</h2>
        <table>
            <tr>
                <th>Property</th>
                <th>Value</th>
            </tr>
            <tr>
                <td>Driver Version</td>
                <td>1.0.0 (Mock)</td>
            </tr>
            <tr>
                <td>Installation Date</td>
                <td>$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</td>
            </tr>
            <tr>
                <td>Device Status</td>
                <td>Connected (Simulated)</td>
            </tr>
            <tr>
                <td>Test Mode</td>
                <td>Enabled</td>
            </tr>
        </table>
        
        <h2>Recent Events</h2>
        <table>
            <tr>
                <th>Time</th>
                <th>Event</th>
                <th>Status</th>
            </tr>
            <tr>
                <td>$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</td>
                <td>Driver Initialization</td>
                <td>Success</td>
            </tr>
            <tr>
                <td>$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</td>
                <td>Mock Test Run</td>
                <td>Completed</td>
            </tr>
        </table>
        
        <div class="settings">
            <h2>Settings</h2>
            <p>These settings are for demonstration purposes only.</p>
            <form>
                <div>
                    <label>
                        <input type="checkbox" checked> Enable Multi-touch Gestures
                    </label>
                </div>
                <div>
                    <label>
                        <input type="checkbox" checked> Enable Palm Rejection
                    </label>
                </div>
                <div>
                    <label>
                        <input type="checkbox" checked> Enable Advanced Features
                    </label>
                </div>
                <div>
                    <label>Tracking Speed:</label>
                    <input type="range" min="1" max="10" value="5">
                </div>
                <div>
                    <button type="button" class="action-button">Save Settings</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
"@

$dashboardPath = Join-Path $dashboardDir "dashboard.html"
Set-Content -Path $dashboardPath -Value $dashboardContent

# Create a batch file to open the dashboard
$launcherPath = Join-Path $dashboardDir "LaunchDashboard.bat"
$launcherContent = @"
@echo off
start "" "%~dp0dashboard.html"
"@

Set-Content -Path $launcherPath -Value $launcherContent

Write-Host "Dashboard created at: $dashboardPath" -ForegroundColor Green
Write-Host "You can open it by running: $launcherPath" -ForegroundColor Cyan 