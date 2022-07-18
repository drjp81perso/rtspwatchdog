FROM drjp81/powershell as build

ARG TARGETARCH
ARG TARGETPLATFORM
RUN apt update && apt install -y wget ffmpeg 

FROM build
RUN mkdir -p /app/config
RUN mkdir -p /app/vanilla
RUN mkdir -p /app/script

SHELL [ "/usr/bin/pwsh" ]

COPY ./vanilla.json /app/vanilla/
COPY ./watch.ps1 /app/script/
COPY ./health.ps1 /app/script/

HEALTHCHECK --interval=60s --timeout=15s CMD ["/usr/bin/pwsh", "-file", "/app/script/health.ps1"]
CMD ["/usr/bin/pwsh","-file", "/app/script/watch.ps1"]

