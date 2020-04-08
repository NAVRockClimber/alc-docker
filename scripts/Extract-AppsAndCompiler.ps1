New-Item -Path "C:\alc\depedencies" -ItemType Directory -Force
New-Item -Path "C:\alc\compiler" -ItemType Directory -Force

$apps = Get-ChildItem -Path C:\Applications\ -Filter *.app -Recurse
foreach ($app in $apps) {
    $AppFileName = Join-Path -Path "C:\alc\depedencies" -ChildPath $app.Name
    Write-Host "Copying $($app.Name) to $($AppFileName)"
    Copy-Item -Path $app.FullName -Destination $AppFileName -Force
}
