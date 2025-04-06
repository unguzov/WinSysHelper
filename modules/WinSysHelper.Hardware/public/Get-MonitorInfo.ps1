function Get-MonitorInfo {
    <#
    .SYNOPSIS
        Returns informationabout monitors.
    
    .DESCRIPTION
        Get-MonitorInfo returns information about connected monitors.
    
    .EXAMPLE
        Get-MonitorInfo

    .EXAMPLE
        Get-MonitorInfo -UseWmiObject $false

    .OUTPUTS
        PSCustomObject
    
    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com

    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
        [PSDefaultValue(Help = $true)]
        $UseWmiObject = $true
    )

    $videoOutputTechLookup = @{
        -2 = "Uninitialized"
        -1 = "Other"
        0 = "HD15 (VGA)"
        1 = "SVIDEO"
        2 = "Composite video"
        3 = "Component video"
        4 = "DVI"
        5 = "HDMI"
        6 = "LVDS"
        8 = "D_JPN"
        9 = "SDI"
        10 = "DisplayPort External"
        11 = "DisplayPort Embedded"
        12 = "UDI_EXTERNAL"
        13 = "UDI_EMBEDDED"
        14 = "SDTVDONGLE"
        15 = "MIRACAST"
        16 = "INDIRECT_WIRED"
        2147483648 = "Internal"
    }


    $Monitors = $null
    $monitorConnections = $null

    if ($UseWmiObject) {
        $Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
        $monitorConnections = Get-WmiObject WmiMonitorConnectionParams -Namespace root\wmi
    } else {
        $Monitors = Get-CimInstance -ClassName WmiMonitorID -Namespace root/WMI
        $monitorConnections = Get-CimInstance -Namespace root/wmi -classname WmiMonitorConnectionParams
    }

    ForEach ($Monitor in $Monitors) {
        
        $VideoOutputTechnology = "Unknown"

        $matchingConnection = $monitorConnections | Where-Object {
            $_.InstanceName -eq $Monitor.InstanceName}

        if ($matchingConnection) {
            $videoTechCode = $matchingConnection.VideoOutputTechnology
            $VideoOutputTechnology = $videoOutputTechLookup[[int]$videoTechCode]
            if (-not $VideoOutputTechnology) { $VideoOutputTechnology = "Unknown ($videoTechCode)" }
        }

        New-Object -TypeName PSObject -Property ([ordered]@{
          'Name' = (-join $Monitor.UserFriendlyName.ForEach({[char]$_})).Trim(0x00)
          'Manufacturer' = (-join $Monitor.ManufacturerName.ForEach({[char]$_})).Trim(0x00)
          'Serial' = (-join $Monitor.SerialNumberID.ForEach({[char]$_})).Trim(0x00)
          'ProductCodeID' =  (-join $Monitor.ProductCodeID.ForEach({[char]$_})).Trim(0x00)
          'WeekOfManufacture' = $Monitor.WeekofManufacture
          'YearOfManufacture' = $Monitor.YearOfManufacture
          'VideoOutputTechnology' = $VideoOutputTechnology
          'Active' = $Monitor.Active
          })
      }
}