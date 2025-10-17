BeforeAll {
  # Import the module once for all tests
  $modulePath = Join-Path (Join-Path $PSScriptRoot '..') 'src/PSAdminToolkit/PSAdminToolkit.psd1'
  Import-Module $modulePath -Force
}

Describe 'PSAdminToolkit' {

  It 'imports the module' {
    (Get-Module PSAdminToolkit) | Should -Not -BeNullOrEmpty
  }

  Context 'Get-SystemHealth' {
    It 'returns expected properties' {
      $h = Get-SystemHealth
      $h | Should -Not -BeNullOrEmpty
      $h | Get-Member -Name OSDescription     | Should -Not -BeNullOrEmpty
      $h | Get-Member -Name ProcessorCount    | Should -Not -BeNullOrEmpty
      $h | Get-Member -Name Uptime            | Should -Not -BeNullOrEmpty
      $h | Get-Member -Name PowerShellVersion | Should -Not -BeNullOrEmpty
    }
  }

  Context 'Test-PortOpen' {
    It 'returns false for a closed local port' {
      # Port 1 on localhost should be closed in most environments
      $res = Test-PortOpen -Host '127.0.0.1' -Port 1 -WhatIf:$false
      $res | Should -Not -BeNullOrEmpty
      $res | Get-Member -Name Open | Should -Not -BeNullOrEmpty
      $res.Open | Should -BeFalse
    }
  }

  Context 'Update-ModuleVersion and alias' {

    It 'exports Update-ModuleVersion and Set-ModuleVersion alias' {
      Get-Command Update-ModuleVersion -Module PSAdminToolkit | Should -Not -BeNullOrEmpty
      (Get-Command Set-ModuleVersion).Source | Should -Be 'PSAdminToolkit'
    }

    It 'bumps version on a test manifest copy (patch)' {
      # Work on a copy under Pester's TestDrive to avoid modifying the real manifest
      $original = Join-Path (Join-Path $PSScriptRoot '..') 'src/PSAdminToolkit/PSAdminToolkit.psd1'
      $temp = Join-Path $TestDrive 'PSAdminToolkit.psd1'
      Copy-Item -Path $original -Destination $temp -Force

      # Read before/after using Import-PowerShellDataFile (more robust than regex)
      $before = (Import-PowerShellDataFile -Path $temp).ModuleVersion.ToString()
      $result = Update-ModuleVersion -Path $temp -Part patch -WhatIf:$false
      $after = (Import-PowerShellDataFile -Path $temp).ModuleVersion.ToString()

      # Sanity check: the function's reported "New" matches what we read back
      $result.New | Should -Be $after

      # Assert only the patch part increased by 1
      $b = $before -split '\.' | ForEach-Object { [int]$_ }
      $a = $after -split '\.' | ForEach-Object { [int]$_ }

      $a[0] | Should -Be $b[0]
      $a[1] | Should -Be $b[1]
      $a[2] | Should -Be ($b[2] + 1)
    }
  }

}