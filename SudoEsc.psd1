@{
	RootModule        = 'SudoEsc.psm1'
	ModuleVersion     = '1.0.0'
	GUID              = 'bf9d1850-6a94-4a03-9d0f-1847208c38ff'
	Author            = 'Re•MART'
	Description       = 'Adds functionality to prepend sudo to the last command by double-pressing Esc'
	PowerShellVersion = '5.1'
	FunctionsToExport = @('Enable-SudoEsc', 'Disable-SudoEsc', 'Get-SudoEscUpdate')
	PrivateData       = @{
		PSData = @{
			Tags         = @('sudo', 'gsudo', 'esc', 'keyboard', 'shortcut')
			LicenseUri   = 'https://opensource.org/licenses/MIT'
			ProjectUri   = 'https://github.com/Ranamzes/PowerShell_SudoEsc'
			ReleaseNotes = 'Initial release of SudoEsc module.'
		}
	}
}
