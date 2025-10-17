# PSAdminToolkit.psm1
# Module loader: loads Private helpers first, then Public functions,
# defines convenient aliases, and exports only functions that are actually defined.

#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve folders
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'

# --- Load Private helpers (if any) -------------------------------------------
Get-ChildItem -Path $privatePath -Filter *.ps1 -ErrorAction SilentlyContinue |
ForEach-Object {
    Write-Verbose "Loading private: $($_.Name)"
    . $_.FullName
}

# --- Load Public functions (with error visibility) ---------------------------
$publicScripts = Get-ChildItem -Path $publicPath -Filter *.ps1 -ErrorAction SilentlyContinue
foreach ($script in $publicScripts) {
    Write-Verbose "Loading public:  $($script.Name)"
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to load public script '$($script.Name)': $($_.Exception.Message)"
        throw
    }
}

# --- Define aliases only when backing functions exist ------------------------
$aliasesToExport = @()
if (Get-Command -Name Update-ModuleVersion -CommandType Function -ErrorAction SilentlyContinue) {
    Set-Alias -Name Set-ModuleVersion -Value Update-ModuleVersion
    $aliasesToExport += 'Set-ModuleVersion'
}

# --- Export only functions that are truly defined ----------------------------
$definedFunctions = foreach ($script in $publicScripts) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($script.Name)
    if (Get-Command -Name $name -CommandType Function -ErrorAction SilentlyContinue) { $name }
}

# De-duplicate just in case
$definedFunctions = $definedFunctions | Select-Object -Unique

Write-Verbose ("Exporting functions: {0}" -f ($definedFunctions -join ', '))
if ($aliasesToExport) {
    Write-Verbose ("Exporting aliases:   {0}" -f ($aliasesToExport -join ', '))
}

Export-ModuleMember -Function $definedFunctions -Alias $aliasesToExport