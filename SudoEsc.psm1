# SudoEsc.psm1
$escCount = 0
$lastEscTime = [DateTime]::MinValue

function Add-SudoToLastCommand {
	$line = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$null)
	if ([string]::IsNullOrWhiteSpace($line)) {
		$line = (Get-History -Count 1).CommandLine
	}
	if (![string]::IsNullOrWhiteSpace($line)) {
		if (!$line.StartsWith("sudo ")) {
			[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
			[Microsoft.PowerShell.PSConsoleReadLine]::InsertText("sudo $line")
			[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
		}
	}
}

function Enable-SudoEsc {
	Set-PSReadLineKeyHandler -Chord Escape -ScriptBlock {
		$now = [DateTime]::Now
		if (($now - $script:lastEscTime).TotalMilliseconds -lt 300) {
			$script:escCount++
		}
		else {
			$script:escCount = 1
		}
		$script:lastEscTime = $now
		if ($script:escCount -eq 2) {
			Add-SudoToLastCommand
			$script:escCount = 0
		}
		else {
			[Microsoft.PowerShell.PSConsoleReadLine]::CancelLine()
		}
	}
	Write-Host "SudoEsc functionality enabled. Double-press Esc to add 'sudo' to the last command."
}

function Disable-SudoEsc {
	Remove-PSReadLineKeyHandler -Chord Escape
	Write-Host "SudoEsc functionality disabled."
}

function Get-SudoEscUpdateInfo {
	$installed = Get-Module SudoEsc -ListAvailable | Select-Object -First 1
	$online = Find-Module SudoEsc -ErrorAction SilentlyContinue

	if ($online -and ($online.Version -gt $installed.Version)) {
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

# Запускаем проверку обновлений в фоновом режиме
Start-Job -ScriptBlock {
	$updateInfo = Get-SudoEscUpdateInfo
	if ($updateInfo.UpdateAvailable) {
		Write-Host "An update for SudoEsc is available. Installed version: $($updateInfo.InstalledVersion), Latest version: $($updateInfo.OnlineVersion)"
		Write-Host "To update, run: Update-Module SudoEsc"
	}
} | Out-Null

Export-ModuleMember -Function Enable-SudoEsc, Disable-SudoEsc, Get-SudoEscUpdate
