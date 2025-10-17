
function Set-ModuleManifestVersion {
    <#
.SYNOPSIS
  Bumps the ModuleVersion in the module manifest using SemVer.
.PARAMETER Path
  Path to the module .psd1 file.
.PARAMETER Part
  Which part to bump: major, minor, or patch (default patch).
.EXAMPLE
  Set-ModuleManifestVersion -Path ./src/PSAdminToolkit/PSAdminToolkit.psd1 -Part minor
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][ValidateScript({ Test-Path $_ })][string]$Path,
        [ValidateSet('major', 'minor', 'patch')][string]$Part = 'patch'
    )

    $content = Get-Content -Path $Path -Raw
    if ($content -match "ModuleVersion\s*=\s*'(?<ver>\d+\.\d+\.\d+)'") {
        $current = $Matches.ver
        $parts = $current -split '\.' | ForEach-Object { [int]$_ }
        switch ($Part) {
            'major' { $parts[0]++; $parts[1] = 0; $parts[2] = 0 }
            'minor' { $parts[1]++; $parts[2] = 0 }
            'patch' { $parts[2]++ }
        }
        $new = "{0}.{1}.{2}" -f $parts[0], $parts[1], $parts[2]

        if ($PSCmdlet.ShouldProcess($Path, "Bump version $current -> $new")) {
            $newContent = $content -replace "ModuleVersion\s*=\s*'\d+\.\d+\.\d+'", "ModuleVersion     = '$new'"
            Set-Content -Path $Path -Value $newContent -NoNewline
            [pscustomobject]@{ Path = $Path; Old = $current; New = $new }
        }
    }
    else {
        throw "ModuleVersion not found in manifest: $Path"
    }
}
