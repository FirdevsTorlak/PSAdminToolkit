# Example script showing basic usage
Import-Module "$PSScriptRoot/../src/PSAdminToolkit/PSAdminToolkit.psd1" -Force
$h = Get-SystemHealth
"OS: {0}" -f $h.OSDescription
"Uptime: {0}" -f $h.Uptime
$res = Test-PortOpen -Host "github.com" -Port 443
"Port open: {0}" -f $res.Open
