ARG BaseImageVersion
FROM ${BaseImageVersion} AS builder
COPY Extract-AppsAndCompiler.ps1 C:/run/Extract-AppsAndCompiler.ps1
COPY Compile-AlApp.ps1 c:/alc/scripts/Compile-AlApp.ps1
RUN Powershell -Command C:\run\Extract-AppsAndCompiler.ps1


FROM mcr.microsoft.com/dotnet/framework/runtime:4.8
ENV errorlog=c:\\logs\\error.log \
    loglevel=Normal \
    readonlyerrorsaswarnings=false \
    assemblyprobingpaths=C:\\alc\\assemblies \ 
    project=c:\\project \
    out=c:\\artifact \
    packagecachepath=C:\\alc\\depedencies
COPY --from=builder ["C:/alc", "C:/alc/"] 

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

CMD .\alc\scripts\Compile-AlApp.ps1