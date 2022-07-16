[int]$newpid = Get-Content /app/script/pid.file
$data = get-process -id $newpid
if (-not $data) {
    exit -1
}
else {
    write-host "ok"
    exit 0
}