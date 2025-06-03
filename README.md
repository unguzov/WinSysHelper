# WinSysHelper

## Table of Contents

[About](#about)  
[WinSysHelper Modules Description](#winsyshelper-modules-description)  
[Social Media](#social-media)  
[Feedback](#feedback)  

## About
WinSysHelper is a PowerShell set of modules that provide functions that facilitate the daily work of the system administrator. I add and update modules into my company's day-to-day work process.

Each function is in a separate file and can be used independently.

## WinSysHelper Modules Description

<table>
    <thead>
        <tr>
            <th>Module</th>
            <th>Description</th>
            <th>URL</th>
        </tr>
    </thead>
    <tbody>
        <tr>
        <tr>
            <td>WinSysHelper.Activation<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Activation/public/Get-ActivationInfo.ps1">Get-ActivationInfo</a>
            </td>
            <td>Windows Activation tools</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Activation">Link</a></td>
        </tr>
            <td>WinSysHelper.Drives<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Drives/public/Get-HDDEventsFromLog.ps1">Get-HDDEventsFromLog</a><br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Drives/public/Get-HDDInfo.ps1">Get-HDDInfo</a><br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Drives/public/Get-TreeFolderSize.ps1">Get-TreeFolderSize</a>
            </td>
            <td>HDD tools</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.Drives">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.ExchangeOnline<br>
            <a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.ExchangeOnline/public/Get-MailboxInfo.ps1">Get-MailboxInfo</a></td>
            <td>Exchange Online tools</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.ExchangeOnline">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.Hardware<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Hardware/public/Get-MonitorInfo.ps1">Get-MonitorInfo</a></td>
            <td>Computer hardware information</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.Hardware">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.Network<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Network/public/Get-WirelessConnectionInfo.ps1">Get-WirelessConnectionInfo</a><br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Network/public/Get-WirelessPasswords.ps1">Get-WirelessPasswords</a><br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Network/public/Test-InternetSpeed.ps1">Test-InternetSpeed</a><br>
            </td>
            <td>Network related tools - Internet speed test, ethernet adapters, wi-fi</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.Network">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.Printers<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Printers/public/Get-PrinterInfo.ps1">Get-PrinterInfo</a><br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Printers/public/Send-TestPage.ps1">Send-TestPage</a>
            </td>
            <td>Managing Windows printers - printer ports and IP addresses, printing a test page.</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.Printers">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.Software<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Software/public/Get-InstalledSoftware.ps1">Get-InstalledSoftware</a></td>
            <td>Installed software information</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.Software">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.UPS<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.UPS/public/Get-BatteryInfo.ps1">Get-BatteryInfo</a></td>
            <td>UPS and laptop battery information</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.UPS">Link</a></td>
        </tr>
        <tr>
            <td>WinSysHelper.Tools<br>
            <a href="https://github.com/unguzov/WinSysHelper/blob/main/modules/WinSysHelper.Tools/public/Get-FileFromWeb.ps1">Get-FileFromWeb</a></td>
            <td>Varios tools</td>
            <td><a href="https://github.com/unguzov/WinSysHelper/tree/main/modules/WinSysHelper.Tools">Link</a></td>
        </tr>
<!--
        <tr>
            <td>XXX<br>
            <a href="XXX">YYY</a></td>
            <td>XXX</td>
            <td><a href="XXX">Link</a></td>
        </tr>
-->        
    </tbody>
</table>

## Social Media
[Facebook](https://www.facebook.com/ProcompExpress)  
[LinkedIn (company)](https://www.linkedin.com/company/procomp-express/)  
[LinkedIn (personal)](https://www.linkedin.com/in/nikolay-unguzov/)  


## Feedback
If you encounter a problem or have a suggestion to improve modules, you may file an [issue report](https://github.com/unguzov/WinSysHelper/issues/).

If you are filing a problem report, you should include:
* The name and version of the module you are using
* The Operating System and version
* The observed output
* The expected output
* Any troubleshooting you took to resolve the issue yourself

