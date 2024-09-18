# SudoEsc.psm1

$script:debugMode = $false
$script:lastUpdateCheck = $null
$script:updateCheckInterval = New-TimeSpan -Days 30

function Write-DebugMessage {
	param([string]$message)
	if ($script:debugMode) {
		Write-Host "DEBUG: $message" -ForegroundColor Yellow
	}
}

function Get-PSReadLineVersion {
	$module = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
	return $module.Version
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
	$psReadLineVersion = Get-PSReadLineVersion

	if ($psReadLineVersion -ge [Version]"2.2.0") {
		if (!(Get-PSReadLineKeyHandler -Chord 'Escape,Escape' | Where-Object { $_.Function -eq 'SudoEscHandler' })) {
			Set-PSReadLineKeyHandler -Chord 'Escape,Escape' -ScriptBlock {
				Write-DebugMessage "Double Esc detected"
				Switch-SudoCommand
				[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
			} -Description 'SudoEscHandler'
		}
	}
	else {
		$handlers = Get-PSReadLineKeyHandler
		if (!($handlers | Where-Object { $_.Key -eq 'Escape' -and $_.Function -eq 'SudoEscHandler' })) {
			Set-PSReadLineKeyHandler -Key 'Escape' -ScriptBlock {
				$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				if ($key.VirtualKeyCode -eq 27) {
					Write-DebugMessage "Double Esc detected"
					Switch-SudoCommand
					[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
				}
				else {
					[Microsoft.PowerShell.PSConsoleReadLine]::Insert([char]27 + $key.Character)
				}
			} -Description 'SudoEscHandler'
		}
	}

	Write-Host "SudoEsc functionality enabled. Double-press Esc to switch 'sudo' for the current command."
	Start-AsyncUpdateCheck
}

function Disable-SudoEsc {
	$psReadLineVersion = Get-PSReadLineVersion

	if ($psReadLineVersion -ge [Version]"2.2.0") {
		Remove-PSReadLineKeyHandler -Chord 'Escape,Escape'
	}
	else {
		Remove-PSReadLineKeyHandler -Key 'Escape'
	}

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

function Start-AsyncUpdateCheck {
	if ($null -eq $script:lastUpdateCheck -or
        ((Get-Date) - $script:lastUpdateCheck) -gt $script:updateCheckInterval) {
		$script:lastUpdateCheck = Get-Date
		Start-Job -ScriptBlock {
			$updateInfo = Get-SudoEscUpdateInfo
			if ($updateInfo.UpdateAvailable) {
				Write-Host "An update for SudoEsc is available. Installed version: $($updateInfo.InstalledVersion), Latest version: $($updateInfo.OnlineVersion)" -ForegroundColor Yellow
				Write-Host "To update, run: Update-Module SudoEsc" -ForegroundColor Yellow
			}
		} | Out-Null
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

# Initialize the last update check time
$script:lastUpdateCheck = Get-Date

Export-ModuleMember -Function Enable-SudoEsc, Disable-SudoEsc, SudoEscUpdate
