#Prepare folder structure
New-Item -Path "C:\alc\depedencies" -ItemType Directory -Force | Out-Null
New-Item -Path "C:\alc\compiler" -ItemType Directory -Force | Out-Null
New-Item -Path "C:\alc\assemblies" -ItemType Directory -Force | Out-Null
New-Item -Path "C:\Build" -ItemType Directory -Force | Out-Null

# Copy app files into create folder structure
Write-Host "-------------------------------------------------------------------------"
Write-Host "Copying app files"
$apps = Get-ChildItem -Path C:\Applications\ -Filter *.app -Recurse
foreach ($app in $apps) {
    $AppFileName = Join-Path -Path "C:\alc\depedencies" -ChildPath $app.Name
    Write-Host "Copying $($app.Name) to $($AppFileName)"
    Copy-Item -Path $app.FullName -Destination $AppFileName -Force
}

# Get AL Compiler and move it into created folder structure
Write-Host "-------------------------------------------------------------------------"
Write-Host "Extracting Compiler"
$tempZip = Join-Path -Path $env:TEMP -ChildPath "alc.zip"
Copy-item -Path (Get-Item -Path "c:\run\*.vsix").FullName -Destination $tempZip
Expand-Archive -Path $tempZip -DestinationPath "c:\build\vsix"
Copy-Item -Path C:\Build\vsix\extension\bin\* -Destination C:\alc\compiler -Recurse

# Copy assemblies into created structure
Write-Host "-------------------------------------------------------------------------"
Write-Host "Copy assemblies"
$roleTailoredClientFolder = "C:\Program Files (x86)\Microsoft Dynamics NAV\*\RoleTailored Client"
$xmlLibFolder = "C:\Program Files (x86)\Open XML SDK\V2.5\lib"
$mockAssembliesFolder = "C:\Test Assemblies\Mock Assemblies"
$serviceTierFolder = (Get-Item "C:\Program Files\Microsoft Dynamics NAV\*\Service")

if (Test-Path $roleTailoredClientFolder) {
    Copy-Item -Path $roleTailoredClientFolder -Destination "C:\alc\assemblies\RTC" -Recurse
}
if (Test-Path $serviceTierFolder) {
    Copy-Item -Path $serviceTierFolder -Destination "C:\alc\assemblies\ServiceTier" -Recurse
}
if (Test-Path $xmlLibFolder) {
    Copy-Item -Path $xmlLibFolder -Destination "C:\alc\assemblies\OpenXMLLibs" -Recurse
}
if (Test-Path $mockAssembliesFolder) {
    Copy-Item -Path $mockAssembliesFolder -Destination "C:\alc\assemblies\MockAssemblies" -Recurse
}

# Generate a Password
$url = "https://makemeapassword.ligos.net/api/v1/alphanumeric/json?c=1&l=12"
$Password = (Invoke-RestMethod -ContentType "application/json" -Uri $url).pws

# Set environment variables and fire up BC
Write-Host "-------------------------------------------------------------------------"
Write-Host "Extract System App"
# Better pass this though to give the user the possibility to accept Microsofts EULA
$env:Accept_eula = $env:Accept_MS_Eula
$env:Accept_outdated ='Y' 
$env:useSSL = 'N'
$env:username = 'admin'
$env:password = ("{0}" -f $Password)
Write-Host ("Generated Password: {0}" -f $env:password)
& c:/Run/navstart.ps1 

# Extract System app file from service
Write-Host ("Extracting System App")
$publisher = "Microsoft"
$appName="System"
$appVersion="15.0.0.0"
$tenant="default"
$url = "http://$($env:COMPUTERNAME):7049/BC/dev/packages?publisher=$([uri]::EscapeDataString($publisher))&appName=$([uri]::EscapeDataString($appName))&versionText=$($appVersion)&tenant=$tenant"
$pair = ("admin:{0}" -f $Password)
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue }
$authParam += @{ "headers" = $headers }
$appFile = ("C:\alc\depedencies\{0}_{1}.app" -f $publisher, $appName)
Invoke-RestMethod -ContentType "application/octet-stream" -Method Get -Uri $url @AuthParam -OutFile $appFile 
Write-Host "-------------------------------------------------------------------------"
Write-Host "Finished extracting compiler and dependencies"
Write-Host "Docker will take a while for committing everything and going on."