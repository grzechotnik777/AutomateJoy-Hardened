param([switch]$SetupOnly, [switch]$NoBrowser)

$ErrorActionPreference = 'Stop'
$nodeVersion = '24.22.3'
$n8nVersion = '2.49.7'
$nodeHash = 'e612af99f626ab415ea225af6bce5c971feb448cb5cae250bb1c3fa50c5f7d9f'
$root = Join-Path $env:LOCALAPPDATA 'n8n-local-windows'
$runtime = Join-Path $root "runtime-$nodeVersion-$n8nVersion"
$staging = "$runtime.installing"
$node = Join-Path $runtime 'node\node.exe'
$entry = Join-Path $runtime 'node_modules\n8n\bin\n8n'
$editor = 'http://127.0.0.1:5678'

if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64' -and $env:PROCESSOR_ARCHITEW6432 -ne 'AMD64') {
    throw 'This launcher requires Windows x64.'
}

[void][IO.Directory]::CreateDirectory($root)
try {
    $lock = [IO.File]::Open((Join-Path $root 'launcher.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
} catch [IO.IOException] {
    throw 'Another instance of the launcher already has this profile open.'
}

$browserJob = $null
try {
    if (!(Test-Path -LiteralPath $node) -or !(Test-Path -LiteralPath $entry)) {
        if (Test-Path -LiteralPath $runtime) {
            throw "Incomplete runtime at $runtime. Close n8n and rename that runtime folder before retrying."
        }
        if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
        [void][IO.Directory]::CreateDirectory($staging)
        try {
            $nodeFolder = "node-v$nodeVersion-win-x64"
            $archive = Join-Path $staging "$nodeFolder.zip"
            Write-Host "Downloading Node.js $nodeVersion..."
            Invoke-WebRequest -UseBasicParsing -Uri "https://nodejs.org/dist/v$nodeVersion/$nodeFolder.zip" -OutFile $archive
            if ((Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash -ne $nodeHash) {
                throw 'Node.js checksum mismatch.'
            }
            Expand-Archive -LiteralPath $archive -DestinationPath $staging
            Rename-Item -LiteralPath (Join-Path $staging $nodeFolder) -NewName 'node'
            Remove-Item -LiteralPath $archive
            $env:Path = (Join-Path $staging 'node') + ';' + $env:Path
            Write-Host "Installing n8n $n8nVersion from npm..."
            Push-Location -LiteralPath $staging
            try {
                & .\node\npm.cmd install --registry=https://registry.npmjs.org --no-audit --no-fund "n8n@$n8nVersion"
                if ($LASTEXITCODE -ne 0) { throw "npm install failed with code $LASTEXITCODE." }
                $manifest = Get-Content -LiteralPath 'node_modules\n8n\package.json' -Raw | ConvertFrom-Json
                if ($manifest.version -ne $n8nVersion -or !(Test-Path -LiteralPath 'node_modules\n8n\bin\n8n')) {
                    throw 'Unexpected n8n version or missing entry point.'
                }
            } finally { Pop-Location }
            Move-Item -LiteralPath $staging -Destination $runtime
        } finally {
            if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
        }
    }

    if ($SetupOnly) { return }
    if (Get-NetTCPConnection -State Listen -LocalPort 5678 -ErrorAction SilentlyContinue) {
        throw 'TCP port 5678 is already in use.'
    }

    $env:Path = (Join-Path $runtime 'node') + ';' + $env:Path
    $env:N8N_USER_FOLDER = Join-Path $root 'profile'
    [void][IO.Directory]::CreateDirectory($env:N8N_USER_FOLDER)
    $env:N8N_LISTEN_ADDRESS = '127.0.0.1'
    $env:N8N_HOST = '127.0.0.1'
    $env:N8N_PORT = '5678'
    $env:N8N_PROTOCOL = 'http'
    $env:N8N_EDITOR_BASE_URL = $editor
    $env:WEBHOOK_URL = "$editor/"
    $env:N8N_SECURE_COOKIE = 'false'
    $env:N8N_DIAGNOSTICS_ENABLED = 'false'
    $env:N8N_VERSION_NOTIFICATIONS_ENABLED = 'false'
    $env:N8N_TEMPLATES_ENABLED = 'false'
    $env:N8N_PERSONALIZATION_ENABLED = 'false'

    if (!$NoBrowser) {
        $browserJob = Start-Job -ArgumentList $editor -ScriptBlock {
            param($url)
            $deadline = (Get-Date).AddMinutes(5)
            while ((Get-Date) -lt $deadline) {
                try {
                    $response = Invoke-WebRequest -UseBasicParsing -Uri "$url/healthz/readiness" -TimeoutSec 2
                    if ($response.StatusCode -eq 200) { Start-Process $url; return }
                } catch {
                    Start-Sleep -Seconds 2
                }
            }
        }
    }

    Write-Host "n8n editor: $editor (Ctrl+C to stop)"
    & $node $entry start
    if ($LASTEXITCODE -ne 0) { throw "n8n exited with code $LASTEXITCODE." }
} finally {
    if ($browserJob) { Remove-Job -Job $browserJob -Force }
    $lock.Dispose()
}
