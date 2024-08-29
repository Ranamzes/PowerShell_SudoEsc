![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/SudoEsc)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/SudoEsc)

# SudoEsc

SudoEsc is a PowerShell module that allows you to quickly prepend 'sudo' to your last command by double-pressing the Escape key. This is particularly useful for Windows users who frequently need to elevate their commands using gsudo or similar tools.

## Features

- Double-press Escape to prepend 'sudo' to the last command
- Easy to enable and disable
- Automatic update checks

## Installation

You can install SudoEsc directly from the PowerShell Gallery:

```powershell
Install-Module -Name SudoEsc -Scope CurrentUser
```
## Compatibility

SudoEsc is designed to work with Windows PowerShell and PowerShell Core on Windows systems.

> **IMPORTANT**: For SudoEsc to function correctly, you must have a sudo-equivalent tool installed and available in your system path. We recommend using [gsudo](https://github.com/gerardog/gsudo), a sudo equivalent for Windows.

To install gsudo, you can use the following command in PowerShell:

```powershell
winget install gerardog.gsudo
```

## Usage

1. Import the module:
   ```powershell
   Import-Module SudoEsc
   ```

2. Enable the SudoEsc functionality:
   ```powershell
   Enable-SudoEsc
   ```

3. Use your PowerShell session as normal. When you need to elevate a command, simply double-press the Escape key. For example:
   ```powershell
   Get-Content C:\Windows\System32\drivers\etc\hosts
   # Double-press Esc
   sudo Get-Content C:\Windows\System32\drivers\etc\hosts

4. If you didn't choose to add SudoEsc to your profile during the initial setup, you can do it later by running:
   ```powershell
   Add-SudoEscToProfile
   ```

5. To disable the functionality:
   ```powershell
   Disable-SudoEsc
   ```

## How It Works

When enabled, SudoEsc sets up a key handler for the Escape key. If you press Escape twice within 300 milliseconds, it will take your last command (either from the current line or from history), prepend 'sudo' to it, and execute it.

## Updates

SudoEsc will automatically check for updates when the module is imported. You can update the module using:

```powershell
Update-Module SudoEsc
```

## Requirements
- PowerShell 5.1 or later
- Windows PowerShell or PowerShell Core
- gsudo or similar sudo-equivalent tool for Windows

## Troubleshooting

If you encounter any issues:
1. Ensure you have the latest version of SudoEsc installed.
2. Check that gsudo or your preferred sudo-equivalent tool is installed and available in your system path.
3. If the double-Esc doesn't work, try disabling and re-enabling the functionality:
   ```powershell
   Disable-SudoEsc
   Enable-SudoEsc

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
Here's how you can contribute:
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the sudo plugin for Oh My Zsh
- Thanks to all contributors and users of SudoEsc
