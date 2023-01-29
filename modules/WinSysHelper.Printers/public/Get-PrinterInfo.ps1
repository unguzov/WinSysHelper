function Get-PrinterInfo {
    <#
    .SYNOPSIS
        Returns information about printers and printer ports.

    .DESCRIPTION
        Get-PrinterInfo returns information about printers and connected printer ports.

    .EXAMPLE
        Get-PrinterInfo

    .EXAMPLE
        Get-PrinterInfo -ComputerName "PCNAME"

    .EXAMPLE
        Get-PrinterInfo -ComputerName "PCNAME" -SkipAppPrinters $true

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
        $ComputerName = $env:computername,

        [PSDefaultValue(Help = {$true})]
        $SkipAppPrinters = $true
    )

    $printerStatus = @{
        0 = 'Idle'
        1 = 'Paused'
        2 = 'Error'
        3 = 'Pending Deletion'
        4 = 'Paper Jam'
        5 = 'Paper Out'
        6 = 'Manual Feed'
        7 = 'Paper Problem'
        8 = 'Offline'
        9 = 'I/O Active'
        10 = 'Busy'
        11 = 'Printing'
        12 = 'Output Bin Full'
        13 = 'Not Available'
        14 = 'Waiting'
        15 = 'Processing'
        16 = 'Initialization'
        17 = 'Warming Up'
        18 = 'Toner Low'
        19 = 'No Toner'
        20 = 'Page Punt'
        21 = 'User Intervention Required'
        22 = 'Out of Memory'
        23 = 'Door Open'
        24 = 'Server_Unknown'
        25 = 'Power Save'
        128 = 'Offline'
        131072 = 'Toner Low'
    }

    $appPrinterNames = @('OneNote','Fax','Microsoft XPS','Microsoft Print to PDF','Adobe PDF','PDF Printer')
    $appPrinterNamesRegex = [string]::Join('|',$appPrinterNames)

    foreach ($pr in (Get-WmiObject MSFT_Printer -Namespace ROOT/StandardCimv2 -Computername $ComputerName)) {

        if ( $SkipAppPrinters -and ($pr.Name -match $appPrinterNamesRegex) ) {
            continue;
        }

        $pp = Get-WmiObject Win32_TCPIPPrinterPort -ComputerName $ComputerName | Where-Object {$_.Name -eq $pr.PortName}

        New-Object -TypeName PSObject -Property ([ordered]@{
        'PrinterName' = $pr.Name
        'Location' = $pr.Location
        'PrinterStatus' = $printerStatus[[int]$pr.PrinterStatus]
        'PortName' = $pr.PortName
        'PrinterHostAddress' = $pp.HostAddress
        'PortDescription' = $pp.Description
        'ComputerName' = $ComputerName
        'SNMPCommunity' = $pp.SNMPCommunity
        'SNMPEnabled' = $pp.SNMPEnabled
        'PortNumber' = $pp.PortNumber
        'DriverName' = $pr.DriverName
        })
    } 
}