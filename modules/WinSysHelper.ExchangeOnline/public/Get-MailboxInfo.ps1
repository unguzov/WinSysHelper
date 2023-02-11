function Get-MailboxInfo {
    <#
    .SYNOPSIS
        Returns informationabout Exchnage mailboxes.
    
    .DESCRIPTION
        Get-MailboxInfo returns information about Exchnage Online mailboxes.
    
    .EXAMPLE
        Get-MailboxInfo

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
        $LimitEvents = 10,

        [PSDefaultValue(Help = $true)]
        $ShowOnlyBadBlocks = $true
    )

    $mailboxes = Get-Mailbox 
    | Where-Object {$_.DisplayName -notlike "Discovery Search Mailbox"}

    ForEach ($mailbox in ( $mailboxes )) {
        $stats = $mailbox | Get-EXOMailboxStatistics
        New-Object -TypeName PSObject -Property ([ordered]@{
            'PrimarySmtpAddress' = $mailbox.PrimarySmtpAddress
            'RecipientTypeDetails' = $mailbox.RecipientTypeDetails
            'ItemCount' = $stats.ItemCount
            'TotalItemSize' = $stats.TotalItemSize
            'DeletedItemCount' = $stats.DeletedItemCount
            'TotalDeletedItemSize' = $stats.TotalDeletedItemSize
            'IsMailboxEnabled' = $mailbox.IsMailboxEnabled
            'MaxSendSize' = $mailbox.MaxSendSize
            'MaxReceiveSize' = $mailbox.MaxReceiveSize
            'WhenChanged' = $mailbox.WhenChanged
            'DisplayName' = $mailbox.DisplayName
        })
    }
}