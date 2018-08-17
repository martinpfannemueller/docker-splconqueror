FROM ubuntu:16.04
MAINTAINER Martin Pfannemüller (martin.pfannemueller@uni-mannheim.de)

# Install dependencies
RUN apt-get update
RUN apt-get install -y mono-complete git curl tzdata apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Fetch SPLConqueror
RUN git clone https://github.com/se-passau/SPLConqueror.git
RUN git -C ./SPLConqueror/ submodule update --init --recursive

# Install DotNet CLI/SDK
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list'

RUN apt-get update
RUN apt-get install -y dotnet-sdk-2.1

# Get latest nuget and restore dependencies
RUN curl -O https://dist.nuget.org/win-x86-commandline/v3.3.0/nuget.exe
#https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
RUN mono nuget.exe restore ./SPLConqueror/SPLConqueror/SPLConqueror.sln

# Build CommandLine project
RUN xbuild ./SPLConqueror/SPLConqueror/SPLConqueror.sln /p:Configuration=Release /p:TargetFrameworkVersion="v4.5" /t:CommandLine

# Set SPLC CLI as entrypoint
ENTRYPOINT ["mono", "./SPLConqueror/SPLConqueror/CommandLine/bin/Release/CommandLine.exe"]
