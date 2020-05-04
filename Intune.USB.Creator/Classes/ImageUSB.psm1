class ImageUSBClass {
    [string]$DownloadPath = $null
    [string]$Drive = $null
    [string]$DirName = "WinPE"
    [string]$Drive2 = $null
    [string]$DirName2 = "Images"
    [string]$WinPEPath = $null
    [string]$WIMPath = $null
    [string]$WIMFilePath = $null
    [string]$ImageIndexFilePath = $null
    [string]$AutopilotFilePath = $null
    ImageUSBClass () {
        $this.DownloadPath = Join-Path -Path $env:TEMP -ChildPath "Win10"
        if (!(Test-Path $this.DownloadPath -ErrorAction SilentlyContinue)) {
            New-Item $this.DownloadPath -ItemType Directory -Force | Out-Null
        }
        $this.WinPEPath = Join-Path $this.DownloadPath -ChildPath "WinPE"
        $this.WIMPath = Join-Path $this.DownloadPath -ChildPath "Images"
        $this.WIMFilePath = "$($this.DownloadPath)\Images\install.wim"
        if (!(test-path $this.WIMPath -ErrorAction SilentlyContinue)) {
            New-Item -Path $this.WIMPath -ItemType Directory -Force | Out-Null
        }
        $this.ImageIndexFilePath = "$($this.DownloadPath)\Images\imageIndex.json"
        $this.AutopilotFilePath = "$($this.DownloadPath)\AutopilotConfigurationFile.json"
    }
}