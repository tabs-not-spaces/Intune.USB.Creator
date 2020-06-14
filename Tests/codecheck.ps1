$fp = Split-Path $PSScriptRoot -Parent
if (!(Test-Path $fp\.tests\)) {
    new-item $fp\.tests -ItemType Directory -Force
}
Import-Module Pester -RequiredVersion 4.10.1 -Force
Invoke-Pester -Script "$PSScriptRoot\codecheck.test.ps1" -OutputFile "$fp\.tests\pester.codecheck.test.xml" -OutputFormat 'NUnitXml'