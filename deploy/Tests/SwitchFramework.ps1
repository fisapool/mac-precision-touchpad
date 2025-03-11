# Script to switch target framework based on installed .NET versions
Write-Host "=== .NET Framework Switcher ===" -ForegroundColor Cyan
Write-Host ""

# Get installed .NET runtimes
$runtimes = dotnet --list-runtimes | Where-Object { $_ -match 'Microsoft\.NETCore\.App\s+(\d+\.\d+\.\d+)' } | ForEach-Object {
    if ($_ -match '(\d+\.\d+)\.\d+') {
        $matches[1]  # Return just the major.minor version
    }
}

# Remove duplicates and sort
$runtimes = $runtimes | Sort-Object -Unique

Write-Host "Detected installed .NET runtimes:" -ForegroundColor Green
$i = 1
$runtimeMap = @{}
foreach ($runtime in $runtimes) {
    Write-Host "$i. .NET $runtime" -ForegroundColor White
    $runtimeMap[$i.ToString()] = $runtime
    $i++
}

Write-Host ""
$choice = Read-Host "Select target framework to use (1-$($i-1))"

if ($runtimeMap.ContainsKey($choice)) {
    $selectedRuntime = $runtimeMap[$choice]
    
    # Update the project file
    $csprojPath = Join-Path $PSScriptRoot "MacTrackpadTest.csproj"
    $content = Get-Content $csprojPath -Raw
    
    # Replace existing target framework
    $newContent = $content -replace '<TargetFramework>net\d+\.\d+</TargetFramework>', "<TargetFramework>net$selectedRuntime</TargetFramework>"
    
    Set-Content -Path $csprojPath -Value $newContent
    Write-Host "Updated target framework to .NET $selectedRuntime" -ForegroundColor Green
    
    # Clean and rebuild
    Write-Host "`nCleaning previous build artifacts..." -ForegroundColor Yellow
    Remove-Item -Path (Join-Path $PSScriptRoot "bin") -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $PSScriptRoot "obj") -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "Done. Try running your tests now!" -ForegroundColor Cyan
} else {
    Write-Host "Invalid choice. No changes made." -ForegroundColor Red
} 