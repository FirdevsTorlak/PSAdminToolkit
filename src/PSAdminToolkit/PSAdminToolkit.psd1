@{
    RootModule        = 'PSAdminToolkit.psm1'
    ModuleVersion     = '0.1.3'
    GUID              = '30c86904-3849-4adf-bcb5-6edad4d98504'
    Author            = 'PSAdminToolkit Contributors'
    CompanyName       = 'Community'
    Copyright         = '(c) 2025 PSAdminToolkit Contributors. MIT License.'
    Description       = 'Cross-platform PowerShell admin toolkit with Pester tests & CI. Includes health checks, port tests, and version bump utilities.'
    PowerShellVersion = '7.0'

    # Export the real functions (do NOT list aliases here)
    FunctionsToExport = @('Get-SystemHealth', 'Test-PortOpen', 'Update-ModuleVersion')
    CmdletsToExport   = @()
    VariablesToExport = @()

    # Export the alias defined in the module (PSM1)
    AliasesToExport   = @('Set-ModuleVersion')

    PrivateData       = @{
        PSData = @{
            Tags         = @('PowerShell', 'DevOps', 'Pester', 'CI', 'Toolkit')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/<your-username>/PSAdminToolkit'
            ReleaseNotes = 'Initial preview release.'
        }
    }
}