# Setup deployment environment script
Write-Host "Setting up Mac Trackpad deployment environment..." -ForegroundColor Cyan

# Determine the repository root directory
# If we're in the src/MacTrackpadTest directory, go up two levels
$currentDir = Get-Location
$repoRoot = $currentDir

if ($currentDir -match "\\src\\MacTrackpadTest$") {
    $repoRoot = (Get-Item $currentDir).Parent.Parent.FullName
    Write-Host "Moving up to repository root: $repoRoot" -ForegroundColor Yellow
}

# Create scripts directory if it doesn't exist
$scriptsDir = Join-Path $repoRoot "scripts"
if (-not (Test-Path $scriptsDir)) {
    Write-Host "Creating scripts directory: $scriptsDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $scriptsDir | Out-Null
}

# Create docs directory if it doesn't exist
$docsDir = Join-Path $repoRoot "docs"
if (-not (Test-Path $docsDir)) {
    Write-Host "Creating docs directory: $docsDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $docsDir | Out-Null
}

# Create GitHub workflows directory if it doesn't exist
$githubDir = Join-Path $repoRoot ".github"
if (-not (Test-Path $githubDir)) {
    New-Item -ItemType Directory -Path $githubDir | Out-Null
}
$workflowsDir = Join-Path $githubDir "workflows"
if (-not (Test-Path $workflowsDir)) {
    Write-Host "Creating GitHub workflows directory: $workflowsDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $workflowsDir | Out-Null
}

# Copy scripts from current directory if they exist
$sourceFiles = @(
    "BuildDeploymentPackage.ps1",
    "DiagnosticTool.ps1",
    "SignDeploymentPackage.ps1"
)

foreach ($file in $sourceFiles) {
    $sourcePath = Join-Path $currentDir $file
    $destPath = Join-Path $scriptsDir $file
    
    if (Test-Path $sourcePath) {
        Write-Host "Moving $file to scripts directory..." -ForegroundColor Green
        Copy-Item -Path $sourcePath -Destination $destPath -Force
    }
}

# Create a verify_build_env.ps1 script if it doesn't exist
$verifyScriptPath = Join-Path $scriptsDir "verify_build_env.ps1"
if (-not (Test-Path $verifyScriptPath)) {
    $verifyContent = @"
# Verify build environment script
Write-Host "Verifying build environment..." -ForegroundColor Cyan

# Check for Windows SDK
if (Test-Path "C:\Program Files (x86)\Windows Kits\10") {
    Write-Host "✓ Windows SDK found" -ForegroundColor Green
} else {
    Write-Host "✗ Windows SDK not found" -ForegroundColor Red
    exit 1
}

# Check for Visual Studio
if (Test-Path "C:\Program Files\Microsoft Visual Studio") {
    Write-Host "✓ Visual Studio found" -ForegroundColor Green
} else {
    Write-Host "✗ Visual Studio not found" -ForegroundColor Red
    exit 1
}

Write-Host "Build environment verification completed successfully" -ForegroundColor Green
exit 0
"@
    Set-Content -Path $verifyScriptPath -Value $verifyContent
    Write-Host "Created verify_build_env.ps1 script" -ForegroundColor Green
}

# Copy documentation to docs directory
$docFiles = @(
    "InstallationGuide.md",
    "DashboardUserGuide.md"
)

foreach ($file in $docFiles) {
    $sourcePath = Join-Path $currentDir $file
    $destPath = Join-Path $docsDir $file
    
    if (Test-Path $sourcePath) {
        Write-Host "Moving $file to docs directory..." -ForegroundColor Green
        Copy-Item -Path $sourcePath -Destination $destPath -Force
    }
}

# Copy GitHub workflow file
$workflowFile = "build-deployment-package.yml"
$sourcePath = Join-Path $currentDir $workflowFile
$destPath = Join-Path $workflowsDir $workflowFile

if (Test-Path $sourcePath) {
    Write-Host "Moving $workflowFile to GitHub workflows directory..." -ForegroundColor Green
    Copy-Item -Path $sourcePath -Destination $destPath -Force
}

Write-Host "`nDeployment environment setup completed!" -ForegroundColor Green
Write-Host "`nTo build a deployment package, run:" -ForegroundColor Cyan
Write-Host "  cd $repoRoot" -ForegroundColor Yellow
Write-Host "  .\scripts\BuildDeploymentPackage.ps1 -Version `"1.2.0`" -IncludeTests" -ForegroundColor Yellow
Write-Host "`nTo sign a deployment package, run:" -ForegroundColor Cyan
Write-Host "  .\scripts\SignDeploymentPackage.ps1 -CertificatePath `".\cert\MyCert.pfx`" -CertificatePassword `"password`" -DeploymentPath `".\Deploy`"" -ForegroundColor Yellow 