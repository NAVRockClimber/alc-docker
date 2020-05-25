Write-Host $env:errorlog
Write-Host $env:loglevel
Write-Host $env:readonlyerrorsaswarnings
Write-Host $env:assemblyprobingpaths
Write-Host $env:project
Write-Host $env:out
Write-Host $env:packagecachepath

$assemblyProbingPaths = @()
$assemblyFolders = Get-ChildItem -Path "C:\alc\assemblies"
foreach ($folder in $assemblyFolders) {
    $assemblyProbingPaths += '"' + ($folder.FullName) + '"'
    Write-Host ("Assembly Path: {0}" -f $folder.FullName)
}
$ProjectAssemblies = Join-Path -Path $env:project -ChildPath ".netpackages"
if (Test-Path $ProjectAssemblies) {
    $assemblyProbingPaths += '"' + ($ProjectAssemblies) + '"'
    Write-Host ("Assembly Path: {0}" -f $ProjectAssemblies)
}
if (Test-Path -Path $env:assemblyprobingpaths) {
    $assemblyProbingPaths += '"' + ($env:assemblyprobingpaths) + '"'
    Write-Host ("Assembly Path: {0}" -f $env:assemblyprobingpaths)
}
$WindowAssembliesPath = "c:\windows\assembly"
if (Test-Path -Path $WindowAssembliesPath)
{
    $assemblyProbingPaths += '"' + $WindowAssembliesPath + '"'
    Write-Host ("Windows Assembly Path: {0}" -f $WindowAssembliesPath)
}
$alcassemblyProbingPath = $assemblyProbingPaths -join ","
Write-Host ("Total assembly probing path {0}" -f $alcassemblyProbingPath)

$appfolder = $env:project
if ($env:appfolder -ne "")
{
    $appfolder = Join-Path -Path $env:project -ChildPath $env:appfolder
    if ((Test-Path -Path $appfolder) -eq $false)
    {
        Write-Host "Error cannot find folder containing app to compile."
        exit(1)
    }
}
Write-Host ("Using '{0}' as project folder" -f $appfolder) 

$AppJsonFile = Get-ChildItem -Path $appfolder -Filter app.json
$AppJson = Get-Content -Raw -Path $AppJsonFile.FullName | ConvertFrom-Json
$PublisherName = $AppJson.publisher
$AppName = $AppJson.name 
# $ArtifactName = '"' + (Join-Path -Path "C:\tmp\artifact" -ChildPath ("{0}_{1}.app" -f $PublisherName, $AppName)) + '"'
$ArtifactName = '"' + (Join-Path -Path $env:out -ChildPath ("{0}_{1}.app" -f $PublisherName, $AppName)) + '"'
$invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
$re = "[{0}]" -f [RegEx]::Escape($invalidChars)
$ArtifactName = $ArtifactName -replace $re

Write-Host "Running alc"
try
{
    if (Test-Path -Path "\alc\compiler\win32")
    {
        Write-Host "Found dotnet core compiler." 
        Write-Host "Using dotnet core compiler."
        \alc\compiler\win32\alc.exe /project:$appfolder /out:$ArtifactName /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$alcassemblyProbingPath /errorlog:$env:errorlog
    } else {
        \alc\compiler\alc.exe /project:$appfolder /out:$ArtifactName /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$alcassemblyProbingPath /errorlog:$env:errorlog
    }
} catch {
    Write-Host "An error occurred. Trying to write error log."
    Move-Item -Path $TempErrorLogFile -Destination $TargetErrorLogFile -Filter *.* -Force
}

# Move-Item -Path $TempErrorLogFile -Destination $env:errorlog -Force