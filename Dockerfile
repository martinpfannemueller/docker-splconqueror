FROM mono
MAINTAINER Martin Pfannemüller (martin.pfannemueller@uni-mannheim.de)

RUN apt-get update && apt-get install -y git

# Fetch SPLConqueror
RUN git clone https://github.com/se-passau/SPLConqueror.git
RUN git -C ./SPLConqueror/ submodule update --init --recursive

# Get nuget and restore dependencies
RUN curl -O https://dist.nuget.org/win-x86-commandline/v3.3.0/nuget.exe
RUN mono nuget.exe restore ./SPLConqueror/SPLConqueror/SPLConqueror.sln

# Build CommandLine project
RUN xbuild ./SPLConqueror/SPLConqueror/SPLConqueror.sln /p:Configuration=Release /p:TargetFrameworkVersion="v4.5" /t:CommandLine

# Set SPLC CLI as entrypoint
ENTRYPOINT ["mono", "./SPLConqueror/SPLConqueror/CommandLine/bin/Release/CommandLine.exe"]