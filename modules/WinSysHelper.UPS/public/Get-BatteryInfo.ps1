function Get-BatteryInfo {
    <#
    .SYNOPSIS
        Returns information about UPS or batteries.
    
    .DESCRIPTION
        Get-BatteryInfo returns information about UPS or batteries and battery status.
    
    .EXAMPLE
        Get-BatteryInfo
    
    .EXAMPLE
        Get-BatteryInfo -ComputerName "MyPC"
    
    .OUTPUTS
        PSCustomObject
    
    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com

    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
        [PSDefaultValue(Help = {$env:computername})]
        $ComputerName = $env:computername
    )

    $batStatus = @{
        1   = "Battery Power"
        2   =  "AC Power"
        3   = "Fully Charged"
        4   =  "Low"
        5   = "Critical"
        6   = "Charging"
        7   = "Charging and High"
        8   = "Charging and Low"
        9   = "Charging and Critical"
        10  = "Undefined"
        11  = "Partially Charged"
    }

    $batAvailability =@{
        1   = "Other" 
        2   =  "Unknown" 
        3   = "Running on Full Power"
        4   =  "Warning" 
        5   = "In Test"
        6   = "Not Applicable"
        7   = "Power Off"
        8   = "Off Line"
        9   = "Off Duty"
        10  =  "Degraded"
        11  =  "Not Installed"
        12  =  "Install Error"
        13  = "Power Save - Unknown"
        14  = "Power Save - Low Power Mode" 
        15  = "Power Save - Standby"
        16  = "Power Cycle"
        17  = "Power Save - Warning"
        18  = "Paused"
        19  = "Not Ready"
        20  = "Not Configured"
        21  = "Quiesced"
        999 = "Not using battery"
    }

    $batteries = Get-WmiObject -Class Win32_Battery -ComputerName $ComputerName

    if ($batteries) {

        $batteryInfo = foreach ($batt in $batteries) {
    
            New-Object -TypeName PSObject -Property ([ordered]@{
                'BatteryName' = $batt.Name
                'DeviceID' = ([string]$batt.DeviceID).Trim()
                'BatteryStatus' = if ($batStatus[[int]$batt.BatteryStatus]) {
                    $batStatus[[int]$batt.BatteryStatus]
                } else {
                    $batt.BatteryStatus
                }
                'Charge' = if ($batt.EstimatedChargeRemaining -lt '100') {
                    "{0:P0}" -f ($batt.EstimatedChargeRemaining/100) 
                } else {
                    "{0:P0}" -f 1
                }
                'MinutesRemaining' = if ($batt.EstimatedRUntime -lt '9999') {
                    $batt.EstimatedRunTime 
                } else {
                    'N/A'
                }
                'BatteryAvailability' = if ($batAvailability[[int]$batt.Availability]) {
                    $batAvailability[[int]$batt.Availability]
                } else {
                    $batt.Availability
                }
                'ComputerName' = $ComputerName
            })
        }

        return $batteryInfo

    } else {
        Write-Host "*** $ComputerName : Battery not found. ***" -ForegroundColor Yellow
        return
    }
}