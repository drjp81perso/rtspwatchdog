$data = (Invoke-WebRequest -uri "https://raw.githubusercontent.com/drjp81perso/rtspwatchdog/main/process.ps1" ).contents
if ($data)
{
    try {
        $file = (Join-Path $PSScriptRoot -ChildPath "work.ps1")   
        Set-Content -Path $file -Value $data  
    }
    catch {
        Write-Error "could not create script"
        exit -1
    }

    chmod $file +x
    Invoke-Expression -Command $file
}
