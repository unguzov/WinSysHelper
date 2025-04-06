function Get-ActivationInfo {
    <#
    .SYNOPSIS
        Returns information about Windows activation.

    .DESCRIPTION
        Get-ActivationInfo returns information about Windows activation status.

    .EXAMPLE
        Get-ActivationInfo

    .OUTPUTS
        PSCustomObject

    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com
        
    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
    )

    $licenseStatus = @{
        0 = 'Unlicensed'
        1 = 'Licensed'
        2 = 'Initial grace period - OOBGrace'
        3 = 'Additional grace period (KMS license expired or hardware out of tolerance) - OOTGrace'
        4 = 'Non-genuine grace period'
        5 = 'Notification'
        6 = 'Extended grace period'
    }

    $LicenseStatusReasonStatus = @{
        0 = 'Activated with a product key'
        1074066433 = 'Activated with digital entitlement'
        2147942402 = 'File not found'
        3221549065 = 'Non-genuine'
        3221549568 = 'Grace time expired'
    }

    # Try to get Windows Key

    $map="BCDFGHJKMPQRTVWXY2346789"

    $value = (get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42]
    $ProductKey = ""

    for ($i = 24; $i -ge 0; $i--) {
    $r = 0
    for ($j = 14; $j -ge 0; $j--) {
        $r = ($r * 256) -bxor $value[$j]
        $value[$j] = [math]::Floor([double]($r / 24))
        $r = $r % 24
    }

    $ProductKey = $map[$r] + $ProductKey

    if (($i % 5) -eq 0 -and $i -ne 0) {
        $ProductKey = "-" + $ProductKey
    }
    }

    $ainfo = Get-CimInstance SoftwareLicensingProduct `
    -Filter "Name like 'Windows%'" `
    | Where-Object { $_.PartialProductKey } `
    | Select-Object Description, `
    @{Label="LicenseStatus";Expression={$licenseStatus[[int]$_.LicenseStatus]}}, `
    @{Label="LicenseStatusReason";Expression={$LicenseStatusReasonStatus[[int]$_.LicenseStatusReasonStatus]}}, `
    ProductKeyChannel,PartialProductKey

    $compInfo = Get-ComputerInfo `
    | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer, OsInstallDate

    New-Object -TypeName PSObject -Property ([ordered]@{
        'Description' = $ainfo.Description
        'LicenseStatus' = $ainfo.LicenseStatus
        'LicenseStatusReason' = $ainfo.LicenseStatusReason
        'ProductKeyChannel' = $ainfo.ProductKeyChannel
        'PartialProductKey' = $ainfo.PartialProductKey
        'GuessedProductKey' = $ProductKey
        'WindowsProductName' = $compInfo.WindowsProductName
        'WindowsVersion' = $compInfo.WindowsVersion
        'OsHardwareAbstractionLayer' = $compInfo.OsHardwareAbstractionLayer
        'OsInstallDate' = $compInfo.OsInstallDate
        })

        
}