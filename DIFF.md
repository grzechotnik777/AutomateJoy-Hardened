# Changes from AutomateJoy v1.0.67

[Polski](DIFF.pl.md) · [Project README](README.md)

## Baseline

The fork retains the history of [newcl/AutomateJoy-Release](https://github.com/newcl/AutomateJoy-Release). Tag `v1.0.67` points to commit `a39318194f36ebbd2edac777b386c7c196df5e29`. The public tag contains `.gitignore`, `LICENSE`, and `README.md`. The new launcher was implemented independently. Findings about the original launcher come from static analysis of its Windows x64 installer, packaged Electron application, and n8n package metadata. The original macOS installers were outside that audit.

[Official release](https://github.com/newcl/AutomateJoy-Release/releases/tag/v1.0.67) · [Original Windows x64 installer](https://github.com/newcl/AutomateJoy-Release/releases/download/v1.0.67/AutomateJoy.Setup.1.0.67.exe)

Verified SHA-256 of the original installer

`dfb436096a85e320ea68f495b885faa82e28abc54402831bd5613ba2825a62af`

## Functional differences

| Area | Original Windows x64 installer | This fork |
|---|---|---|
| Launcher | NSIS installer and Electron 27.3.11 with Chromium 118. Electron's renderer sandbox is disabled. | CMD and PowerShell on Windows, POSIX shell on macOS and Linux. Uses the system browser and has no Electron dependency. |
| Runtime | Bundles Node.js 24.4.0 and n8n 2.43.7. | Installs Node.js 24.22.3 and n8n 2.49.7 on first run. |
| Package integrity | The Windows installer lacks an Authenticode signature and checks the checksum of its bundled n8n archive. | The launcher verifies the official Node.js archive against a pinned SHA-256. npm installs a pinned n8n version and resolves transitive dependencies during setup. |
| Telemetry | n8n diagnostics are disabled. Launcher telemetry is enabled by default and reports an installation ID and usage flags, among other metadata. | n8n diagnostics are disabled. The launcher sends no telemetry. |
| Network binding | Listens on `127.0.0.1:5678` and disables the Secure cookie requirement for local HTTP. | Uses the same listener and cookie setting. |
| Profile and backups | Uses the application data directory and backs up local n8n data before upgrades. | Uses a separate profile. Backups and migration from AutomateJoy are manual. |
| Controls | GUI startup status, restart button, and shortcuts to data and logs. | Console output and a setup-only mode. Windows also opens the editor automatically unless `-NoBrowser` is set. Stop with Ctrl+C. |

## Review the Git changes

`README.md` introduces the fork and explains setup and data storage. `Start.cmd` and `Start.ps1` handle Windows. `start.sh` handles macOS and Linux. The primary documentation is in English, with Polish editions linked at the top.

Run `git diff v1.0.67..main` locally or open [Compare on GitHub](https://github.com/grzechotnik777/AutomateJoy-Release/compare/v1.0.67...main). That diff compares files in the public Git repository. The table above compares behavior against the shipped Windows installer.
