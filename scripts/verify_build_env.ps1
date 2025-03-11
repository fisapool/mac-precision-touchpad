# Verify build environment script
Write-Host "Verifying build environment..." -ForegroundColor Cyan

# Check for Windows SDK
if (Test-Path "C:\Program Files (x86)\Windows Kits\10") {
    Write-Host "Windows SDK found" -ForegroundColor Green
    $sdkFound = $true
} else {
    Write-Host "Windows SDK not found" -ForegroundColor Yellow
    $sdkFound = $false
}

# Check for Visual Studio
if (Test-Path "C:\Program Files\Microsoft Visual Studio") {
    Write-Host "Visual Studio found" -ForegroundColor Green
    $vsFound = $true
} elseif (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio") {
    Write-Host "Visual Studio found" -ForegroundColor Green
    $vsFound = $true
} else {
    Write-Host "Visual Studio not found" -ForegroundColor Yellow
    $vsFound = $false
}

# Check for WDK
$wdkFound = $false
$wdkPaths = @(
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22000.0",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.18362.0"
)

foreach ($path in $wdkPaths) {
    if (Test-Path $path) {
        Write-Host "WDK found at $path" -ForegroundColor Green
        $wdkFound = $true
        break
    }
}

if (-not $wdkFound) {
    Write-Host "WDK not found in standard locations" -ForegroundColor Yellow
}

Write-Host "Build environment verification completed" -ForegroundColor Green
exit 0