function Expand-Download {
    param(
        [Parameter(Mandatory = $true)]
        [string]$zipArchive,

        [Parameter(Mandatory = $true)]
        [string]$extractPath
    )
    Write-Host "Unziping $zipArchive at: $extractPath" -ForegroundColor Cyan
    Try {
        Expand-Archive -LiteralPath $zipArchive -DestinationPath $extractPath -Force
    }
    Catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "(Disk likely out of space, Clear 10GB on Disk and try again.)" -ForegroundColor Red
        exit
    }
}