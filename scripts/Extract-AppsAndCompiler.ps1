$ServiceManagementModule = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service\Microsoft.Dynamics.Nav.Apps.Management.psd1").FullName
Import-Module $ServiceManagementModule -DisableNameChecking

New-Item -Path "C:\alc\depedencies" -ItemType Directory -Force
New-Item -Path "C:\alc\compiler" -ItemType Directory -Force

$apps = Get-NAVAppInfo -ServerInstance BC
foreach ($app in $apps) {
    $AppFileName = Join-Path -Path "C:\alc\depedencies" -ChildPath "$($app.Name).app"
    Write-Host "Exporting $($app.Name) to $($AppFileName)"
    Get-NavAppRuntimePackage -ServerInstance BC -Name $app.Name -Path $AppFileName
    Write-Host "Finished"
}
