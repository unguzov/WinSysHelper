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

    $Monitors = $null

    if ($UseWmiObject) {
        $Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
    } else {
        $Monitors = Get-CimInstance -ClassName WmiMonitorID -Namespace root/WMI
    }

    ForEach ($Monitor in $Monitors) {  
        New-Object -TypeName PSObject -Property ([ordered]@{
          'Name' = (-join $Monitor.UserFriendlyName.ForEach({[char]$_})).Trim(0x00)
          'Manufacturer' = (-join $Monitor.ManufacturerName.ForEach({[char]$_})).Trim(0x00)
          'Serial' = (-join $Monitor.SerialNumberID.ForEach({[char]$_})).Trim(0x00)
          'ProductCodeID' =  (-join $Monitor.ProductCodeID.ForEach({[char]$_})).Trim(0x00)
          'WeekOfManufacture' = $Monitor.WeekofManufacture
          'YearOfManufacture' = $Monitor.YearOfManufacture
          'Active' = $Monitor.Active
          })
      }
}