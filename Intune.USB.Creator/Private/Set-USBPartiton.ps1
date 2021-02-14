function Set-USBPartition {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true)]
        [ImageUSBClass]$usbClass,

        [Parameter(Mandatory = $true)]
        [int]$diskNum
    )
    try {
        Stop-Service -Name ShellHWDetection
        Write-Host "`nClearing Disk: $diskNum" -ForegroundColor Cyan
        if ((Get-Disk $diskNum).PartitionStyle -eq "RAW") {
            Get-Disk $diskNum | Initialize-Disk -ErrorAction SilentlyContinue -Confirm:$false
        }
        else {
            Get-Disk $diskNum | Clear-Disk -RemoveData -Confirm:$false
            Get-Disk $diskNum | Initialize-Disk -ErrorAction SilentlyContinue -Confirm:$false
        }
        Start-Sleep -Seconds 3
        Write-Host "Creating New Partions" -ForegroundColor Cyan
        $usbClass.drive = (New-Partition -DiskNumber $diskNum -Size 3GB -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel WINPE -Confirm:$false -Force).DriveLetter
        $usbClass.drive2 = (New-Partition -DiskNumber $diskNum -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel Images -Confirm:$false -Force).DriveLetter
        $usbClass
    }
    catch {
        Write-Warning $_.Exception.Message
        exit(1)
    }
    finally {
        Start-Service -Name ShellHWDetection
    }
}