Write-Host $env:errorlog
Write-Host $env:loglevel
Write-Host $env:readonlyerrorsaswarnings
Write-Host $env:assemblyprobingpaths
Write-Host $env:project
Write-Host $env:out
Write-Host $env:packagecachepath

Write-Host "Running alc"
\alc\compiler\alc.exe /project:$env:project /out:$env:out /packagecachepath:$env:packagecachepath /assemblyprobingpaths:$env:assemblyprobingpaths