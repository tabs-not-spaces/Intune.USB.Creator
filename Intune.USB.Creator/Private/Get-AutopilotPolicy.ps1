#requires -Modules @{ ModuleName="WindowsAutoPilotIntune"; ModuleVersion="4.3" }
#requires -Modules @{ ModuleName="Microsoft.Graph.Intune"; ModuleVersion="6.1907.1.0"}
function Get-AutopilotPolicy {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        [System.IO.FileInfo]$fileDestination
    )
    try {
        @(
            "WindowsAutoPilotIntune",
            "Microsoft.Graph.Intune"
        ) | ForEach-Object {
            Import-Module $_ -UseWindowsPowerShell -ErrorAction SilentlyContinue 3>$null
        }
        #region Connect to Intune
        Connect-MSGraph | Out-Null
        #endregion Connect to Intune
        #region Get policies
        $apPolicies = Get-AutopilotProfile
        if (!($apPolicies)) {
            Write-Warning "No Autopilot policies found.."
        }
        else {
            if ($apPolicies.count -gt 1) {
                Write-Host "Multiple Autopilot policies found - select the correct one.." -ForegroundColor Cyan
                $apPol = $apPolicies | select-object displayName | Out-ConsoleGridView -passthru
            }
            else {
                Write-Host "Policy found - saving to $fileDestination.." -ForegroundColor Cyan
                $apPol = $apPolicies
            }
            $apPol | ConvertTo-AutoPilotConfigurationJSON | Out-File "$fileDestination\AutopilotConfigurationFile.json" -Encoding ascii -Force
            Write-Host "`nSelected: $($apPol.displayName)" -ForegroundColor Green
        }
        #endregion Get policies
    }
    catch {
        Write-Warning $_
    }
}