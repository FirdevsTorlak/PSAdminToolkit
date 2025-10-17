function Test-PortOpen {
<#
.SYNOPSIS
  Checks if a TCP port is reachable on a host.
.PARAMETER ComputerName
  Target hostname or IP address. Aliases: Host, DnsName
.PARAMETER Port
  TCP port number.
.PARAMETER TimeoutMs
  Timeout in milliseconds (default 2000).
.EXAMPLE
  Test-PortOpen -ComputerName github.com -Port 443
.EXAMPLE
  # Alias works too:
  Test-PortOpen -Host github.com -Port 443
#>
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    [Alias('Host','DnsName')]
    [string]$ComputerName,
    [Parameter(Mandatory)]
    [int]$Port,
    [int]$TimeoutMs = 2000
  )

  if ($PSCmdlet.ShouldProcess("$($ComputerName):$Port", "Connect")) {
    try {
      $client = [System.Net.Sockets.TcpClient]::new()
      $connectTask = $client.ConnectAsync($ComputerName, $Port)
      if (-not $connectTask.Wait($TimeoutMs)) {
        $client.Dispose()
        return [pscustomobject]@{ ComputerName = $ComputerName; Port = $Port; Open = $false; Error = "Timeout after ${TimeoutMs}ms" }
      }
      $open = $client.Connected
      $client.Dispose()
      return [pscustomobject]@{ ComputerName = $ComputerName; Port = $Port; Open = [bool]$open; Error = $null }
    }
    catch {
      return [pscustomobject]@{ ComputerName = $ComputerName; Port = $Port; Open = $false; Error = $_.Exception.Message }
    }
  }
}
