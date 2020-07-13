function Publish-ImageToUSB {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        [string]$winPEPath,

        [parameter(Mandatory = $true)]
        [string]$windowsIsoPath,

        [parameter(Mandatory = $false)]
        [switch]$getAutoPilotCfg
    )
    #region Main Process
    try {
        #region start diagnostic // show welcome
        $errorMsg = $null
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $welcomeScreen = "ICAgIF9fICBfXyAgICBfXyAgX19fX19fICBfX19fX18gIF9fX19fXwogICAvXCBcL1wgIi0uLyAgXC9cICBfXyBcL1wgIF9fX1wvXCAgX19fXAogICBcIFwgXCBcIFwtLi9cIFwgXCAgX18gXCBcIFxfXyBcIFwgIF9fXAogICAgXCBcX1wgXF9cIFwgXF9cIFxfXCBcX1wgXF9fX19fXCBcX19fX19cCiAgICAgXC9fL1wvXy8gIFwvXy9cL18vXC9fL1wvX19fX18vXC9fX19fXy8KIF9fX19fXyAgX18gIF9fICBfXyAgX18gICAgICBfX19fXyAgIF9fX19fXyAgX19fX19fCi9cICA9PSBcL1wgXC9cIFwvXCBcL1wgXCAgICAvXCAgX18tLi9cICBfX19cL1wgID09IFwKXCBcICBfXzxcIFwgXF9cIFwgXCBcIFwgXF9fX1wgXCBcL1wgXCBcICBfX1xcIFwgIF9fPAogXCBcX19fX19cIFxfX19fX1wgXF9cIFxfX19fX1wgXF9fX18tXCBcX19fX19cIFxfXCBcX1wKICBcL19fX19fL1wvX19fX18vXC9fL1wvX19fX18vXC9fX19fLyBcL19fX19fL1wvXy8gL18vCiAgICAgICAgIF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCiAgICAgICAgIFdpbmRvd3MgMTAgRGV2aWNlIFByb3Zpc2lvbmluZyBUb29sCiAgICAgICAgICoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq"
        Write-Host $([system.text.encoding]::UTF8.GetString([system.convert]::FromBase64String($welcomeScreen)))
        if (!(Test-Admin)) {
            throw "Exiting -- need admin right to execute"
        }
        #endregion
        #region set usb class
        Write-Host "`nSetting up configuration paths.." -ForegroundColor Yellow
        $usb = [ImageUSBClass]::new()
        #endregion
        #region get winPE / unpack to temp
        Write-Host "`nGetting WinPE media.." -ForegroundColor Yellow
        Get-RemoteFile -fileUri $winPEPath -destination $usb.downloadPath -expand
        #endregion
        #region get wim from ISO
        if ($windowsIsoPath) {
            Write-Host "`nGetting install.wim from windows media.." -ForegroundColor Yellow -NoNewline
            if (Test-Path -Path $windowsIsoPath -ErrorAction SilentlyContinue) {
                $dlFile = $windowsIsoPath
            }
            else {
                $dlFile = Get-RemoteFile -fileUri $windowsIsoPath -destination $usb.downloadPath
            }
            Get-WimFromIso -isoPath $dlFile -wimDestination $usb.WIMPath
        }
        #endregion
        #region get image index from wim
        Write-Host "`nGetting image index from install.wim.." -ForegroundColor Yellow
        Get-ImageIndexFromWim -wimPath $usb.WIMFilePath -destination "$($usb.downloadPath)\$($usb.dirName2)"
        #endregion
        #region get Autopilot config from azure
        if ($getAutopilotCfg) {
            Write-Host "`nGrabbing Autopilot config file from Azure.." -ForegroundColor Yellow
            Get-AutopilotPolicy -fileDestination $usb.downloadPath
        }
        #endregion
        #region choose and partition USB
        Write-Host "`nConfiguring USB.." -ForegroundColor Yellow
        $chooseDisk = Get-DiskToUse
        $usb = Set-USBPartition -usbClass $usb -diskNum $chooseDisk
        #endregion
        #region write WinPE to USB
        Write-Host "`nWriting WinPE to USB.." -ForegroundColor Yellow -NoNewline
        Write-ToUSB -Path "$($usb.winPEPath)\*" -Destination "$($usb.drive):\"
        #endregion
        #region write Install.wim to USB
        if ($windowsIsoPath) {
            Write-Host "`nWriting Install.wim to USB.." -ForegroundColor Yellow -NoNewline
            Write-ToUSB -Path $usb.WIMPath -Destination "$($usb.drive2):\"
        }
        #endregion
        #region write Autopilot to USB
        if ($getAutopilotCfg) {
            Write-Host "`nWriting Autopilot to USB.." -ForegroundColor Yellow -NoNewline
            Write-ToUSB -Path "$($usb.downloadPath)\AutopilotConfigurationFile.json" -Destination "$($usb.drive):\scripts\"
        }
        #endregion
        #region download provision script and install to usb
        Write-Host "`nGrabbing provision script from GitHub.." -ForegroundColor Yellow
        Invoke-RestMethod -Method Get -Uri $script:provisionUrl -OutFile "$($usb.drive):\scripts\Invoke-Provision.ps1"
        #endregion
        #region download and apply powershell 7 to usb
        Write-Host "`nGrabbing PWSH 7.." -ForegroundColor Yellow
        Invoke-RestMethod -Method Get -Uri 'https://aka.ms/install-powershell.ps1' -OutFile "$env:Temp\install-powershell.ps1"
        . $env:Temp\install-powershell.ps1 -daily -Destination "$($usb.drive):\scripts\pwsh"
        #endregion download and apply powershell 7 to usb
        $completed = $true
    }
    catch {
        $errorMsg = $_.Exception.Message
    }
    finally {
        $sw.Stop()
        if ($errorMsg) {
            Write-Warning $errorMsg
        }
        else {
            if ($completed) {
                Write-Host "`nUSB Image built successfully..`nTime taken: $($sw.Elapsed)" -ForegroundColor Green
            }
            else {
                Write-Host "`nScript stopped before completion..`nTime taken: $($sw.Elapsed)" -ForegroundColor Green
            }
        }
    }
    #endregion
}