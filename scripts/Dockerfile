ARG BaseImageVersion
FROM ${BaseImageVersion} AS builder
ARG Accept_MS_Eula
ENV Accept_MS_eula=${Accept_MS_Eula}    
COPY Extract-AppsAndCompiler.ps1 C:/run/Extract-AppsAndCompiler.ps1
RUN Powershell -Command C:\run\Extract-AppsAndCompiler.ps1


# seems only the sdk image contains the powershell
# FROM mcr.microsoft.com/dotnet/core/sdk:3.1
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8 
ENV errorlog=c:\\logs\\error.log \
    loglevel=Normal \
    readonlyerrorsaswarnings=false \
    assemblyprobingpaths=C:\\alc\\assemblies \ 
    project=c:\\project \
    out=c:\\artifact \
    packagecachepath=C:\\alc\\depedencies
COPY --from=builder ["C:/alc", "C:/alc/"] 
COPY Compile-AlApp.ps1 c:/alc/scripts/Compile-AlApp.ps1

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
# SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

CMD .\alc\scripts\Compile-AlApp.ps1
# CMD  pwsh.exe