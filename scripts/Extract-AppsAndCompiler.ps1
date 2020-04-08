New-Item -Path "C:\alc\depedencies" -ItemType Directory -Force
New-Item -Path "C:\alc\compiler" -ItemType Directory -Force
New-Item -Path "C:\Build" -ItemType Directory -Force

$apps = Get-ChildItem -Path C:\Applications\ -Filter *.app -Recurse
foreach ($app in $apps) {
    $AppFileName = Join-Path -Path "C:\alc\depedencies" -ChildPath $app.Name
    Write-Host "Copying $($app.Name) to $($AppFileName)"
    Copy-Item -Path $app.FullName -Destination $AppFileName -Force
}

$tempZip = Join-Path -Path $env:TEMP -ChildPath "alc.zip"
Copy-item -Path (Get-Item -Path "c:\run\*.vsix").FullName -Destination $tempZip
Expand-Archive -Path $tempZip -DestinationPath "c:\build\vsix"
Copy-Item -Path C:\Build\vsix\extension\bin\* -Destination C:\alc\compiler -Recurse

Write-Host "Finished"