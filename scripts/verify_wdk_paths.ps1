# Verify WDK paths
$wdkPaths = @(
    "C:\Program Files (x86)\Windows Kits\10\Include\wdf\kmdf\1.15",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\km",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\shared",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\km\crt",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\shared\minwin",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\km\wdf",
    "C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\km\usb"
)

$allPathsExist = $true

foreach ($path in $wdkPaths) {
    if (-not (Test-Path $path)) {
        Write-Host "Missing path: $path" -ForegroundColor Red
        $allPathsExist = $false
    }
}

if ($allPathsExist) {
    Write-Host "All WDK paths verified successfully!" -ForegroundColor Green
} else {
    Write-Host "Some WDK paths are missing. Please install or repair WDK." -ForegroundColor Yellow
    exit 1
} 