function Get-HDDInfo {
    <#
    .SYNOPSIS
        Returns information about physical drives.
    
    .DESCRIPTION
        Get-HDDInfo returns information about physical drive health status.
    
    .EXAMPLE
        Get-HDDInfo

    .OUTPUTS
        PSCustomObject
    
    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com

    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    foreach ($pdisk in (Get-PhysicalDisk)) {

        $hinfo = Get-StorageReliabilityCounter -PhysicalDisk $pdisk

        New-Object -TypeName PSObject -Property ([ordered]@{
        'FriendlyName' = $pdisk.FriendlyName
        'HealthStatus' = $pdisk.HealthStatus
        'MediaType' = $pdisk.MediaType
        'BusType' = $pdisk.BusType
        'SizeGB' = ([math]::Round($pdisk.Size/1GB,2))
        'SerialNumber' = $pdisk.SerialNumber
        'PowerOnHours' = $hinfo.PowerOnHours
        'PowerOnYears' = if ($hinfo.PowerOnHours) {
            [math]::Round(((New-TimeSpan -Hours ($hinfo.PowerOnHours)).Days / 365),2)
        } else {
            $null
        }
        'Wear' = $hinfo.Wear
        'WriteErrorsCorrected' = $hinfo.WriteErrorsCorrected
        'WriteErrorsTotal' = $hinfo.WriteErrorsTotal
        'WriteErrorsUncorrected' = $hinfo.WriteErrorsUncorrected
        'ReadErrorsCorrected' = $hinfo.ReadErrorsCorrected
        'ReadErrorsTotal' = $hinfo.ReadErrorsTotal
        'ReadErrorsUncorrected' = $hinfo.ReadErrorsUncorrected
        'Temperature' = $hinfo.Temperature
        'TemperatureMax' = $hinfo.TemperatureMax
        })
    } 
}