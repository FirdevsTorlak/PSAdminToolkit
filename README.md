# PSAdminToolkit

A **cross‑platform PowerShell admin toolkit** with **Pester** tests and **GitHub Actions** CI.
It showcases clean module design, advanced functions with comment‑based help, static analysis
via **PSScriptAnalyzer**, and a test suite that runs on Windows, Linux, and macOS.

> **Requires PowerShell 7+**

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Project Structure](#project-structure)
- [Quality: Tests & Linting](#quality-tests--linting)
- [Continuous Integration](#continuous-integration)
- [Versioning & Releases](#versioning--releases)
- [Publishing to PowerShell Gallery (Optional)](#publishing-to-powershell-gallery-optional)
- [Contributing](#contributing)
- [Security Policy](#security-policy)
- [License](#license)

---

## Features

- `Get-SystemHealth` – Cross‑platform snapshot including OS description, CPU count,
  uptime, PowerShell version, process count, and basic disk usage.
- `Test-PortOpen` – Fast TCP port reachability check with configurable timeouts.
- `Update-ModuleVersion` (alias: `Set-ModuleVersion`) – Bump SemVer in the module
  manifest (`major` | `minor` | `patch`). Safe by default with `-WhatIf`.

---

## Requirements

- **PowerShell 7+** (Windows, Linux, or macOS).
- Internet access is *not* required for the module itself, but CI may install
  development dependencies from the PowerShell Gallery.

---

## Installation

Clone and open the repository:

```pwsh
git clone https://github.com/<your-username>/PSAdminToolkit.git
cd PSAdminToolkit
```

Import the module (local development):

```pwsh
pwsh
Import-Module ./src/PSAdminToolkit/PSAdminToolkit.psd1 -Force
```

> If you see an execution policy error on Windows, run:
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

---

## Quick Start

```pwsh
# System snapshot
Get-SystemHealth | Format-List

# TCP reachability
Test-PortOpen -Host github.com -Port 443

# Safe SemVer bump preview (patch)
Set-ModuleVersion -Path ./src/PSAdminToolkit/PSAdminToolkit.psd1 -Part patch -WhatIf
```

---

## Usage Examples

**1) Get-SystemHealth**

```pwsh
$h = Get-SystemHealth
$h | Format-List
$h.Disk
```

**2) Test-PortOpen**

```pwsh
Test-PortOpen -Host 'localhost' -Port 1          # expected false
Test-PortOpen -Host 'github.com' -Port 443       # expected true
Test-PortOpen -Host 'server' -Port 3389 -TimeoutMs 3000
```

**3) Update-ModuleVersion / Set-ModuleVersion**

```pwsh
# Preview bump
Update-ModuleVersion -Path ./src/PSAdminToolkit/PSAdminToolkit.psd1 -Part minor -WhatIf

# Apply bump and verify
Set-ModuleVersion -Path ./src/PSAdminToolkit/PSAdminToolkit.psd1 -Part patch
(Import-PowerShellDataFile ./src/PSAdminToolkit/PSAdminToolkit.psd1).ModuleVersion
```

---

## Project Structure

```
src/PSAdminToolkit/
  PSAdminToolkit.psd1   # Manifest (FunctionsToExport/AliasesToExport configured)
  PSAdminToolkit.psm1   # Loader: Private → Public, dynamic export, alias creation
  Public/               # Exported functions (Get-SystemHealth, Test-PortOpen, Update-ModuleVersion)
  Private/              # Internal helpers (if/when needed)

tests/                  # Pester tests (v5), including version bump + alias checks
.github/workflows/ci.yml# GitHub Actions: ScriptAnalyzer + Pester on Win/Linux/macOS
tools/                  # PSScriptAnalyzer settings (Rules tuned for this repo)
scripts/                # Dev helper scripts (Install-DevDeps.ps1)
examples/               # Example usage scripts
```

---

## Quality: Tests & Linting

**Run tests (Pester):**
```pwsh
Invoke-Pester -CI -Output Detailed
```

**Static analysis (PSScriptAnalyzer):**
```pwsh
Invoke-ScriptAnalyzer -Path src -Recurse -Settings ./tools/PSScriptAnalyzerSettings.psd1
```

**Dev dependencies (one‑time):**
```pwsh
pwsh -File ./scripts/Install-DevDeps.ps1
```

---

## Continuous Integration

CI runs on **ubuntu-latest**, **windows-latest**, and **macos-latest** on every push and PR:

- Installs **PSScriptAnalyzer** and **Pester**
- Runs ScriptAnalyzer with the repo ruleset
- Executes the Pester test suite

You can find the workflow at: `/.github/workflows/ci.yml`

Add status badges to your README after pushing:

```md
![CI](https://img.shields.io/github/actions/workflow/status/<your-username>/PSAdminToolkit/ci.yml?branch=main)
![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
```

---

## Versioning & Releases

Follow **SemVer**:
- `major` – incompatible API changes
- `minor` – backward‑compatible functionality
- `patch` – backward‑compatible bug fixes

Commands:
```pwsh
# bump
Set-ModuleVersion -Path ./src/PSAdminToolkit/PSAdminToolkit.psd1 -Part patch

# commit & tag
git commit -am "chore: bump version"
git tag v0.1.4
git push && git push --tags
```

Recommended commit convention: **Conventional Commits** (`feat:`, `fix:`, `chore:` …).

---

## Publishing to PowerShell Gallery (Optional)

1. Ensure `Author`, `Description`, `Tags`, `ProjectUri`, `LicenseUri` are set in the manifest.
2. Create an API key in the PowerShell Gallery and store it as `PSGALLERY_API_KEY` (GitHub Secret).
3. Use a publish workflow triggered on tags (example):

```yaml
name: Publish
on:
  push:
    tags: ['v*']
jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install PowerShellGet
        shell: pwsh
        run: |
          Set-PSRepository PSGallery -InstallationPolicy Trusted
          Install-Module PowerShellGet -Force -Scope CurrentUser
      - name: Publish to PSGallery
        shell: pwsh
        env:
          NUGET_KEY: ${ secrets.PSGALLERY_API_KEY }
        run: |
          Publish-Module -Path ./src/PSAdminToolkit `
            -NuGetApiKey $env:NUGET_KEY -Verbose
```

---

## Contributing

- Open an issue to discuss significant changes.
- Write unit tests for new functionality (Pester v5).
- Run ScriptAnalyzer and fix warnings.
- Follow **PowerShell approved verbs**, comment‑based help, and `SupportsShouldProcess` where relevant.
- Keep functions cross‑platform when possible.

---

## Security Policy

If you discover a vulnerability, please **do not** open a public issue.
Email the maintainers or use a private channel. We will coordinate a fix and
disclosure timeline.

---

## License

This project is released under the **MIT License**. See [LICENSE](LICENSE) for details.

---

_Last updated: 2025-10-17_