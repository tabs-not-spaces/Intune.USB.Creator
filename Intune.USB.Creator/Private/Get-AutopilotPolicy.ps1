#requires -Modules @{ ModuleName="WindowsAutoPilotIntune"; ModuleVersion="4.3" }
#requires -Modules @{ ModuleName="Microsoft.Graph.Intune"; ModuleVersion="6.1907.1.0"}
function Get-AutopilotPolicy {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]
        [System.IO.FileInfo]$FileDestination
    )
    try {
        if (!(Test-Path "$FileDestination\AutopilotConfigurationFile.json" -ErrorAction SilentlyContinue)) {
            $modules = @(
                "WindowsAutoPilotIntune",
                "Microsoft.Graph.Intune"
            )
            if ($PSVersionTable.PSVersion.Major -eq 7) {
                $modules | ForEach-Object {
                    Import-Module $_ -UseWindowsPowerShell -ErrorAction SilentlyContinue 3>$null
                }
            }
            else {
                $modules | ForEach-Object {
                    Import-Module $_
                }
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
                    $apPol = $apPolicies | Select-Object displayName | Out-GridView -passthru
                }
                else {
                    Write-Host "Policy found - saving to $FileDestination.." -ForegroundColor Cyan
                    $apPol = $apPolicies
                }
                $apPol | ConvertTo-AutopilotConfigurationJSON | Out-File "$FileDestination\AutopilotConfigurationFile.json" -Encoding ascii -Force
                Write-Host "Autopilot profile selected: $($apPol.displayName)" -ForegroundColor Green
            }
            #endregion Get policies
        }
        else {
            Write-Host "Autopilot Configuration file found locally: $FileDestination\AutopilotConfigurationFile.json" -ForegroundColor Green
        }
    }
    catch {
        $errorMsg = $_
    }
    finally {
        if ($PSVersionTable.PSVersion.Major -eq 7) {
            $modules = @(
                "WindowsAutoPilotIntune",
                "Microsoft.Graph.Intune"
            ) | ForEach-Object {
                Remove-Module $_ -ErrorAction SilentlyContinue 3>$null
            }
        }
        if ($errrorMsg) {
            Write-Warning $errorMsg
        }
    }
}