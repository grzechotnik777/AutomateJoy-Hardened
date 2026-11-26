#!/bin/sh
set -eu

node_version=24.22.3
n8n_version=2.49.7
editor=http://127.0.0.1:5678
setup_only=false
case "${1:-}" in
    '') ;;
    --setup-only) setup_only=true ;;
    *) printf 'Usage: %s [--setup-only]\n' "$0" >&2; exit 2 ;;
esac

case "$(uname -s):$(uname -m)" in
    Darwin:arm64)
        platform=darwin-arm64
        checksum=ff6e17d4874b76d272212b908cc020d6e815fba5a6c7eaaa06add725840307fd ;;
    Darwin:x86_64)
        platform=darwin-x64
        checksum=977614af0504c81045e7fd85596dbca0e5f951b96681516dadafedcca8c447f7 ;;
    Linux:aarch64|Linux:arm64)
        platform=linux-arm64
        checksum=261af2af250dfd7e9f25cf151d1b2713a0adf8f10a9ad116c4947f68627affe8 ;;
    Linux:x86_64)
        platform=linux-x64
        checksum=061ec3e3062115705b56b51fa9cc330ab50d34b6969387d4e4b1a50c6809acc2 ;;
    *)
        printf 'Unsupported OS or architecture.\n' >&2; exit 1 ;;
esac

case "$platform" in
    darwin-*) root="$HOME/Library/Application Support/AutomateJoy" ;;
    linux-*) root="${XDG_DATA_HOME:-$HOME/.local/share}/automatejoy" ;;
esac

umask 077
runtime="$root/runtime-$platform-$node_version-$n8n_version"
lock="$root/launcher.lock"
staging=
child=
mkdir -p "$root"
if ! mkdir "$lock"; then
    printf 'Profile locked at %s. Remove the lock directory only after checking that the launcher and n8n are stopped.\n' "$lock" >&2
    exit 1
fi

cleanup() {
    if [ -n "$staging" ]; then rm -rf "$staging"; fi
    rmdir "$lock"
}

stop() {
    if [ -n "$child" ]; then
        kill -TERM "$child" 2>/dev/null || :
        wait "$child" || :
    fi
    exit "$1"
}

trap cleanup EXIT
trap 'stop 130' INT
trap 'stop 143' TERM
trap 'stop 129' HUP

entry=node_modules/n8n/bin/n8n
if [ ! -x "$runtime/node/bin/node" ] || [ ! -f "$runtime/$entry" ]; then
    if [ -e "$runtime" ]; then
        printf 'Incomplete runtime at %s. Rename it before retrying.\n' "$runtime" >&2
        exit 1
    fi
    staging=$(mktemp -d "$root/runtime.installing.XXXXXXXX")
    archive="node-v$node_version-$platform.tar.gz"
    printf 'Downloading Node.js %s...\n' "$node_version"
    curl -fLsS --retry 2 --connect-timeout 15 -o "$staging/$archive" \
        "https://nodejs.org/dist/v$node_version/$archive"
    if command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum < "$staging/$archive")
    else
        actual=$(shasum -a 256 < "$staging/$archive")
    fi
    if [ "${actual%% *}" != "$checksum" ]; then
        printf 'Node.js checksum mismatch.\n' >&2
        exit 1
    fi
    tar -xzf "$staging/$archive" -C "$staging"
    mv "$staging/${archive%.tar.gz}" "$staging/node"
    rm "$staging/$archive"

    printf 'Installing n8n %s from npm...\n' "$n8n_version"
    (
        cd "$staging"
        PATH="$staging/node/bin:$PATH" ./node/bin/npm install \
            --registry=https://registry.npmjs.org --no-audit --no-fund "n8n@$n8n_version"
        ./node/bin/node -e \
            'if (require("./node_modules/n8n/package.json").version !== process.argv[1]) process.exit(1)' "$n8n_version"
        test -f "$entry"
    )
    mv "$staging" "$runtime"
    staging=
fi

if "$setup_only"; then exit 0; fi

export PATH="$runtime/node/bin:$PATH"
export N8N_USER_FOLDER="$root/profile"
export N8N_LISTEN_ADDRESS=127.0.0.1 N8N_HOST=127.0.0.1 N8N_PORT=5678 N8N_PROTOCOL=http
export N8N_EDITOR_BASE_URL="$editor" WEBHOOK_URL="$editor/" N8N_SECURE_COOKIE=false
export N8N_DIAGNOSTICS_ENABLED=false N8N_VERSION_NOTIFICATIONS_ENABLED=false
export N8N_TEMPLATES_ENABLED=false N8N_PERSONALIZATION_ENABLED=false
mkdir -p "$N8N_USER_FOLDER"

printf 'n8n editor: %s (Ctrl+C to stop)\n' "$editor"
"$runtime/node/bin/node" "$runtime/$entry" start &
child=$!
wait "$child"
