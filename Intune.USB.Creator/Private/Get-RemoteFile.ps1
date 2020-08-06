function Get-RemoteFile {
    [cmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [uri]$fileUri,
        [Parameter(Mandatory = $true)]
        [String]$destination,

        [switch]$expand
    )
    $tick = [char]0x221a
    Write-Host "Checking if file already downloaded.." -ForegroundColor Cyan -NoNewline
    [string]$fn = $fileUri.Segments[-1]
    $filePath = Join-Path -Path $destination -ChildPath $fn
    if (!(Test-Path -Path "$filePath" -ErrorAction SilentlyContinue)) {
        Test-DiskSpace -DriveLetter $destination.Split(":")[0]
        Write-Host " X" -ForegroundColor Red
        Write-Host "File not found, Downloading..." -ForegroundColor Cyan
        Write-Host "Downloading the file $fn to $destination.." -ForegroundColor Cyan
        Invoke-FileTransfer -source $fileUri -destination $filePath
    }
    else {
        Write-Host " $tick" -ForegroundColor Green
        $fso = New-Object -comobject Scripting.FileSystemObject
        $fileSize = ($fso.GetFile($filePath)).size / 1GB
        Write-Host ".zip Size: $fileSize" -ForegroundColor Green
        if ($fileSize -le "0") {
            Remove-Item $filePath
            Write-Host "File Error, Re-Downloading..."
            Write-Host "Downloading the Image $fn in  $filePath" -ForegroundColor Cyan
            Invoke-FileTransfer -source $fileUri -destination $filePath
        }
    }
    if ($expand) {
        $expandPath = Join-Path $destination -ChildPath $($fn -Split ".zip")[0]
        Write-Host "Checking if file already unzipped.." -ForegroundColor Cyan -NoNewline
        if (!(Test-Path -Path $expandPath)) {
            Write-Host " X" -ForegroundColor Red
            Test-DiskSpace -DriveLetter $destination.Split(":")[0]
            try {
                Write-Host "Creating directory: $expandPath" -ForegroundColor Cyan
                New-Item -Path $expandPath -ItemType Directory -Force | Out-Null
                Expand-Download -zipArchive $filePath -extractPath $expandPath
            }
            catch {
                Write-Warning $_.Exception
            }
        }
        else {
            Write-Host " $tick" -ForegroundColor Green
            $fso = New-Object -ComObject Scripting.FileSystemObject
            $size = ($fso.GetFolder($expandPath)).size / 1GB
            Write-Host "Folder Size: $size" -ForegroundColor Green
            if ($size -le ($fso.GetFile($filePath)).size / 1GB) {
                Write-Host "Filesize Mismatch - Trying again.." -ForegroundColor Red
                Write-Host "Deleting $expandPath" -ForegroundColor Cyan
                Remove-Item $expandPath -Recurse -Force
                try {
                    #md $expandPath
                    Write-Host "Creating Directory: $expandPath" -ForegroundColor Cyan
                    New-Item -Path $expandPath -ItemType Directory -Force | Out-Null
                    Write-Host "Unziping Image.." -ForegroundColor Cyan
                    Expand-Download -zipArchive $filePath -extractPath $expandPath
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }
        }
    }
    else {
        return $filePath
    }
}