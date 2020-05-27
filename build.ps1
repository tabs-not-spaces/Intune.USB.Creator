[cmdletbinding()]
param (
    [parameter(Mandatory = $true)]
    [System.IO.FileInfo]$modulePath,

    [parameter(Mandatory = $true)]
    [string]$moduleName,

    [parameter(Mandatory = $false)]
    [switch]$buildLocal
)
if ($buildLocal) {
    if (Test-Path $PSScriptRoot\localenv.ps1 -ErrorAction SilentlyContinue) {
        . $PSScriptRoot\localenv.ps1
        if (Test-Path "$PSScriptRoot\bin\release\*") {
            $env:BUILD_BUILDID = ((Get-ChildItem $PSScriptRoot\bin\release\).Name | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) + 1
        }
    }
}
try {
    #region Generate a new version number
    $newVersion = New-Object version -ArgumentList 1, 0, 1, $env:BUILD_BUILDID
    $releaseNotes = (Get-Content .\Intune.USB.Creator\ReleaseNotes.txt -Raw).Replace("{{NewVersion}}",$newVersion)
    #endregion
    #region Build out the release
    $relPath = "$PSScriptRoot\bin\release\$env:BUILD_BUILDID\$moduleName"
    "Version is $newVersion"
    "Module Path is $modulePath"
    "Module Name is $moduleName"
    "Release Path is $relPath"
    if (!(Test-Path $relPath)) {
        New-Item -Path $relPath -ItemType Directory -Force | Out-Null
    }
    Copy-Item "$modulePath\*" -Destination "$relPath" -Recurse -Exclude ".gitKeep"
    #endregion
    #region Generate a list of public functions and update the module manifest
    $functions = @(Get-ChildItem -Path $relPath\Public\*.ps1 -ErrorAction SilentlyContinue).basename
    $params = @{
        Path = "$relPath\$ModuleName.psd1"
        ModuleVersion = $newVersion
        Description = (Get-Content $relPath\description.txt -raw).ToString()
        FunctionsToExport = $functions
        ReleaseNotes = $releaseNotes.ToString()
    }
    Update-ModuleManifest @params
    $moduleManifest = Get-Content $relPath\$ModuleName.psd1 -raw | Invoke-Expression
    #endregion
    #region Generate the nuspec manifest
    $t = [xml](Get-Content $PSScriptRoot\module.nuspec -Raw)
    $t.package.metadata.id = $moduleName
    $t.package.metadata.version = $newVersion.ToString()
    $t.package.metadata.authors = $moduleManifest.author.ToString()
    $t.package.metadata.owners = $moduleManifest.author.ToString()
    $t.package.metadata.requireLicenseAcceptance = "false"
    $t.package.metadata.description = (Get-Content $relPath\description.txt -raw).ToString()
    $t.package.metadata.description
    $t.package.metadata.releaseNotes = $releaseNotes.ToString()
    $t.package.metadata.releaseNotes
    $t.package.metadata.copyright = $moduleManifest.copyright.ToString()
    $t.package.metadata.tags = ($moduleManifest.PrivateData.PSData.Tags -join ',').ToString()
    $t.Save("$PSScriptRoot\$moduleName`.nuspec")
    #endregion
}
catch {
    $_
}