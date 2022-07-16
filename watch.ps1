$global:configfile = gci /app/config/config.json -ErrorAction Ignore

if (-not $global:configfile) {
    Copy-Item /app/vanilla/vanilla.json -Destination /app/config/config.json
    chmod +x /app/config/config.json
}

if (-not (gci /app/script/pid.file -ErrorAction Ignore )) {
    Set-Content /app/script/pid.file -Value $PID
    chmod +x /app/script/pid.file
}

function loadconfig {
    try {
        $tempconfig = Join-Path $PSScriptRoot -ChildPath ".\config.json"
        if (gci $tempconfig -ErrorAction Ignore)
        {
            $global:config = Get-Content $tempconfig | Convertfrom-Json #reload config each loop, for dynamic config
        
        }
        else {
            $global:config = Get-Content /app/config/config.json | Convertfrom-Json #reload config each loop, for dynamic config
            <# Action when all if and elseif conditions are false #>
        }
         #reload config each loop, for dynamic config
        $global:thelist = $global:config.config.sources | Get-ObjectMember
    }
    catch {
        { Write-error "Config file invalid or not found!" }
    }
    return $true
}

#for debug only!
get-job | remove-job -force

#to help parse the json
function Get-ObjectMember {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key" }
    }
}

#For the job to call
$scriptblock = {
    param($binpath, $inargs)
    $proc = Start-Process -FilePath $binpath -ArgumentList $inargs -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "The camera didn't respond properly!"
    }

}
loadconfig
#this is just to debug the output
foreach ($source in $global:thelist) {
    Write-Host ("source name: " + $source.Key)
    Write-Host ("source url: " + $source.Value.url)
    Write-Host ("source timeout: " + $source.Value.timeout)
    Write-Host ("source commands offline: " + $source.Value.commands_offline)
    Write-Host ("source commands online: " + $source.Value.commands_online)
}
$eternity = $true
$hashcams = @{} #keeps the last state of the attempt to connect, so we dont reissue commands for nothing
do {

    loadconfig
        
    #redefine the timeouts for the probes, if they are the same than the interval
    foreach ($source in $global:thelist) {
        if ($source.Value.timeout -ge $global:config.config.interval) {
            $source.Value.timeout = ($global:config.config.interval - 2)
        }
        if ($null -eq $hashcams[$source.Key]) {
            $hashcams.Add($source.Key, -1)
        }
        
        #ack!
        if ($Env:OS -ilike "windows*"){
            $timeoutarg = "-timeout"}
        else {
            $timeoutarg = "-stimeout"<# Action when all if and elseif conditions are false #>
        }
        #defin the ffprobe args
        $cargs = @(
            "-hide_banner", 
            "-loglevel error",
           ("-i " + $source.Value.url),
           ("-analyzeduration " + $source.Value.timeout + "M "),
           ("-probesize 1000k")
           ($timeoutarg + " " + $source.Value.timeout * 1000000)
        )
         
        write-host ($global:config.config.ffprobepath + " " + $cargs)
        #okay we're going to do a bit of crazy math to spread the load

        $millisecondwait = (($global:config.config.interval * 1000) / 2) / $global:thelist.key.count

        Start-Sleep -Milliseconds $millisecondwait

        $j = start-job -ScriptBlock $scriptblock -ArgumentList @($global:config.config.ffprobepath, $cargs) -Name $source.Key #we put it in j so it doesn't output to screen

    }
    [int]$a = 0
    #wait for the remainder of the scan/loop interval, or that we got a reply from all probes, whichever comes first 
    do {
        Start-Sleep -Seconds 1
        $a = $a + 1
    } until ((get-job | ? {($_.state -ieq "completed") -or ($_.state -ieq "failed")  }).count -eq ($global:thelist.key.count) -or ($a -ge [int]$global:config.config.interval ))
    Write-Host  ("Time waited: " + ($a) + " seconds."  )

    #lets check the state of our probes
    foreach ($source in $global:thelist) {
        $job = get-job -name $source.Key
                
        #these jobs succeeded we should execute the commands
        if ($job.State -ieq "Completed") {
            if ($hashcams[$source.Key] -eq 0) {
                $newcmd = Invoke-Expression $source.Value.commands_online.replace("@@name@@", $source.Key) #only executes if the state changed
                $hashcams[$source.Key] = 1 #set to "last time, we had success"
            } 
        }
        else {
            if ($hashcams[$source.Key] -eq 1) {
                $newcmd = Invoke-Expression $source.Value.commands_offline.replace("@@name@@", $source.Key) #only executes if the state changed
                $hashcams[$source.Key] = 0 # set to last time we failed
            }<# Action when all if and elseif conditions are false #>
        }
        Write-Host $newcmd #debug writing the commands launched so the user knows what was sent
        $job | Remove-Job -Force #cleanup, whatever wappens and relaunch
    }
    $leftsleep = ([int]$global:config.config.interval - $a) #calculate what's left of the interval delay, not to hammer the system
    write-host ("Time left to sleep: " + $leftsleep + " seconds.")
    Start-Sleep -Seconds $leftsleep

} while ($eternity) #loop forever
