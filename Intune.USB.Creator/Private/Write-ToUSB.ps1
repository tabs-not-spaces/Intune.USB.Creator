function Write-ToUSB {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        $path,

        [parameter(Mandatory = $true)]
        $destination
    )
    try {
        $progressDiag = "&H0&"
        $yesToAll = "&H16&"
        $simpleProgress = "&H100&"
        $opts = $progressDiag + $yesToAll + $simpleProgress
        $objShell = New-Object -ComObject "Shell.Application"
        $objFolder = $objShell.NameSpace($destination)
        $objFolder.CopyHere($path, $opts)
    }
    catch {
        $errorMsg = $_
    }
    finally {
        if ($errorMsg) {
            Write-Host "`n"
            Write-Warning $errorMsg
        }
        else {
            Write-Host $([char]0x221a) -ForegroundColor Green
        }
    }
}