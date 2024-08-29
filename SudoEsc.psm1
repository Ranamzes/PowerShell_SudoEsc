# SudoEsc.psm1

$script:debugMode = $false

function Write-DebugMessage {
	param([string]$message)
	if ($script:debugMode) {
		Write-Host "DEBUG: $message" -ForegroundColor Yellow
	}
}

function Switch-SudoCommand {
	$line = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

	if ([string]::IsNullOrWhiteSpace($line)) {
		$line = (Get-History -Count 1).CommandLine
	}

	if (![string]::IsNullOrWhiteSpace($line)) {
		if ($line.TrimStart().StartsWith("sudo ")) {
			$newLine = $line -replace '^(\s*)sudo\s+', '$1'
		}
		else {
			$newLine = $line -replace '^(\s*)', '$1sudo '
		}
		[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
		[Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert($newLine)
	}
}

function Add-SudoEscToProfile {
	$profileContent = @"

# SudoEsc Autoload
if (-not (Get-Module -Name SudoEsc -ListAvailable)) {
		Install-Module -Name SudoEsc -Scope CurrentUser -Force
}
Import-Module SudoEsc
Enable-SudoEsc
"@

	if (!(Test-Path -Path $PROFILE)) {
		New-Item -ItemType File -Path $PROFILE -Force | Out-Null
	}

	$currentContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
	if ($currentContent -notmatch "# SudoEsc Autoload") {
		Add-Content -Path $PROFILE -Value "`n$profileContent"
		Write-Host "SudoEsc has been added to your PowerShell profile. It will be automatically loaded in future sessions." -ForegroundColor Green
		return $true
	}
	else {
		return $false
	}
}

function Enable-SudoEsc {
	if (Get-PSReadLineKeyHandler -Chord 'Escape,Escape' | Where-Object { $_.Function -eq 'SudoEscHandler' }) {
		return
	}

	Set-PSReadLineKeyHandler -Chord 'Escape,Escape' -ScriptBlock {
		Write-DebugMessage "Double Esc detected"
		Switch-SudoCommand
		[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
	} -Description 'SudoEscHandler'

	$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
	if ($profileContent -notmatch "# SudoEsc Autoload") {
		$addToProfile = Read-Host "Do you want to add SudoEsc to your PowerShell profile for automatic loading? (Y/N)"
		if ($addToProfile -eq 'Y' -or $addToProfile -eq 'y') {
			$added = Add-SudoEscToProfile
			if (-not $added) {
				Write-Host "SudoEsc is already in your PowerShell profile." -ForegroundColor Yellow
			}
		}
	}
}

function Disable-SudoEsc {
	Write-DebugMessage "Disabling SudoEsc functionality"
	Remove-PSReadLineKeyHandler -Chord 'Escape,Escape'
	Write-Host "SudoEsc functionality disabled."
}

function Get-SudoEscUpdateInfo {
	$installed = Get-Module SudoEsc -ListAvailable | Select-Object -First 1
	$online = Find-Module SudoEsc -ErrorAction SilentlyContinue
	if ($null -ne $online -and $online.Version -gt $installed.Version) {
		return @{
			UpdateAvailable  = $true
			InstalledVersion = $installed.Version
			OnlineVersion    = $online.Version
		}
	}
	else {
		return @{
			UpdateAvailable  = $false
			InstalledVersion = $installed.Version
		}
	}
}

function SudoEscUpdate {
	$updateInfo = Get-SudoEscUpdateInfo
	if ($updateInfo.UpdateAvailable) {
		Write-Host "An update for SudoEsc is available. Installed version: $($updateInfo.InstalledVersion), Latest version: $($updateInfo.OnlineVersion)"
		Write-Host "To update, run: Update-Module SudoEsc"
	}
	else {
		Write-Host "SudoEsc is up to date. Current version: $($updateInfo.InstalledVersion)"
	}
}

Export-ModuleMember -Function Enable-SudoEsc, Disable-SudoEsc, SudoEscUpdate
