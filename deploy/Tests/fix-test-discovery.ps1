# Comprehensive script to fix test discovery issues
Write-Host "=== MacTrackpad Test Discovery Fixer ===" -ForegroundColor Cyan

# Remove any VS Test cache if present
$cacheDir = Join-Path $env:TEMP "VisualStudioTestExplorerExtensions"
if (Test-Path $cacheDir) {
    Write-Host "Removing test explorer cache..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $cacheDir -ErrorAction SilentlyContinue
}

# Create proper test configuration file
Write-Host "Creating test configuration..." -ForegroundColor Yellow
$testConfigContent = @"
{
  "testRunner": "mstest",
  "testFramework": "MSTestV2",
  "testAdapter": "MSTest",
  "configuration": {
    "logging": "verbose"
  }
}
"@

Set-Content -Path (Join-Path $PSScriptRoot ".testconfig") -Value $testConfigContent

# Create additional configuration for VS Test runner
$vsTestConfigContent = @"
{
  "TargetPlatform": "x64",
  "TestAdaptersPaths": [ "." ],
  "DiagnosticsDirectory": "TestResults/Logs",
  "LoggerRunSettings": {
    "Loggers": [
      {
        "Logger": "console;verbosity=detailed"
      },
      {
        "Logger": "trx"
      }
    ]
  }
}
"@

Set-Content -Path (Join-Path $PSScriptRoot ".runsettings") -Value $vsTestConfigContent

# Create global.json to ensure consistent SDK version
$globalJsonContent = @"
{
  "sdk": {
    "version": "6.0.100",
    "rollForward": "latestFeature"
  }
}
"@

Set-Content -Path (Join-Path $PSScriptRoot "global.json") -Value $globalJsonContent

# Create Directory.Build.props if it doesn't exist
$dirBuildPropsContent = @"
<Project>
  <PropertyGroup>
    <IsTestProject>true</IsTestProject>
    <VSTestLogger>trx</VSTestLogger>
    <VSTestVerbosity>detailed</VSTestVerbosity>
  </PropertyGroup>
</Project>
"@

Set-Content -Path (Join-Path $PSScriptRoot "Directory.Build.props") -Value $dirBuildPropsContent

# Install or update required packages
Write-Host "Installing test packages..." -ForegroundColor Yellow
Push-Location $PSScriptRoot
try {
    dotnet add package Microsoft.NET.Test.Sdk --version 17.5.0
    dotnet add package MSTest.TestAdapter --version 3.0.2
    dotnet add package MSTest.TestFramework --version 3.0.2
    dotnet add package coverlet.collector --version 3.2.0
} finally {
    Pop-Location
}

# Force a clean and rebuild
Write-Host "Rebuilding test project..." -ForegroundColor Yellow
Push-Location $PSScriptRoot
try {
    dotnet clean
    dotnet build --no-incremental
} finally {
    Pop-Location
}

# Run the diagnostic test to verify discovery is working
Write-Host "Running diagnostic test..." -ForegroundColor Yellow
Push-Location $PSScriptRoot
try {
    dotnet test --filter "FullyQualifiedName~TestDiscoveryDiagnostics" --verbosity detailed
} catch {
    Write-Host "Diagnostic test failed to run. Error: $_" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host "Test discovery configuration fixed." -ForegroundColor Green
Write-Host "If tests are still not discovered, try restarting Visual Studio or your IDE." -ForegroundColor Yellow 