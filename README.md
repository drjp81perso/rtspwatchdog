# rtspwatchdog
Simple app/service to watch your RTSP/RTMP (or any other [FFMPEG](https://ffmpeg.org/) compatible streams)

# What is it?

I couldn't find an app that I liked, that would watch my RTSP streams and alert me when they were no longer available. So I wrote a configurable service that could watch multiple streams (any [FFPROBE](HTTPS://FFMPEG.ORG/FFPROBE.HTML) compatible stream) so if you use RTMP or even HTTP mjpeg, in principle, this should work

The whole thing is written in powershell. Yes PowerShell.

One, because I'm comfortable with it and two I am familiar.
Lastly I wanted to see if it could be done, it turns out it can.

# What does it do?

Simple, from a list of configured sources, it checks, via [ffprobe](https://ffmpeg.org/ffprobe.html), if they are available.
If so, gives you the opportunity to run a command (wget in the vanilla example)
Same happens of the source becomes unavailable.

**NOTE:** While the source's state stays the same, no new commands are sent.
# Getting started

I have exposed different flavours of the images in my docker hub repo

The default image/tag drjp81/camwatchdog:latest is the linux/arm64 and linux/arm32 variants. 
For amd64 your have to use the amd64-latest tag.

Pull the right version in docker

Run a modified version of the docker-compose.yml to suit your needs

## Option Linux
You could just install powershell in linux and run the watch.ps1 file in a cron job.

## Configurations
The [./vanilla.json](./vanilla.json) file is a "vanilla" version of the required "config.json" file that holds your configuration.

The service looks in /app/config/ for the config.json, and if it doesn't exist, it copies the vanilla file to it (internally from /app/config/).

So if you prepared one of your own and would like to have a persistent config, use docker's volume mounting option to point to it. (/app/config/config.json)


## Configuration file example

```
{
    "config": {
        "sources": {
            "doorbell": {
                "url": "rtsp://admin:password@127.0.0.1",
                "timeout": 30,
                "commands_offline": "wget 'http://192.168.0.2/cameraon?cam=@@name@@&state=off' -O /dev/null",
                "commands_online": "wget 'http://192.168.0.2/cameraon?cam=@@name@@&state=on' -O /dev/null"
            }
        },
        "interval": 30,
        "[ffprobe](https://ffmpeg.org/ffprobe.html)path": "/usr/bin/[ffprobe](https://ffmpeg.org/ffprobe.html)"
        
    }
}
```
Each source is defined in a json file, here we have a stream from the "doorbell"

1. The url defines the stream we want to probe
2. The timeout determines the maximum amount of time (in seconds) [ffprobe](https://ffmpeg.org/ffprobe.html) will wait before it gets an answer (it also defines the analyzeduration parameter: it is 2 seconds shorter).
3. commands_offline: what to execute if the feed can't be probed successfully (here I use a web hook like command with wget) 
4. command_offline: same as above but when it comes back online 

The commands are limited by the install/image (not much in there), but there is all of the latest powershell core commands :D


And those define a source

The two other configurations are:

1. The interval what are the interval between the scans (in seconds)
2. The path to [ffprobe](https://ffmpeg.org/ffprobe.html) in your system

**note:** The interval is the hard limit to which the sources' timeout compare. So if you set a higher or equal value value to your sources' timeout it will ignore it and adjust to the lower interval value. 

### ToDo: 
~~- Spread out the probes across the interval to use the cpu/threads more uniformly instead of spiking it with a bunch of async processes.~~
- Some more debuggimg...

# Licensing

Copyright (c) 2002 by Jean-Paul Lizotte

Professional identification: Jean-Paul Lizotte, Chief of Devops / DEVSECOPS Practice - Strategic consultant - Technical sales support - MCP / jp.lizotte (at) drjpsoftware.com

URL: [https://www.linkedin.com/in/jplizotte/](https://www.linkedin.com/in/jplizotte/)


All Rights Reserved
ATTRIBUTION ASSURANCE LICENSE (adapted from the original BSD license)
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the conditions below are met.
These conditions require a modest attribution to Jean-Paul Lizotte (the
"Author"), who hopes that its promotional value may help justify the
value in otherwise billable time invested in writing
this and other freely available, open-source software.

1. Redistributions of source code, in whole or part and with or without
modification (the "Code"), must prominently display this GPG-signed
text in verifiable form.
2. Redistributions of the Code in binary form must be accompanied by
this GPG-signed text in any documentation and, each time the resulting
executable program or a program dependent thereon is launched, a
prominent display (e.g., splash screen or banner text) of the Author's
attribution information, which includes:
(a) Name ("AUTHOR"),
(b) Professional identification ("PROFESSIONAL IDENTIFICATION"), and
(c) URL ("URL").
3. Neither the name nor any trademark of the Author may be used to
endorse or promote products derived from this software without specific
prior written permission.
4. Users are entirely responsible, to the exclusion of the Author and
any other persons, for compliance with (1) regulations set by owners or
administrators of employed equipment, (2) licensing terms of any other
software, and (3) local regulations regarding use, including those
regarding import, export, and use of encryption software.
5. This software includes references to other open source work and and any 
licenses or copyrights are the property and responsibility or their respective owners. 

THIS FREE SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL THE AUTHOR OR ANY CONTRIBUTOR BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
EFFECTS OF UNAUTHORIZED OR MALICIOUS NETWORK ACCESS;
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Cheers!
