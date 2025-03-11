# Build script for dashboard
$ErrorActionPreference = "Stop"

# Set paths
$solutionPath = ".\Dashboard\MacTrackpadDashboard.sln"
$configuration = "Release"
$platform = "x64"

Write-Host "Building dashboard..." -ForegroundColor Yellow

try {
    # Build solution
    dotnet build $solutionPath -c $configuration

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dashboard built successfully!" -ForegroundColor Green
    } else {
        throw "Build failed with exit code $LASTEXITCODE"
    }
}
catch {
    Write-Host "Build failed: $_" -ForegroundColor Red
    exit 1
}