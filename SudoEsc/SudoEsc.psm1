# SudoEsc.psm1

$script:debugMode = $false

function Write-DebugMessage {
	param([string]$message)
	if ($script:debugMode) { Write-Host "DEBUG: $message" -ForegroundColor Yellow }
}

function Get-PSReadLineVersion {
	$module = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
	if ($null -eq $module) { return [Version]"0.0.0" }
	return $module.Version
}

function Test-PSReadLineAvailable {
	return [bool](Get-Module PSReadLine -ListAvailable)
}

function Ensure-SudoAlias {
	[CmdletBinding()]
	param()
	if (-not (Get-Command sudo -ErrorAction SilentlyContinue)) {
		$gsudo = Get-Command gsudo -ErrorAction SilentlyContinue
		if ($gsudo) {
			Set-Item -Path Function:\sudo -Value { & gsudo @args } -Force | Out-Null
		}
	}
}

function Switch-SudoCommand {
	# Prepend or remove 'sudo ' on current/last command, keep cursor sane
	$line = $null
	$cursor = $null
	try { [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor) } catch { $line = $null }

	if ([string]::IsNullOrWhiteSpace($line)) {
		$last = Get-History -Count 1 -ErrorAction SilentlyContinue
		if ($last) { $line = $last.CommandLine }
	}

	if (![string]::IsNullOrWhiteSpace($line)) {
		if ($line.TrimStart().StartsWith('sudo ')) {
			$newLine = $line -replace '^(\s*)sudo\s+', '$1'
		} else {
			$newLine = $line -replace '^(\s*)', '$1sudo '
		}
		try {
			[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
			[Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($newLine)
			[Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
		} catch {
			# If PSReadLine is not active, just write to output as a fallback
			Write-Host $newLine
		}
	}
}

function Remove-ExistingSudoBindings {
	$handlers = Get-PSReadLineKeyHandler -ErrorAction SilentlyContinue
	if ($handlers) {
		$targets = $handlers | Where-Object {
			$desc  = $_.Description
			$brief = $_.BriefDescription
			($_.Function -eq 'ScriptBlock') -and ( $desc -eq 'SudoEscHandler' -or $brief -eq 'SudoEsc' )
		}
		foreach ($h in $targets) {
			if ($h.KeyChord) {
				try { Remove-PSReadLineKeyHandler -Chord $h.KeyChord -ErrorAction SilentlyContinue } catch {}
			} elseif ($h.Key) {
				try { Remove-PSReadLineKeyHandler -Key $h.Key -ErrorAction SilentlyContinue } catch {}
			}
		}
	}
}

function Add-SudoEscToProfile {
	[CmdletBinding()]
	param(
		[switch]$EnsureSudoAlias
	)
	$profileContent = @"
# SudoEsc
Import-Module SudoEsc
Enable-SudoEsc$(if ($EnsureSudoAlias) { ' -EnsureSudoAlias' } )
"@
	if (!(Test-Path -Path $PROFILE)) {
		New-Item -ItemType File -Path $PROFILE -Force | Out-Null
	}
	$current = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
	if ($current -notmatch '# SudoEsc') {
		Add-Content -Path $PROFILE -Value "`n$profileContent"
		Write-Host "SudoEsc has been added to your PowerShell profile." -ForegroundColor Green
		return $true
	}
	return $false
}

function SudoEscUpdate {
	[CmdletBinding()]
	param([switch]$Quiet)
	try {
		$latest = Find-Module -Name SudoEsc -ErrorAction Stop
		$here   = Get-Module -Name SudoEsc -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
		if ($here -and $latest -and ($latest.Version -gt $here.Version)) {
			if (-not $Quiet) { Write-Host ("SudoEsc update available: {0} -> {1}" -f $here.Version, $latest.Version) -ForegroundColor Cyan }
			return @{
				UpdateAvailable = $true
				CurrentVersion  = $here.Version
				LatestVersion   = $latest.Version
			}
		}
	} catch {
		if (-not $Quiet) { Write-Host "SudoEsc update check failed: $($_.Exception.Message)" -ForegroundColor Yellow }
	}
	return @{ UpdateAvailable = $false }
}

function Enable-SudoEsc {
	[CmdletBinding()]
	param(
		[string]$Chord = 'Escape,Escape',
		[switch]$EnsureSudoAlias,
		[switch]$Quiet
	)

	if (-not (Test-PSReadLineAvailable)) {
		if (-not $Quiet) { Write-Host "PSReadLine is not available. SudoEsc cannot be enabled." -ForegroundColor Yellow }
		return
	}

	if ($EnsureSudoAlias) { Ensure-SudoAlias }

	# Remove existing SudoEsc bindings (idempotent)
	Remove-ExistingSudoBindings

	$psrl = Get-PSReadLineVersion
	if ($psrl -ge [Version]'2.2.0') {
		Set-PSReadLineKeyHandler -Chord $Chord -ScriptBlock {
			Switch-SudoCommand
		} -Description 'SudoEscHandler' -BriefDescription 'SudoEsc'
	} else {
		# Legacy fallback only supports double-ESC reliably
		Set-PSReadLineKeyHandler -Key 'Escape' -ScriptBlock {
			$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			if ($key.VirtualKeyCode -eq 27) { Switch-SudoCommand }
			else { [Microsoft.PowerShell.PSConsoleReadLine]::Insert([char]27 + $key.Character) }
		} -Description 'SudoEscHandler'
	}

	if (-not $Quiet) { Write-Host ("SudoEsc enabled (Chord: {0})" -f $Chord) -ForegroundColor Green }
}

function Disable-SudoEsc {
	[CmdletBinding()]
	param([switch]$Quiet)
	if (-not (Test-PSReadLineAvailable)) { return }
	Remove-ExistingSudoBindings
	if (-not $Quiet) { Write-Host "SudoEsc disabled." -ForegroundColor Yellow }
}

Export-ModuleMember -Function Enable-SudoEsc, Disable-SudoEsc, SudoEscUpdate, Add-SudoEscToProfile
