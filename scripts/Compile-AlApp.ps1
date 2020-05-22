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
Join-Path -Path $env:project -ChildPath ".netpackages"
if (Test-Path $ProjectAssemblies) {
    $assemblyProbingPaths += '"' + ($ProjectAssemblies) + '"'
}
if (Test-Path -Path $env:assemblyprobingpaths) {
    $assemblyProbingPaths += '"' + ($env:assemblyprobingpaths) + '"'
}
$assemblyProbingPaths += '"' + "c:\windows\assembly" + '"'
$alcassemblyProbingPath = $assemblyProbingPaths -join ","
Write-Host ("Total Assembly Path {0}" -f $alcassemblyProbingPath)


Write-Host "Running alc"
if (Test-Path -Path "\alc\compiler\win32")
{
    Write-Host "Found dotnet core compiler." 
    Write-Host "Using dotnet core compiler."
    \alc\compiler\win32\alc.exe /project:$env:project /out:$env:out /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$alcassemblyProbingPath /errorlog:$env:errorlog
} else {
    \alc\compiler\alc.exe /project:$env:project /out:$env:out /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$alcassemblyProbingPath /errorlog:$env:errorlog
}
