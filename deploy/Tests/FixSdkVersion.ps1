# Script to fix .NET SDK version issues
Write-Host "=== Fixing .NET SDK Version ===" -ForegroundColor Cyan
Write-Host ""

$globalJsonPath = Join-Path $PSScriptRoot "global.json"

# Get the installed SDK version
$installedSdk = dotnet --list-sdks | Select-Object -First 1
if ($installedSdk -match '(\d+\.\d+\.\d+)') {
    $installedVersion = $matches[1]
    Write-Host "Detected installed SDK version: $installedVersion" -ForegroundColor Green
} else {
    Write-Host "Could not detect installed SDK version" -ForegroundColor Red
    exit 1
}

# Option 1: Remove global.json (uses latest installed SDK)
if (Test-Path $globalJsonPath) {
    Write-Host "Found global.json at: $globalJsonPath" -ForegroundColor Yellow
    Write-Host "Do you want to:"
    Write-Host "1. Remove global.json (recommended)"
    Write-Host "2. Update global.json to use version $installedVersion"
    Write-Host "3. Skip this step"
    
    $choice = Read-Host "Enter your choice (1-3)"
    
    switch ($choice) {
        "1" {
            Remove-Item $globalJsonPath -Force
            Write-Host "Removed global.json" -ForegroundColor Green
        }
        "2" {
            $jsonContent = @{
                sdk = @{
                    version = $installedVersion
                    rollForward = "latestFeature"
                }
            } | ConvertTo-Json -Depth 3
            
            Set-Content -Path $globalJsonPath -Value $jsonContent
            Write-Host "Updated global.json to use SDK version $installedVersion" -ForegroundColor Green
        }
        "3" {
            Write-Host "Skipping global.json update" -ForegroundColor Yellow
        }
        default {
            Write-Host "Invalid choice. Skipping global.json update" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No global.json found, no action needed" -ForegroundColor Green
}

# Update project file target framework if needed
$csprojPath = Join-Path $PSScriptRoot "MacTrackpadTest.csproj"
if (Test-Path $csprojPath) {
    $content = Get-Content $csprojPath -Raw
    
    if ($content -match '<TargetFramework>net6.0</TargetFramework>' -and $installedVersion.StartsWith("9.")) {
        Write-Host "Project targets .NET 6.0 but you have .NET 9.0 installed" -ForegroundColor Yellow
        Write-Host "Do you want to update the target framework to net7.0? (y/n)"
        
        $updateTarget = Read-Host
        if ($updateTarget -eq "y") {
            $content = $content -replace '<TargetFramework>net6.0</TargetFramework>', '<TargetFramework>net7.0</TargetFramework>'
            Set-Content -Path $csprojPath -Value $content
            Write-Host "Updated target framework to net7.0" -ForegroundColor Green
        } else {
            Write-Host "Target framework not updated" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "SDK version compatibility check complete" -ForegroundColor Cyan
Write-Host "Try running your tests again" -ForegroundColor Cyan 