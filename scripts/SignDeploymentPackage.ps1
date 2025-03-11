param (
    [Parameter(Mandatory=$true)]
    [string]$CertificatePath,
    
    [Parameter(Mandatory=$true)]
    [string]$CertificatePassword,
    
    [Parameter(Mandatory=$true)]
    [string]$DeploymentPath,
    
    [string]$TimestampServer = "http://timestamp.digicert.com"
)

$ErrorActionPreference = "Stop"

Write-Host "===== Mac Trackpad Driver Package Digital Signing =====" -ForegroundColor Cyan
Write-Host ""

# Verify certificate exists
if (-not (Test-Path $CertificatePath)) {
    Write-Host "ERROR: Certificate file not found at $CertificatePath" -ForegroundColor Red
    exit 1
}

# Extract driver files path
$driverPath = Join-Path $DeploymentPath "Driver"
if (-not (Test-Path $driverPath)) {
    Write-Host "ERROR: Driver directory not found at $driverPath" -ForegroundColor Red
    exit 1
}

# Sign driver files
Write-Host "Signing driver files..." -ForegroundColor Green
$driverFiles = Get-ChildItem -Path $driverPath -Filter "*.sys"
foreach ($file in $driverFiles) {
    Write-Host "Signing $($file.Name)..." -ForegroundColor Yellow
    
    & signtool.exe sign /f $CertificatePath /p $CertificatePassword /tr $TimestampServer /td sha256 /fd sha256 $file.FullName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to sign $($file.Name)" -ForegroundColor Red
        exit 1
    }
}

# Sign catalog files
$catalogFiles = Get-ChildItem -Path $driverPath -Filter "*.cat"
foreach ($file in $catalogFiles) {
    Write-Host "Signing $($file.Name)..." -ForegroundColor Yellow
    
    & signtool.exe sign /f $CertificatePath /p $CertificatePassword /tr $TimestampServer /td sha256 /fd sha256 $file.FullName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to sign $($file.Name)" -ForegroundColor Red
        exit 1
    }
}

# Sign application files
$dashboardPath = Join-Path $DeploymentPath "Dashboard"
if (Test-Path $dashboardPath) {
    Write-Host "Signing dashboard application..." -ForegroundColor Green
    $exeFiles = Get-ChildItem -Path $dashboardPath -Filter "*.exe" -Recurse
    foreach ($file in $exeFiles) {
        Write-Host "Signing $($file.Name)..." -ForegroundColor Yellow
        
        & signtool.exe sign /f $CertificatePath /p $CertificatePassword /tr $TimestampServer /td sha256 /fd sha256 $file.FullName
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to sign $($file.Name)" -ForegroundColor Red
            exit 1
        }
    }
    
    $dllFiles = Get-ChildItem -Path $dashboardPath -Filter "*.dll" -Recurse
    foreach ($file in $dllFiles) {
        Write-Host "Signing $($file.Name)..." -ForegroundColor Yellow
        
        & signtool.exe sign /f $CertificatePath /p $CertificatePassword /tr $TimestampServer /td sha256 /fd sha256 $file.FullName
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to sign $($file.Name)" -ForegroundColor Red
            exit 1
        }
    }
    
    $msiFiles = Get-ChildItem -Path $dashboardPath -Filter "*.msi" -Recurse
    foreach ($file in $msiFiles) {
        Write-Host "Signing $($file.Name)..." -ForegroundColor Yellow
        
        & signtool.exe sign /f $CertificatePath /p $CertificatePassword /tr $TimestampServer /td sha256 /fd sha256 $file.FullName
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to sign $($file.Name)" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""
Write-Host "===== Digital Signing Complete =====" -ForegroundColor Green
Write-Host "" 