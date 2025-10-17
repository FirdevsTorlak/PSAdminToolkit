
function Get-SystemHealth {
    <#
.SYNOPSIS
  Returns a quick, cross-platform system health snapshot.
.DESCRIPTION
  Collects OS description, processor count, uptime, process count, PowerShell version,
  and basic disk usage for the primary ready drive.
.EXAMPLE
  Get-SystemHealth | Format-List
#>
    [CmdletBinding()]
    param()

    $os = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
    $pc = [Environment]::ProcessorCount
    $upt = [TimeSpan]::FromMilliseconds([Environment]::TickCount64)
    $psv = $PSVersionTable.PSVersion.ToString()
    $procs = [System.Diagnostics.Process]::GetProcesses().Count

    $drive = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady } | Select-Object -First 1
    $disk = if ($drive) {
        [pscustomobject]@{
            Name    = $drive.Name
            TotalGB = [Math]::Round($drive.TotalSize / 1GB, 2)
            FreeGB  = [Math]::Round($drive.TotalFreeSpace / 1GB, 2)
            UsedPct = if ($drive.TotalSize -ne 0) { [Math]::Round((1 - ($drive.TotalFreeSpace / $drive.TotalSize)) * 100, 2) } else { 0 }
        }
    }
    else {
        $null
    }

    [pscustomobject]@{
        OSDescription     = $os
        ProcessorCount    = $pc
        Uptime            = $upt
        ProcessCount      = $procs
        PowerShellVersion = $psv
        Disk              = $disk
    }
}
