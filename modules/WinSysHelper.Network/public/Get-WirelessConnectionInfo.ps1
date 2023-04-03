function Get-WirelessConnectionInfo {
    <#
    .SYNOPSIS
      Returns information about wireless adapter.
  
    .DESCRIPTION
      Get-WirelessConnectionInfo returns information about wireless adapter and connection status.
  
    .EXAMPLE
      Get-WirelessConnectionInfo

    .EXAMPLE
        $firstLine = 0
        while ($true) { `
        if ($firstLine -eq 0) { `
            (Get-WirelessConnectionInfo `
            | ft SSID,Signal,Channel,Band,Radio,Authentication,BSSID `
            -AutoSize | Out-String).Trim()
            $firstLine = 1
        } else { `
            (Get-WirelessConnectionInfo `
            | ft SSID,Signal,Channel,Band,Radio,Authentication,BSSID `
            -AutoSize -HideTableHeaders | Out-String).Trim() `
        } `
        Start-Sleep 2 `
        }
      
    .OUTPUTS
      PSCustomObject
  
    .NOTES
      Author:  Nikolay Unguzov
      Website: https://procomp-bg.com
    #>

    $winterfaces = (netsh wlan show interfaces)
  
    $state = ($winterfaces | Select-String '(?<=State\s+:\s).+').Matches.Value
  
    if ($state -ne 'connected') {
      Write-Host " *** Wirelesss adapter is not connected to SSID. ***"
      return
    }
  
    New-Object -TypeName PSObject -Property ([ordered]@{
      'SSID' = ($winterfaces | Select-String '(?<=\bSSID\s+:\s).+').Matches.Value
      'Signal' = ($winterfaces | Select-String '(?<=Signal\s+:\s).+').Matches.Value
      'Channel' = ($winterfaces | Select-String '(?<=Channel\s+:\s).+').Matches.Value
      'Radio' = ($winterfaces | Select-String '(?<=Radio type\s+:\s).+').Matches.Value
      'Connection mode' = ($winterfaces | Select-String '(?<=Connection mode\s+:\s).+').Matches.Value
      'Authentication' = ($winterfaces | Select-String '(?<=Authentication\s+:\s).+').Matches.Value
      'BSSID' = ($winterfaces | Select-String '(?<=BSSID\s+:\s).+').Matches.Value
      'MAC' = ($winterfaces | Select-String '(?<=Physical address\s+:\s).+').Matches.Value
      })
  }
  