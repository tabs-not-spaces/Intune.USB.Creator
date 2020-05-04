function Get-DiskToUse {
    $diskList = Get-Disk | Where-Object { $_.Bustype -notin @('SATA', 'NVMe') }
    while ($diskNum -lt 0 -or $diskNum -notin $diskList.Number) {
        $disks = $diskList | Select-Object Number, @{name = 'TotalSize(GB)'; Expression = { ($_.Size / 1GB).ToString("#.##") } }, @{Name = "Name"; Expression = { $_.FriendlyName } } | Sort-Object -Property number
        $table = $disks | Format-Table | Out-String
        $diskNum = Read-Host -prompt "$table`Please select Desired disk number for USB creation"
    }
    return $diskNum
}