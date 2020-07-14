function Get-DiskToUse {
    $diskList = Get-Disk | Where-Object { $_.Bustype -notin @('SATA', 'NVMe') }
    while ($diskNum -lt 0 -or $diskNum -notin $diskList.Number) {
        $disks = $diskList | Select-Object Number, @{Name = 'TotalSize(GB)'; Expression = { ($_.Size / 1GB).ToString("#.##") } }, @{Name = "Name"; Expression = { $_.FriendlyName } } | Sort-Object -Property Number
        $table = $disks | Format-Table | Out-Host
        $diskNum = Read-Host -Prompt "$table`Please select Desired disk number for USB creation or CTRL+C to cancel"
        if ($Disks[$diskNum].'TotalSize(GB)' -lt 8) {
            Write-Host "I am afraid not, that disk is less than 8Gb and we just wont have the space. Please use a larger disk"
            $diskNum = Read-Host -Prompt "$table`Please select Desired disk number for USB creation or CTRL C to cancel"
        }
    }
    return $diskNum
}