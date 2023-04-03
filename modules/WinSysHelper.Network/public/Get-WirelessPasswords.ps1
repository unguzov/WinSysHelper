function Get-WirelessPasswords {
    <#
    .SYNOPSIS
      Returns information about wireless passwords.
  
    .DESCRIPTION
      Get-WirelessPasswords returns information about wireless profiles passwords.
  
    .EXAMPLE
      Get-WirelessPasswords

    .OUTPUTS
      PSCustomObject
  
    .NOTES
      Author:  Nikolay Unguzov
      Website: https://procomp-bg.com
    #>
    
    (netsh wlan show profile) | Select-String '(?<=All User Profile\s+:\s).+' | ForEach-Object {
        New-Object -TypeName PSObject -Property ([ordered]@{
            SSID = $_.Matches.Value
            Key = (netsh wlan show profile $_.Matches.Value key=clear | Select-String '(?<=Key Content\s+:\s).+').Matches.Value
        })
    } | Sort-Object SSID

}
