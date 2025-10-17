function Update-ModuleVersion {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path $_ })][string]$Path,
    [ValidateSet('major', 'minor', 'patch')][string]$Part = 'patch'
  )

  # Read the manifest text
  $content = Get-Content -Path $Path -Raw

  # Regex: tolerant to leading spaces, any number of spaces, single or double quotes (first occurrence only)
  $pattern = "(?im)^\s*ModuleVersion\s*=\s*['""](?<ver>\d+\.\d+\.\d+)['""]"

  if ($content -match $pattern) {
    $current = $Matches['ver']
    $parts = $current -split '\.' | ForEach-Object { [int]$_ }

    switch ($Part) {
      'major' { $parts[0]++; $parts[1] = 0; $parts[2] = 0 }
      'minor' { $parts[1]++; $parts[2] = 0 }
      'patch' { $parts[2]++ }
    }

    $new = '{0}.{1}.{2}' -f $parts[0], $parts[1], $parts[2]

    if ($PSCmdlet.ShouldProcess($Path, "Bump version $current -> $new")) {
      # Replace only the first match
      $replacement = "ModuleVersion     = '$new'"
      $newContent = [regex]::Replace($content, $pattern, $replacement, 1)

      # Write back with explicit UTF8 encoding
      Set-Content -Path $Path -Value $newContent -Encoding UTF8

      [pscustomobject]@{
        Path = $Path
        Old  = $current
        New  = $new
      }
    }
  } else {
    throw "ModuleVersion not found in manifest: $Path"
  }
}