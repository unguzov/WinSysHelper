
function Get-TreeFolderSize {
    <#
    .SYNOPSIS
        Returns information about folders file size.
    
    .DESCRIPTION
        Get-TreeFolderSize returns information about one level deep folders file size.
        Files in start folder are included.
    
    .EXAMPLE
        Get-TreeFolderSize

    .EXAMPLE
        Get-TreeFolderSize -StartFolder "C:\Users\"

    .EXAMPLE
        Get-TreeFolderSize -StartFolder "C:\Users\" -FormatResult TopByFiles

    .EXAMPLE
        Get-TreeFolderSize -StartFolder "C:\Users\" -ShowSizeOnDisk $false -FormatResult Raw

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
        [PSDefaultValue(Help = ".")]
        [string]
        $StartFolder = (Get-Location).Path,

        [Parameter(Position = 1)]
        [PSDefaultValue(Help = "TopBySize")]
        [ValidateSet('TopBySize', 'TopByFiles', 'Raw')]
        [string]
        $FormatResult = 'TopBySize',

        [Parameter(Position = 2)]
        [PSDefaultValue(Help = "20")]
        [int]
        $First = 20,

        [Parameter(Position = 3)]
        [PSDefaultValue(Help = {"$true"})]
        [bool]
        $ShowSizeOnDisk = $true
    )

    $source = @"
    using System;
    using System.Runtime.InteropServices;
    using System.ComponentModel;
    using System.IO;
   
    namespace Win32
    {
       
       public class Disk {
       
       [DllImport("kernel32.dll")]
       static extern uint GetCompressedFileSizeW([In, MarshalAs(UnmanagedType.LPWStr)] string lpFileName,
       [Out, MarshalAs(UnmanagedType.U4)] out uint lpFileSizeHigh);	
           
       public static ulong GetSizeOnDisk(string filename)
       {
         uint HighOrderSize;
         uint LowOrderSize;
         ulong size;

         FileInfo file = new FileInfo(filename);
         LowOrderSize = GetCompressedFileSizeW(file.FullName, out HighOrderSize);
   
         if (HighOrderSize == 0 && LowOrderSize == 0xffffffff)
          {
            //throw new Win32Exception(Marshal.GetLastWin32Error());
            return 0;
          }
         else { 
           size = ((ulong)HighOrderSize << 32) + LowOrderSize;
           return size;
         }
       }

       }
    }
"@

    Add-Type -TypeDefinition $source

    if ( (Test-Path -Path $StartFolder) -eq $false ) {
        Write-Host "Path '$StartFolder' not found."
        return;
    }

    Write-Host -NoNewline "Reading folders..."

    # Get files from current folder
    $files = Get-ChildItem $StartFolder -Attributes !Directory+!System -Force -ErrorAction SilentlyContinue

    $fsize = 0
    foreach ($file in $files) {
        if ($ShowSizeOnDisk) {
            try {
                $fsize += [Win32.Disk]::GetSizeOnDisk($file.FullName)
            }
            catch {
            }
        } else {
            $fsize += $file.Length
        }
    }

    $RetValue = @()

    $RetValue += New-Object -TypeName psobject -Property ([ordered]@{
        'SizeBytes' = $fsize
        'Size' = 
        if ($fsize -eq 0) {
            "{0:n2} KB" -f ($fsize / 1KB)
        } else {
            switch ([math]::truncate([math]::log($fsize,1024))) {
                0 {"$fsize Bytes"}
                1 {"{0:n2} KB" -f ($fsize / 1KB)}
                2 {"{0:n2} MB" -f ($fsize / 1MB)}
                3 {"{0:n2} GB" -f ($fsize / 1GB)}
                4 {"{0:n2} TB" -f ($fsize / 1TB)}
                Default {"{0:n2} PB" -f ($fsize / 1pb)}
            }
        }
        'Files' = $files.count
        'Folder' = $StartFolder
    })

    $folders = Get-ChildItem -Path $StartFolder -Attributes Directory+!System -Force
    
    foreach ($folder in $folders) {

        # Get files from subfolders
        $files = Get-ChildItem $folder.FullName -Recurse -Attributes !Directory+!System -Force -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -notmatch "HardLink" }

        $fsize = 0
        foreach ($file in $files) {
            if ($ShowSizeOnDisk) {
                try {
                    $fsize += [Win32.Disk]::GetSizeOnDisk($file.FullName)
                }
                catch {
                }
            } else {
                $fsize += $file.Length
            }
        }

        $RetValue += New-Object -TypeName psobject -Property ([ordered]@{
            'SizeBytes' = $fsize
            'Size' = 
            if ($fsize -eq 0) {
                "{0:n2} KB" -f ($fsize / 1KB)
            } else {
                switch ([math]::truncate([math]::log($fsize,1024))) {
                    0 {"$fsize Bytes"}
                    1 {"{0:n2} KB" -f ($fsize / 1KB)}
                    2 {"{0:n2} MB" -f ($fsize / 1MB)}
                    3 {"{0:n2} GB" -f ($fsize / 1GB)}
                    4 {"{0:n2} TB" -f ($fsize / 1TB)}
                    Default {"{0:n2} PB" -f ($fsize / 1pb)}
                }
            }
            'Files' = $files.count
            'Folder' = $folder.FullName
        })
    }
    Write-Host " Ready."

    switch ($FormatResult) {
        'TopBySize' { 
            $RetValue | 
            Sort-Object SizeBytes -Descending | 
            Select-Object -First $First | 
            Format-Table @{n='Size';e={$_.Size};a="right"},Files,Folder -AutoSize -Wrap 
        }
        'TopByFiles' {
            $RetValue | 
            Sort-Object Files -Descending | 
            Select-Object -First $First | 
            Format-Table @{n='Size';e={$_.Size};a="right"},Files,Folder -AutoSize -Wrap
        }
        'Raw' { return $RetValue }
        Default { return $RetValue }
    }
}