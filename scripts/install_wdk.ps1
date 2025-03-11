# Download WDK installer
$wdkUrl = "https://go.microsoft.com/fwlink/?linkid=2196230"
$outputPath = "$env:TEMP\wdksetup.exe"
Invoke-WebRequest -Uri $wdkUrl -OutFile $outputPath

# Install WDK
Write-Host "Installing Windows Driver Kit..."
Start-Process -Wait -FilePath $outputPath -ArgumentList "/features + /q"

# Verify installation
$wdkPath = "C:\Program Files (x86)\Windows Kits\10"
if (Test-Path $wdkPath) {
    Write-Host "WDK installed successfully at $wdkPath"
} else {
    Write-Error "WDK installation failed"
    exit 1
} 