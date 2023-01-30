function Test-InternetSpeed {
    <#
    .SYNOPSIS
        Returns information about Internet speed.

    .DESCRIPTION
        Test-InternetSpeed returns information about Internet speed using SpeeDtest CLI.

    .EXAMPLE
        Test-InternetSpeed

    .EXAMPLE
        Test-InternetSpeed -ShowProgress $false

    .OUTPUTS
        PSCustomObject

    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com
        
    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
        [PSDefaultValue(Help = {$true})]
        $ShowProgress = $true
    )

    mkdir $env:temp\stest -Force > $null
    $tmpLocation = "$env:temp\stest"

    $source = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
    $destination = "$tmpLocation\stest.zip"

    $stfile = "$tmpLocation\speedtest.exe"
    $stParams = "--accept-license --accept-gdpr"

    if ($ShowProgress) {
        $stParams += " -p"
    }

    if (Get-Command 'Invoke-Webrequest') 
    { 
        $ProgressPreference = 'SilentlyContinue' 
        Invoke-WebRequest $source -OutFile $destination 
    } else { 
        $WebClient = New-Object System.Net.WebClient 
        $webclient.DownloadFile($source, $destination) 
    }

    Expand-Archive -LiteralPath $destination -DestinationPath $tmpLocation -Force

    if (Test-Path $stfile -PathType Leaf) {
        if ($ShowProgress) {
            & $stfile $stParams.Split(" ")
        } else {
            Write-Host "Running SpeedTest... " -NoNewline
            $testResult = & $stfile $stParams.Split(" ")
            $testResult
        }

        Remove-Item -LiteralPath $tmpLocation -Recurse -Force
    } else {
        Write-Host "SpeedTest.exe not found."
    }
}