FROM debian

RUN apt update && apt install -y wget ffmpeg nano
# Download the powershell '.tar.gz' archive
RUN wget  https://github.com/PowerShell/PowerShell/releases/download/v7.2.5/powershell-7.2.5-linux-arm64.tar.gz -O /tmp/powershell.tar.gz

# Create the target folder where powershell will be placed
RUN mkdir -p /opt/microsoft/powershell/7

# Expand powershell to the target folder
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

# Set execute permissions
RUN chmod +x /opt/microsoft/powershell/7/pwsh

# Create the symbolic link that points to pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

RUN mkdir -p /app/config
RUN mkdir -p /app/vanilla
RUN mkdir -p /app/script

SHELL [ "/usr/bin/pwsh" ]

COPY ./vanilla.json /app/vanilla/
COPY ./watch.ps1 /app/script/
COPY ./health.ps1 /app/script/

HEALTHCHECK --interval=60s --timeout=15s CMD ["/usr/bin/pwsh", "-file", "/app/script/health.ps1"]
CMD ["/usr/bin/pwsh","-file", "/app/script/watch.ps1"]

