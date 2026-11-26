# AutomateJoy — lokalny launcher n8n


[English](README.md)
Ten fork AutomateJoy uruchamia n8n na komputerze użytkownika i udostępnia edytor pod [http://127.0.0.1:5678](http://127.0.0.1:5678). Zamiast instalatora z wbudowanym Electronem używa skryptów startowych i przeglądarki użytkownika. Pierwszy start pobiera oficjalny Node.js **24.22.3** oraz instaluje **n8n 2.49.7** z npm.

| System | Architektura | Start |
|---|---|---|
| Windows 10/11 | x64 | `Start.cmd` |
| macOS | Apple Silicon i Intel | `./start.sh` |
| Linux z glibc | x64 i ARM64 | `./start.sh` |

## Pierwsze uruchomienie

1. Sklonuj repozytorium lub pobierz ZIP i go rozpakuj.
2. Na Windows uruchom `Start.cmd`. Na macOS i Linux otwórz terminal w katalogu projektu i uruchom `sh ./start.sh`. Wymagane są dostęp do Internetu oraz standardowe narzędzia systemowe. Na macOS i Linux skrypt używa m.in. `curl`, `tar` i `sha256sum` lub `shasum`.
3. Otwórz [edytor](http://127.0.0.1:5678) i utwórz konto właściciela. Na Windows launcher próbuje otworzyć przeglądarkę automatycznie po starcie n8n.
4. Zatrzymaj n8n przez **Ctrl+C** przed wykonaniem kopii danych. Workflow działają tak długo, jak działa proces n8n.

Na Windows obowiązuje lokalna polityka wykonywania skryptów PowerShell. Jeżeli pobrany ZIP oznaczył skrypt jako plik z Internetu, sprawdź źródło i odblokuj `Start.ps1` we właściwościach pliku, o ile pozwala na to polityka urządzenia.

Do przygotowania runtime bez uruchamiania edytora użyj `powershell.exe -NoProfile -File .\Start.ps1 -SetupOnly` na Windows lub `sh ./start.sh --setup-only` na macOS i Linux. Windows obsługuje również `Start.ps1 -NoBrowser`.

## Dane i połączenia

| System | Katalog profilu |
|---|---|
| Windows | `%LOCALAPPDATA%\n8n-local-windows\profile\.n8n` |
| macOS | `~/Library/Application Support/AutomateJoy/profile/.n8n` |
| Linux | `${XDG_DATA_HOME:-~/.local/share}/automatejoy/profile/.n8n` |

Kopiuj cały katalog profilu, w tym bazę i konfigurację z kluczem szyfrowania. Launcher tworzy osobny profil. Dane z instalacji AutomateJoy v1.0.67 wymagają własnej procedury migracji.

Edytor nasłuchuje lokalnie. Launcher wyłącza diagnostykę n8n i sam nie wysyła telemetrii. Instalacja korzysta z Node.js i npm, a uruchamiane workflow mogą łączyć się z usługami, które skonfigurujesz.

## Pochodzenie i zmiany

[DIFF.pl.md](DIFF.pl.md) opisuje pochodzenie kodu, porównanie z AutomateJoy v1.0.67, ograniczenia i sposób sprawdzenia zakresu zmian. [Oryginalne wprowadzenie](https://github.com/newcl/AutomateJoy-Release/blob/v1.0.67/README.md) jest dostępne w tagu upstreamu. n8n podlega [własnej licencji](https://docs.n8n.io/sustainable-use-license/).
