Function Send-TestPage {
    <#
    .SYNOPSIS
        Sends test page to printer

    .DESCRIPTION
        Send-TestPage Sends test page to printer.

    .EXAMPLE
        Send-TestPage "My printer"

    .EXAMPLE
        Send-TestPage -PrinterName "My printer"

    .OUTPUTS
        PSCustomObject

    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com

    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
        [Parameter(Mandatory,Position=0)]
        [string]
        $PrinterName
    )

    $returnValues = @{
        0    = 'Success'
        5    = 'Access denied'
    }

    $printer = (Get-CimInstance Win32_Printer -Filter "name='$PrinterName'")

    if ($printer) {
        # $retValue = $printer.PrintTestPage()
        $retValue = Invoke-CimMethod -MethodName PrintTestPage -InputObject ($printer)
        Write-Host $returnValues[[int]$retValue.ReturnValue]
    } else {
        Write-Host "Printer '$PrinterName' not found."
    }
}