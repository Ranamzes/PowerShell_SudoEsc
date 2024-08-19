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

## Usage

1. Import the module:
   ```powershell
   Import-Module SudoEsc
   ```

2. Enable the SudoEsc functionality:
   ```powershell
   Enable-SudoEsc
   ```

3. Use your PowerShell session as normal. When you need to elevate a command, simply double-press the Escape key.

4. To disable the functionality:
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the sudo plugin for Oh My Zsh
- Thanks to all contributors and users of SudoEsc
