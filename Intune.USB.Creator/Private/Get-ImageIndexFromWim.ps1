function Get-ImageIndexFromWim {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        $wimPath,

        [parameter(Mandatory = $true)]
        $destination
    )
    try {
        Write-Verbose "Getting windows images from $wimPath"
        $images = Get-WindowsImage -ImagePath $wimPath
        Write-Host "Select an Image from the below available options:" -ForegroundColor Cyan
        $images | Select-Object ImageIndex, ImageName | Format-Table
        $rh = Read-Host "Select Image Index..($($images[0].ImageIndex)..$($images[-1].ImageIndex))"
        while ($rh -notin $images.ImageIndex) {
            $rh = Read-Host "Select Image Index..($($images[0].ImageIndex)..$($images[-1].ImageIndex))"
        }
        Write-Host "Image $rh / $(($images | Where-Object {$_.ImageIndex -eq $rh}).ImageName) selected.." -ForegroundColor Gray
        $images | Where-Object { $_.ImageIndex -eq $rh } | ConvertTo-Json -Depth 20 | Out-File "$destination\imageIndex.json" -Encoding ascii -Force
        Write-Verbose "ImageIndex.Json saved to $destination.."
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}