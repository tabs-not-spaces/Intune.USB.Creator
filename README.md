# Intune.USB.Creator

[![Build Status](https://dev.azure.com/powers-hell/Intune.USB.Creator/_apis/build/status/tabs-not-spaces.Intune.USB.Creator?branchName=master)](https://dev.azure.com/powers-hell/Intune.USB.Creator/_build/latest?definitionId=31&branchName=master)
![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Intune.USB.Creator.svg?style=flat&logo=powershell&label=PSGallery%20Version)
![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/Intune.USB.Creator.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)
## Summary

A module containing tools to assist with the creation of a bootable WinPE USB used to provision devices for enrollment to Intune.


## Pre-Reqs

- [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7)
- [WindowsAutoPilotIntune](https://www.powershellgallery.com/packages/WindowsAutoPilotIntune) - Installed automatically if missing
- [Microsoft.Graph.Intune](https://www.powershellgallery.com/packages/Microsoft.Graph.Intune/) - Installed automatically if missing
- A copy of Windows 10 (Multi-format ISO recommended)

## How to use

Pretty simple one here.. Only one exposed function

``` PowerShell
$params = @{
    winPEPath = "https://githublfs.blob.core.windows.net/storage/WinPE.zip"
    windowsIsoPath = "C:\path\to\win10.iso"
    getAutopilotCfg = $true
    imageIndex = 5 # Optional parameter
    diskNum = 1 # Optional parameter
}
Publish-ImageToUSB @params
```
## What happens

Running the Publish-ImageToUSB function will configure a USB with a copy of WinPE, Windows 10 & the required provisioning scripts.

![Publish-ImageToUSB](https://i.imgur.com/u4HOn0y.gif)

Once you've configured a USB with the tool, using it as a boot device will launch WinPE and kick off "Invoke-Provision.ps1" to configure Windows 10 on the device and apply the Autopilot configuration file.

![Invoke-Provision.ps1](https://i.imgur.com/v9Ls50M.gif)

Once the provisioning script has completed, removing the USB and rebooting the device will bring us to the Windows 10 OOBE and eventually the Autopilot enrollment screen from the configuration file we captured in the first step.

![OOBE](https://i.imgur.com/KcMT5OP.gif)

## What's next?

If time permits, I'm looking to add the following additions to the solution:

- Warnings and the ability to wipe the USB after use - as this solution is VERY volatile, it may be a good idea to trash the USB after being used.
- Allowing custom installation media - currently the solution expects that you will use a Windows 10 ISO to extract the install.wim file. I'd like to allow custom *.wim files to be added during the initial process.

## Caveat Emptor

I'm providing this solution as a tool as an educational tool to assist the IT-Pro community with absolutely ZERO warranties or guarantees - I know it works for me, but if it doesn't for you - read the code and fix it..

If you find a problem and want to contribute - please do! I love community involvement and will be as active as my schedule allows.

Lastly, I'm providing a copy of WinPE (which also includes the "Invoke-Provision.ps1" file) on a personal Azure storage account. This will stay up as long as it doesn't begin to cost me too much - if it does, I *will* take it down. If there are better options, please let me know.

## Release Notes

* V1.0.1.311
  - ImageIndex & DiskNum variables added to allow non-interactive use of module. (Thanks axgch)
  
* v1.0.1.309
  - USB size check implemented - no smaller than 8gb. (Thanks Rob)
  - Autopilot provisioning path now tested (Thanks Rob)
  - Removed daily flag from pwsh7 installer ( Thanks jmaystahl)

* v1.0.1.285
  - Adding in warning messages to invoke-provision script.
  - Moved Invoke-Provision out of the WinPE media and now pulling from GitHub.
* v1.0.1.280
  - Updated module dependencies to be auto-installed
  - Removed support for Out-ConsoleGridView for less required dependencies
  - Improved windows PowerShell compatibility for modules not natively supported in PowerShell 7.
* v1.0.1.178
  - UI improvements - typo fixes
* v1.0.1.177
  - Initial release of module.
