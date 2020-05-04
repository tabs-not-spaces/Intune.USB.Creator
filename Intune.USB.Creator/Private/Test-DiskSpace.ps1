function Test-DiskSpace {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$driveLetter
    )
    $drive = Get-PSDrive $driveLetter
    $freeSpace = ($drive.free / 1GB)
    if ($freeSpace -le 16) {
        Write-Host "Insufficent Disk Space for opperation. Please free up additional storage (16GB) and try again." -ForegroundColor Red
        exit
    }
}