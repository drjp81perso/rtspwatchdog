#!/bin/bash

TARGETARCH="amd64"
VERSION="7.2.5"
if [ "$TARGETARCH" = "amd64" ]; then \
      PWSHURL=https://github.com/PowerShell/PowerShell/releases/download/v${VERSION}/powershell-${VERSION}-linux-x64.tar.gz; \
    fi; \
    if [ "$TARGETARCH" = "arm64" ]; then \
      PWSHURL= https://github.com/PowerShell/PowerShell/releases/download/v${VERSION}/powershell-${VERSION}-linux-arm32.tar.gz; \
    fi; \
    if [ "$TARGETARCH" = "arm" ]; then \
      PWSHURL= https://github.com/PowerShell/PowerShell/releases/download/v${VERSION}/powershell-${VERSION}-linux-arm64.tar.gz; \
    fi; \
    wget "$PWSHURL" -O /tmp/powershell.tar.gz
