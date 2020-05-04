# Intune.USB.Creator

## Summary

A module containing tools to assist with the creation of a bootable WinPE USB used to provision devices for enrollment to Intune.


## Pre-Reqs

- [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7)
- [WindowsAutoPilotIntune](https://www.powershellgallery.com/packages/WindowsAutoPilotIntune)
- [Microsoft.Graph.Intune](https://www.powershellgallery.com/packages/Microsoft.Graph.Intune/)
- A copy of Windows 10 (Multi-format ISO recommended)

## How to use

Pretty simple one here.. Only one exposed function

``` PowerShell
$params = @{
    winPEPath = "https://githublfs.blob.core.windows.net/storage/WinPE.zip"
    windowsIsoPath = "C:\path\to\win10.iso"
    getAutopilotCfg = $true
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

If time permits, I'm looking to add the following additions to the solution

- Warnings and the ability to wipe the USB after use - as this solution is VERY volatile, it may be a good idea to trash the USB after being used.
- Allowing custom installation media - currently the solution expects that you will use a Windows 10 ISO to extract the install.wim file. I'd like to allow custom *.wim files to be added during the initial process.

## Release Notes

* v1.0.1.178 - UI improvements - typo fixes
* v1.0.1.177 - Initial release of module.