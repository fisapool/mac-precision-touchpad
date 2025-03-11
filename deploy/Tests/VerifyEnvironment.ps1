# Simple script to verify the .NET environment

Write-Host "=== Environment Verification ===" -ForegroundColor Cyan
Write-Host ""

# Check .NET SDK version
$dotnetVersion = dotnet --version
Write-Host ".NET SDK Version: $dotnetVersion" -ForegroundColor Yellow

# Check MSTest availability
$mstestAvailable = dotnet list package | Select-String "MSTest"
if ($mstestAvailable) {
    Write-Host "MSTest packages are installed" -ForegroundColor Green
} else {
    Write-Host "MSTest packages may not be installed" -ForegroundColor Red
}

# Check project structure
$csprojFiles = Get-ChildItem -Path . -Filter *.csproj -Recurse
Write-Host "Found $($csprojFiles.Count) project files:" -ForegroundColor Yellow
foreach ($file in $csprojFiles) {
    Write-Host "  - $($file.FullName)" -ForegroundColor Cyan
}

# Verify test assemblies
$testDlls = Get-ChildItem -Path . -Filter *Test*.dll -Recurse
Write-Host "Found $($testDlls.Count) test assemblies:" -ForegroundColor Yellow
foreach ($dll in $testDlls) {
    Write-Host "  - $($dll.FullName)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== Verification Complete ===" -ForegroundColor Cyan 