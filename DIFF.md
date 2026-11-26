# Zmiany względem AutomateJoy v1.0.67

## Punkt odniesienia

- [Publiczne repozytorium upstream](https://github.com/newcl/AutomateJoy-Release/tree/v1.0.67) zachowuje tag `v1.0.67` i commit `a39318194f36ebbd2edac777b386c7c196df5e29`.
- [Oficjalne wydanie v1.0.67](https://github.com/newcl/AutomateJoy-Release/releases/tag/v1.0.67) udostępnia [instalator Windows x64](https://github.com/newcl/AutomateJoy-Release/releases/download/v1.0.67/AutomateJoy.Setup.1.0.67.exe). SHA-256 sprawdzonego pliku: `dfb436096a85e320ea68f495b885faa82e28abc54402831bd5613ba2825a62af`.
- Publiczny tag zawiera `.gitignore`, `LICENSE` i `README.md`. Ustalenia o oryginalnej aplikacji pochodzą z analizy statycznej instalatora Windows x64, jego metadanych, `resources/app.asar` i manifestu paczki n8n.
- Wersja po zmianach to samodzielna implementacja launchera na Windows, macOS i Linux. Poniżej znajduje się porównanie funkcji i zabezpieczeń. Utworzenie diffu kodu względem źródeł użytych do produkcyjnej kompilacji AutomateJoy wymagałoby dostępu do tych źródeł.

## Różnice

| Obszar | Oryginał v1.0.67 | Ten fork |
|---|---|---|
| Uruchamianie | Instalator NSIS i aplikacja Electron 27.3.11 z Chromium 118. Renderer ma wyłączony sandbox. | `Start.cmd` i `Start.ps1` na Windows, `start.sh` na macOS i Linux. Edytor działa w przeglądarce użytkownika. Bez zależności od Electron i jego wbudowanego Chromium. |
| Wersje | n8n 2.43.7 i Node.js 24.4.0 w instalatorze. | n8n 2.49.7 i Node.js 24.22.3. Numery wersji są zapisane w `Start.ps1`. |
| Dystrybucja | Gotowy instalator EXE bez podpisu Authenticode. Instalator zawiera runtime i sprawdza sumę archiwum n8n. | Skrypty pobierają oficjalne archiwum Node.js i sprawdzają jego przypiętą sumę SHA-256. npm instaluje przypiętą wersję n8n; zależności przechodnie są rozwiązywane przy instalacji. Pierwszy start wymaga Internetu. |
| Telemetria | Telemetria n8n wyłączona. Telemetria launchera jest domyślnie włączona i wysyła m.in. identyfikator instalacji oraz flagi użycia do serwera wydawcy. | Telemetria n8n wyłączona. Launcher nie ma własnego mechanizmu telemetrii. Workflow mogą łączyć się z usługami skonfigurowanymi przez użytkownika. |
| Dostęp do edytora | `127.0.0.1:5678`, z wyłączonym wymogiem Secure dla ciasteczka na lokalnym HTTP. | Ten sam nasłuch i ustawienie ciasteczka. |
| Profil użytkownika | Katalog danych launchera i automatyczna kopia lokalnych danych przed aktualizacją n8n. | Oddzielny profil w `%LOCALAPPDATA%\n8n-local-windows\profile\.n8n`. Na macOS i Linux ścieżki opisuje README. Kopię wykonuje użytkownik po zatrzymaniu n8n. Brak automatycznej migracji profilu AutomateJoy. |
| Funkcje launchera | Graficzny status startu, przyciski restartu oraz otwierania folderu danych i logu. | Konsola z logiem procesu, na Windows otwarcie przeglądarki po sprawdzeniu gotowości, opcje `-SetupOnly` i `-NoBrowser`. Zatrzymanie przez Ctrl+C. |

## Zmiany plików w Git

- `README.md` zawiera wprowadzenie, instrukcję startu i lokalizację danych. Oryginalny README pozostaje w historii Git pod tagiem `v1.0.67`.
- `Start.cmd` i `Start.ps1` obsługują Windows x64. `start.sh` obsługuje macOS i Linux na x64 oraz ARM64.
- `DIFF.md` dokumentuje porównanie instalatora z nowym launcherem.

Zmiany w plikach repozytorium można przejrzeć przez `git diff v1.0.67..main` lub w [porównaniu GitHub](https://github.com/grzechotnik777/AutomateJoy-Release/compare/v1.0.67...main).
