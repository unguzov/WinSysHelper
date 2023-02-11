function Get-InstalledSoftware {
    <#
    .SYNOPSIS
        Returns information about installed software.
    
    .DESCRIPTION
        Get-InstalledSoftware returns information about installed software.
        Must be run in user account context to collect HKCU data.
    
    .EXAMPLE
        Get-InstalledSoftware

    .EXAMPLE
        Get-InstalledSoftware '*adobe*'

    .EXAMPLE
        Set-Location $env:TEMP

        Get-InstalledSoftware `
        | Select-Object * `
        | Export-Csv -Path ".\$env:COMPUTERNAME-software.csv" -Encoding Unicode -NoTypeInformation

        Import-Csv `
        -Path .\*.csv `
        | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation, InstallSource, PSDrive `
        | Out-GridView 

    .OUTPUTS
        PSCustomObject
    
    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com

    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
        [Parameter(Position = 0)]
        [PSDefaultValue(Help = "*")]
        [string]
        $DisplayName = '*',

        [PSDefaultValue(Help = $false)]
        $IncludeEmptyDisplayNames = $false,

        [PSDefaultValue(Help = $true)]
        $UniqueDisplayNames = $true
    )

    $RegPaths = @(
        'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $Soft = $null

    foreach ($rp in $RegPaths) {
        if ($IncludeEmptyDisplayNames) {
            $Soft += Get-ItemProperty -Path $rp | Sort-Object DisplayName
        } else {
            $Soft += Get-ItemProperty -Path $rp | Sort-Object DisplayName | Where-Object {$_.DisplayName}
        }
    }

    [string[]]$visible = @(
        'DisplayName'
        'DisplayVersion'
        'Publisher'
    )

    [Management.Automation.PSMemberInfo[]]$visibleProperties = [System.Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet',$visible)

    if ($UniqueDisplayNames) {
        $Soft `
        | Where-Object {$_.DisplayName -like "$DisplayName"} `
        | Sort-Object DisplayName -Unique `
        | Select-Object -Property * `
        | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $visibleProperties -PassThru
    } else {
        $Soft `
        | Where-Object {$_.DisplayName -like "$DisplayName"} `
        | Sort-Object DisplayName `
        | Select-Object -Property * `
        | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $visibleProperties -PassThru
   }

}