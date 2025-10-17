# Installs Pester and PSScriptAnalyzer for local development
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Pester -Scope CurrentUser -Force -AllowClobber
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -AllowClobber
