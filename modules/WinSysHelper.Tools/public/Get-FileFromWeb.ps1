function Get-FileFromWeb {
    <#
    .SYNOPSIS
        Returns information about UPS or batteries.
    
    .DESCRIPTION
        Get-FileFromWeb returns information about UPS or batteries and battery status.
    
    .EXAMPLE
        Get-FileFromWeb "https://ninite.com/7zip/ninite.exe"
    
    .EXAMPLE
        Get-FileFromWeb "https://ninite.com/7zip/ninite.exe" -AddFileVersion
    
    .EXAMPLE
        Get-FileFromWeb "https://ninite.com/7zip/ninite.exe" -AddFileVersion -OutputFileName "NewFileName.ext"
    
    .OUTPUTS
        
    
    .NOTES
        Author:  Nikolay Unguzov
        Website: https://procomp-bg.com

    .LINK
        https://github.com/unguzov/WinSysHelper
    #>

    param (
        [Parameter(Position = 0)]
        [PSDefaultValue(Help = "Download URL")]
        [string]
        $DownloadURL,

        [Parameter(Position = 1)]
        [PSDefaultValue(Help = ".")]
        [string]
        $DestFolder = (Get-Location).Path,

        [Parameter()]
        [PSDefaultValue(Help = {"Rename file and add file version."})]
        [switch]
        $AddFileVersion,

        [Parameter()]
        [PSDefaultValue(Help = {"MyFile.ext"})]
        [string]
        $OutputFileName,

        [Parameter()]
        [PSDefaultValue(Help = {"Overrides existing file."})]
        [switch]
        $Force
    )


    $downloadedFile = (Split-Path $DownloadURL -Leaf)

    if ($OutputFileName) {
        $downloadedFile = $OutputFileName
    }

    $destinationFileAndPath = Join-Path $DestFolder $downloadedFile

    if ( (Test-Path $destinationFileAndPath) -and (-not $Force) ) {
        Write-Warning "File $destinationFileAndPath already exists. Use -Force to override the file."
    } else {

        Write-Host "Downloading $DownloadURL ..."
        $ProgressPreference = 'SilentlyContinue' 
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$destinationFileAndPath"
#        Start-BitsTransfer -Source $DownloadURL -Destination "$destinationFileAndPath"

        if (Test-Path $destinationFileAndPath) {
            if ($AddFileVersion) {
                $fileNameWithVersion = "$([System.IO.Path]::GetFileNameWithoutExtension((Get-Item $destinationFileAndPath).Name)).$((Get-Item $destinationFileAndPath | Select-Object -ExpandProperty VersionInfo).FileVersionRaw)$((Get-Item $destinationFileAndPath).Extension)"

                if ( (Test-Path $fileNameWithVersion) -and (-not $Force) ) {
                    Write-Warning "File $fileNameWithVersion already exists. Use -Force to override the file."
                } else {
                    if (Test-Path $fileNameWithVersion) {
                        Remove-Item $fileNameWithVersion
                    }
                    Rename-Item -Path $destinationFileAndPath -NewName $fileNameWithVersion
                    Write-Host "File is renamed and saved to $(Join-Path $DestFolder $fileNameWithVersion)"
                }
            } else {
                Write-Host "File is saved to $destinationFileAndPath"
            }
        } else {
            Write-Error "File $destinationFileAndPath is NOT downloaded."
        }
    }

}