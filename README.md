# AutomateJoy Hardened

[Polski](README.pl.md) · [Changes from AutomateJoy v1.0.67](DIFF.md)

AutomateJoy Hardened runs n8n on your computer and serves the editor at [http://127.0.0.1:5678](http://127.0.0.1:5678). It replaces the Electron launcher with startup scripts and uses your default browser. On the first run, the launcher downloads **Node.js 24.22.3**, verifies the package checksum, and installs **n8n 2.49.7** from npm.

## Changes made after the audit

- **Outdated n8n and Node.js.** Updated the bundled versions from n8n 2.43.7 and Node.js 24.4.0 to n8n 2.49.7 and Node.js 24.22.3. The n8n update includes the fix for [GHSA-w6f8-8qh4-h3j4](https://github.com/n8n-io/n8n/security/advisories/GHSA-w6f8-8qh4-h3j4).
- **Unsupported Electron and disabled renderer sandbox.** Removed the Electron dependency. The editor opens in the system browser.
- **Launcher telemetry enabled by default.** The new launcher has no telemetry code. The editor still binds to `127.0.0.1`.
- **Unsigned Windows installer.** This fork runs from source scripts and verifies the downloaded Node.js archive against a pinned SHA-256.

[Audit findings, changes and verification](DIFF.md#changes-traced-to-the-audit)

| Operating system | Architecture | How to start |
|---|---|---|
| Windows 10/11 | x64 | Double-click `Start.cmd` |
| macOS | Apple Silicon and Intel | Run `sh ./start.sh` |
| Linux with glibc | x64 and ARM64 | Run `sh ./start.sh` |

## First run

1. Clone this repository or download and extract its ZIP.
2. Run the launcher for your operating system. The first run requires internet access. On macOS and Linux, the script uses standard system tools including `curl`, `tar`, and either `sha256sum` or `shasum`.
3. Open the [local editor](http://127.0.0.1:5678) and create the owner account. On Windows, the launcher attempts to open the browser once n8n is ready.
4. Press **Ctrl+C** in the launcher console or terminal to stop n8n. Workflows run while the n8n process is running.

The Windows launcher follows your local PowerShell execution policy. If Windows marks `Start.ps1` as downloaded from the internet, verify its source before unblocking it in file properties, where your device policy permits.

To install the runtime without starting the editor, use `powershell.exe -NoProfile -File .\Start.ps1 -SetupOnly` on Windows or `sh ./start.sh --setup-only` on macOS and Linux. To skip opening the browser on Windows, pass `-NoBrowser` to `Start.ps1`.

## Data and connectivity

| Operating system | Profile directory |
|---|---|
| Windows | `%LOCALAPPDATA%\n8n-local-windows\profile\.n8n` |
| macOS | `~/Library/Application Support/AutomateJoy/profile/.n8n` |
| Linux | `automatejoy/profile/.n8n` under `$XDG_DATA_HOME`, which defaults to `~/.local/share` |

Stop n8n before backing up the entire profile, including its database and the configuration that contains the encryption key. The launcher creates a separate profile. Moving data from an existing AutomateJoy v1.0.67 installation requires a separate migration.

The editor listens on the loopback interface. The launcher disables n8n diagnostics and sends no telemetry of its own. Setup connects to Node.js and npm. Workflows can connect to the services you configure.

## Upstream and licensing

See [DIFF.md](DIFF.md) for the comparison, scope, and Git diff. The [original README](https://github.com/newcl/AutomateJoy-Release/blob/v1.0.67/README.md) remains available at the upstream tag. See [LICENSE](LICENSE) for this repository and the [n8n license](https://docs.n8n.io/sustainable-use-license/) for n8n.
