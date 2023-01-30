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

    Get-CimInstance SoftwareLicensingProduct `
    -Filter "Name like 'Windows%'" `
    | Where-Object { $_.PartialProductKey } `
    | Select-Object Description, `
    @{Label="LicenseStatus";Expression={$licenseStatus[[int]$_.LicenseStatus]}}, `
    @{Label="LicenseStatusReason";Expression={$LicenseStatusReasonStatus[[int]$_.LicenseStatusReasonStatus]}}, `
    ProductKeyChannel,PartialProductKey,EvaluationEndDate
}