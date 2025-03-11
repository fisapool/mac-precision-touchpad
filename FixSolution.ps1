# Run this script to create a proper solution file

$projectPath = Join-Path $PWD "src\MacTrackpadTest\MacTrackpadTest.csproj"
$projectGuid = [guid]::NewGuid().ToString("B").ToUpper()
$solutionGuid = [guid]::NewGuid().ToString("B").ToUpper()

$solutionContent = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{9A19103F-16F7-4668-BE54-9A1E7A4F7556}") = "MacTrackpadTest", "$projectPath", "$projectGuid"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		$projectGuid.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		$projectGuid.Debug|Any CPU.Build.0 = Debug|Any CPU
		$projectGuid.Release|Any CPU.ActiveCfg = Release|Any CPU
		$projectGuid.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = $solutionGuid
	EndGlobalSection
EndGlobal
"@

$solutionContent | Out-File -FilePath "MacTrackpad.sln" -Encoding utf8
Write-Host "Solution file created successfully!" 