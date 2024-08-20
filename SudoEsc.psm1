# SudoEsc.psm1

$script:debugMode = $false  # Отключаем режим отладки по умолчанию

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

function Enable-SudoEsc {
	Write-DebugMessage "Enabling SudoEsc functionality"

	Set-PSReadLineKeyHandler -Chord 'Escape,Escape' -ScriptBlock {
		Write-DebugMessage "Double Esc detected"
		Switch-SudoCommand
		# Перемещаем курсор в конец строки
		[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
	}

	Write-Host "SudoEsc functionality enabled. Double-press Esc to switch 'sudo' for the current command."
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

function Get-SudoEscUpdate {
	$updateInfo = Get-SudoEscUpdateInfo
	if ($updateInfo.UpdateAvailable) {
		Write-Host "An update for SudoEsc is available. Installed version: $($updateInfo.InstalledVersion), Latest version: $($updateInfo.OnlineVersion)"
		Write-Host "To update, run: Update-Module SudoEsc"
	}
	else {
		Write-Host "SudoEsc is up to date. Current version: $($updateInfo.InstalledVersion)"
	}
}

Export-ModuleMember -Function Enable-SudoEsc, Disable-SudoEsc, Get-SudoEscUpdate
