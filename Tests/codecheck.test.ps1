[cmdletbinding()]
param (
    [System.IO.FileInfo]$filePath
)
$excludeRule = @(
    "PSAvoidUsingWriteHost",
    "PSAvoidUsingConvertToSecureStringWithPlainText",
    "PSAvoidUsingPositionalParameters"
)
$fp = Split-Path $PSScriptRoot -Parent
if (Test-Path $fp\localenv.ps1 -ErrorAction SilentlyContinue) {
    . $fp\localenv.ps1
}
$fp = "$fp\bin\release\$env:MODULENAME"
$fp
Describe "Checking content exists" {
    if ($filePath) {
        $scripts = Get-ChildItem $filePath
    }
    else {
        $scripts = Get-ChildItem -Path "$fp" -Recurse -Include *.ps1
        $scope = @("Private", "Public")
        foreach ($s in $scope) {
            Context "Checking for files in $s.." {
                It "$s scripts folder not empty" { ($scripts | Where-Object { $_.Directory.Name -eq $s }).count | Should -BeGreaterOrEqual 1 }
            }
        }
    }
}
if (!($filePath)) {
    Describe "Manifest" {
        Context "Checking module manifest" {
            $manifest = Test-ModuleManifest -Path "$fp\$env:MODULENAME`.psd1"
            It "Has a valid module manifest" { $manifest | Should -Not -BeNullOrEmpty }
        }
    }
}
Describe "Checking Code Quality" {
    $scripts = Get-ChildItem -Path "$fp" -Recurse -Include *.ps1
    $scripts.ForEach{
        Context "PSSA Quality Check: $($_.name)" {
            $pssaIssues = Invoke-ScriptAnalyzer -Path "$_" -ExcludeRule $excludeRule
            $pssaRuleNames = Get-ScriptAnalyzerRule | Select-Object -ExpandProperty RuleName
            foreach ($rule in $pssaRuleNames) {
                It "Should pass $rule" {
                    $failure = $pssaIssues | Where-Object -Property RuleName -EQ -Value $rule
                    $message = ($failure | Select-Object Message -Unique).Message
                    $lines = $failure.Line -join ','
                    $scriptName = $failure.ScriptName
                    ($failure | Measure-Object).Count | Should -Be 0 -Because "our code should be perfect. However in script $scriptName on line $lines we got an error from PSScriptAnalyzer saying `'$message`'"
                }
            }
        }
    }
}
