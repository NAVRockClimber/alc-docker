function BuildAssemblyProbingPath { 
    param (
        [Parameter(Mandatory = $true)][string]$ProjectFolder,
        [Parameter(Mandatory = $true)][string]$CustomFolder
    )

    $assemblyProbingPaths = @()
    $assemblyFolders = Get-ChildItem -Path "C:\alc\assemblies"
    foreach ($folder in $assemblyFolders) {
        $assemblyProbingPaths += '"' + ($folder.FullName) + '"'
    }
    $ProjectAssemblies = Join-Path -Path $ProjectFolder -ChildPath ".netpackages"
    if (Test-Path $ProjectAssemblies) {
        $assemblyProbingPaths += '"' + ($ProjectAssemblies) + '"'
    }
    if (Test-Path -Path $CustomFolder) {
        $assemblyProbingPaths += '"' + ($CustomFolder) + '"'
    }
    $WindowAssembliesPath = "c:\windows\assembly"
    if (Test-Path -Path $WindowAssembliesPath) {
        $assemblyProbingPaths += '"' + $WindowAssembliesPath + '"'
    }
    return $assemblyProbingPaths -join ","
}

function Get-AppJsonFile {
    param (
        [Parameter(Mandatory = $true)][string]$BasePath
    )
    
    $appfolder = $env:project
    if ($env:appfolder -ne " ") {
        $appfolder = Join-Path -Path $env:project -ChildPath $env:appfolder
        if ((Test-Path -Path $appfolder) -eq $false) {
            Write-Host "Error cannot find folder containing app to compile."
            exit(1)
        }
    }

    $AppJsonFile = (Get-ChildItem -Path $appfolder -Filter app.json -Recurse)[0].FullName
    return $AppJsonFile
}

function Build-ArtifactName {
    param (
        [Parameter(Mandatory = $true)][string]$AppJsonFile,
        [Parameter(Mandatory = $true)][string]$OutFolder
    )
    
    $AppJson = Get-Content -Raw -Path $AppJsonFile | ConvertFrom-Json
    $PublisherName = $AppJson.publisher
    $AppName = $AppJson.name 
    $ArtifactName = '"' + (Join-Path -Path $OutFolder -ChildPath ("{0}_{1}.app" -f $PublisherName, $AppName)) + '"'
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    $ArtifactName = $ArtifactName -replace $re

    return $ArtifactName
}

function Get-RulesetFile {
    param (
        [Parameter(Mandatory = $true)][string]$AppFolder,
        [string]$RulesetFileName
    )
    
    if (($RulesetFileName -ne " ") -and ($null -ne $RulesetFileName)) {
        $rulesetfile = Get-ChildItem -Path $appfolder -Include *.json -Filter $RulesetFileName -Recurse
    }
    else {    
        $rulesetfile = Get-ChildItem -Path $appfolder -Include *.json -Filter "*ruleset*" -Recurse
    }
    return $rulesetfile
}

Write-Host $env:errorlog
Write-Host $env:loglevel
Write-Host $env:readonlyerrorsaswarnings
Write-Host $env:assemblyprobingpaths
Write-Host $env:project
Write-Host $env:out
Write-Host $env:packagecachepath

[int]$PSMajorVersion = [int]$PSVersionTable.PSVersion.Major
$PSMajorVersion.GetType()
$AppJsonFile = Get-AppJsonFile -BasePath $env:project
Write-Host ("Found app file: '{0}'" -f $AppJsonFile) $PSMajorVersion
if ($PSMajorVersion -ge 7) {
    $appfolder = Split-Path -Path $AppJsonFile -Parent
    Write-Host ("Powershell {0} detected" -f $PSMajorVersion)
}
else {
    Write-Host ("Powershell {0} found" -f $PSMajorVersion)
    $appfolder = Split-Path -Path $AppJsonFile.FullName -Paren
}
Write-Host ("Using '{0}' as project folder" -f $appfolder) 

[string]$alcassemblyProbingPath = BuildAssemblyProbingPath -ProjectFolder $appfolder -CustomFolder $env:assemblyprobingpaths
Write-Host ("Total assembly probing path {0}" -f $alcassemblyProbingPath)

$ArtifactName = Build-ArtifactName -AppJsonFile $AppJsonFile -OutFolder $env:out 

$rulesetfile = Get-RulesetFile -AppFolder $appfolder -RulesetFileName $env:rulesetfile
Write-Host ("Using ruleset file: {0}" -f $rulesetfile) 

Write-Host "Running alc"
/alc/compiler/alc.exe /?
try {
    if (Test-Path -Path "\alc\compiler\win32") {
        Write-Host "Found dotnet core compiler." 
        Write-Host "Using dotnet core compiler."
        \alc\compiler\win32\alc.exe /project:$appfolder /out:$ArtifactName /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$alcassemblyProbingPath /errorlog:$env:errorlog
    }
    else {
        \alc\compiler\alc.exe /project:$appfolder /out:$ArtifactName /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$alcassemblyProbingPath /errorlog:$env:errorlog
    }
}
catch {
    Write-Host "An error occurred. Trying to write error log."
    Move-Item -Path $TempErrorLogFile -Destination $TargetErrorLogFile -Filter *.* -Force
}
/alc/compiler/alc.exe /?