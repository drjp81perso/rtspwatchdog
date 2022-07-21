# rtspwatchdog
Simple app/service to watch your RTSP/RTMP (or any other [FFMPEG](https://ffmpeg.org/) compatible streams)

# What is it?

I couldn't find an app that I liked, that would watch my RTSP streams and alert me when they were no longer available. So I wrote a configurable service that could watch multiple streams (any [FFPROBE](HTTPS://FFMPEG.ORG/FFPROBE.HTML) compatible stream) so if you use RTMP or even HTTP mjpeg, in principle, this should work

The whole thing is written in powershell. Yes PowerShell.

One, because I'm comfortable with it and two I am familiar.
Lastly I wanted to see if it could be done, it turns out it can.

# What does it do?

Simple, from a list of configured sources, it checks, via [ffprobe](https://ffmpeg.org/ffprobe.html), if they are available.
If so, gives you the opportunity to run a command (wget in the [./vanilla.json](./vanilla.json) example)
Same happens when the source becomes unavailable, a specific command is launched then.

**NOTE:** While the source's state/availability **stays the same**, no new commands are sent.
# Getting started

I have exposed different flavours of the images in my [**docker hub repo**](https://hub.docker.com/repository/docker/drjp81/camwatchdog)

The default image/tag drjp81/camwatchdog:latest a linux/arm64, linux/amd64 and linux/arm32 variant. 

Pull the image into docker then execute

```
docker run -ti -d -v {yourvolumeforpersistentconfig}:/app/config --name watchdog drjp81/camwatchdog:latest
```
AND/OR 

Run a modified version of the docker-compose.yml to suit your needs

OR

Build your own from source

## Option Linux
You could just install powershell in linux and run the watch.ps1 file in a cron job.
I have 3 public flavours (arm/arm64/amd64) of powershell core 7.2.5 in my docker repo: [**drjp81/powershell**](https://hub.docker.com/repository/docker/drjp81/powershell)

# Configurations
The [./vanilla.json](./vanilla.json) file is a "vanilla" version of the required "config.json" file that normally represents your configuration.

The service looks in /app/config/ directory for the config file (config.json) , and if it doesn't exist, it is generated from the vanilla.json (internally from /app/config/).

So if you prepared a config file of your own and would like it to persist, use Docker's volume mounting option to point to it. (/app/config/config.json)


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
        "ffprobepath": "/usr/bin/ffprobe"
        
    }
}
```
Each "source" is defined in a json file. Here we have a stream from the "doorbell" named as such.

1. The url defines the stream we want to probe
2. The timeout determines the maximum amount of time (in seconds) [ffprobe](https://ffmpeg.org/ffprobe.html) will wait before it gets an answer (it also defines the analyzeduration parameter: it is 2 seconds shorter).
An important note about this parameter. It could turn out that **the cycle time is LONGER that this interval.** Which means, the time taken to verify all your sources, is actually longer than the interval you have set. If this is your case, there will be "0" seconds of wait (or sleeping time) between check/loops. Perhaps this is desired for systems that need a more critical analysis of the sources.  
3. commands_offline: what to execute if the feed can't be probed successfully (here I use a web hook like command with wget) 
4. command_offline: same as above but when it comes back online 

- The commands are limited by the install/image (not much in there), but there is all of the latest powershell core commands, so the possibilities are actually quite vast. :D
- The commands are scanned for the token **@@name@@** this will be replaced by the name of the source

And those elements, define a complete source. (all of them are required!)

The two other configurations are:

1. The interval what are the interval between the scans (in seconds)
2. The path to [ffprobe](https://ffmpeg.org/ffprobe.html) in your system

**note:** The interval is the hard limit to which the sources' timeout compare. So if you set a higher or equal value value to your sources' timeout it will ignore it and adjust to the lower interval value. 

## About the process

The [**watch.ps1**](./watch.ps1) file is a bootstrapper that will get (download) [**process.ps1**](./process.ps1) and will save it to the "/app/scripts" directory under the name "work.ps1" then, it will attempt to launch it.

This is so we don't have to rebuild the docker image every time a bug fix comes along. It is in effect, auto updated every time it starts. Of course, you can use your own repo/url it the need be.

# FAQ
- What if I don't want to launch a command upon the camera coming back online?
    - Just put a command like "echo camera @@name@@ back" or something. 
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
