@{
	RootModule        = 'SudoEsc.psm1'
	ModuleVersion     = '1.0.7'
	GUID              = '11104456-8ce9-4742-ae8c-51e75fef4607'
	Author            = 'Re•MART'
	Description       = 'Adds functionality to prepend sudo to the last command by double-pressing Esc'
	PowerShellVersion = '5.1'
	FileList          = @('readme.md', 'SudoEsc.psm1')
	FunctionsToExport = @('Enable-SudoEsc', 'Disable-SudoEsc', 'SudoEscUpdate', 'Add-SudoEscToProfile')
	PrivateData       = @{
		PSData = @{
			Tags         = @('sudo', 'gsudo', 'esc', 'keyboard', 'shortcut')
			License      = 'https://opensource.org/licenses/MIT'
			ProjectUri   = 'https://github.com/Ranamzes/PowerShell_SudoEsc'
			ReleaseNotes = 'Clean profile'
		}
	}
}
