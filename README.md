# Introduction 
Dockerfiles for creating an ALC compiler image with all default dependencies from Microsoft. Special conisideration was to limit the number of environment variables to an absolute minimum. If additional parameters and / or dependencies are needed you should override the default docker CMD in your RUN command.

# Build the image

For building the image you need to specify certain build arguments:

- BASE: The base tag for the release channel of your architecture e.g.: 1709, 1803, 1909
- NCHVERSION: The version of Freddy's navcontainerhelper. Only used in the intermediate image for pulling and extracting the artifacts.
- TYPE, COUNTRY, VERSION: These arguments are passed into Freddy Scripts. See the possible values in Freddy description of Get-BCArtifactUrl.

The image itself is build by the following:`

```
docker build -t <imagename>:<tag> --build-arg BASE=<sac tag> --build-arg NCHVERSION=<Version> --build-arg TYPE=<OnPrem/Sandbox> --build-arg COUNTRY=<de> --build-arg VERSION=<16.2.13509.13779> -f .\Dockerfile.nano .
```

# Run the container

```
docker run -v <App Folder Host>:C:\src -v -e RulesetFile="c:\src\Cop.ruleset.json" --memory 10G --name alcnano --rm alc:<tag>
```

# Choosing the right image

If you don't have any dotnet declarations you should be able to use the much smaller Nanoserver Image. Elsewise you got to choose the servercore image due to it contains the .Net framework.
