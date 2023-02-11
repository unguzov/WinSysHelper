function Get-HDDEventsFromLog {
    <#
    .SYNOPSIS
        Returns information from Event logs about drive problems.
    
    .DESCRIPTION
        Get-HDDEventsFromLog returns information from Event logs about drive problems.
    
    .EXAMPLE
        Get-HDDEventsFromLog

    .EXAMPLE
        Get-HDDEventsFromLog -ShowOnlyBadBlocks $false

    .EXAMPLE
        Get-HDDEventsFromLog -ComputerName "MyPC"

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

        [PSDefaultValue(Help = "10")]
        $First = 10,

        [PSDefaultValue(Help = $true)]
        $ShowOnlyBadBlocks = $true
    )

    if ($ShowOnlyBadBlocks) {
        Get-EventLog -LogName System -ComputerName $ComputerName | `
        Where-Object { 
            ($_.EventID -eq 7)
        } | Select-Object Index,EventID,EntryType,TimeGenerated,Message -First $First
    } else {
        Get-EventLog -LogName System -ComputerName $ComputerName | `
        Where-Object { 
            ($_.Source -eq "Disk") -and
            ( ($_.EntryType -eq "Error") -or ($_.EntryType -eq "Warning") )
        } | Select-Object Index,EventID,EntryType,TimeGenerated,Message -First $First
    }
}