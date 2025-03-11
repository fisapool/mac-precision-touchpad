# VSCode-specific test runner to help with test discovery issues
param (
    [switch]$RefreshTests,
    [string]$Filter = ""
)

$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($RefreshTests) {
    # Fix test discovery and rebuild
    Write-Host "Refreshing test configuration..." -ForegroundColor Cyan
    & (Join-Path $testDir "fix-test-discovery.ps1")
}

# Create test settings if they don't exist
$vsCodeSettingsDir = Join-Path $testDir ".vscode"
if (-not (Test-Path $vsCodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vsCodeSettingsDir | Out-Null
}

$vsCodeSettingsFile = Join-Path $vsCodeSettingsDir "settings.json"
$settingsContent = @"
{
    "dotnet-test-explorer.testProjectPath": "**/*.csproj",
    "dotnet-test-explorer.testArguments": "--verbosity detailed",
    "dotnet-test-explorer.autoWatch": true,
    "dotnet-test-explorer.showCodeLens": true,
    "dotnet-test-explorer.codeLensFailed": "❌",
    "dotnet-test-explorer.codeLensPassed": "✅"
}
"@

Set-Content -Path $vsCodeSettingsFile -Value $settingsContent

# Run tests with appropriate filter
Push-Location $testDir
try {
    if ([string]::IsNullOrEmpty($Filter)) {
        Write-Host "Running all tests..." -ForegroundColor Cyan
        dotnet test --verbosity detailed
    } else {
        Write-Host "Running tests matching: $Filter" -ForegroundColor Cyan
        dotnet test --filter $Filter --verbosity detailed
    }
} finally {
    Pop-Location
} 