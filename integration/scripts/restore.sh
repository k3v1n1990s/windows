#!/usr/bin/env bash
set -euo pipefail
umask 077
if [[ $# != 3 ]]; then echo 'Usage: restore.sh BACKUP_DIR KEY_FILE NEW_EMPTY_LOCAL_DIRECTORY'; exit 2; fi
backup=$(realpath "$1"); key=$(realpath "$2"); dest=$(realpath -m "$3")
[[ ! -e "$dest" ]] || { echo 'Destination must not exist; existing deployments are never overwritten'; exit 1; }
(cd "$backup" && sha256sum -c SHA256SUMS)
mkdir -m 700 -p "$dest"
gpg --batch --pinentry-mode loopback --passphrase-file "$key" --decrypt "$backup/winapps-mir.tar.zst.gpg" | zstd -d | tar --sparse -xf - -C "$dest"
git clone "$dest/recovery/staging/windows.bundle" "$dest/windows"
git -C "$dest/windows" checkout feat/winapps-zhaodice-mir
git clone "$dest/recovery/staging/winapps.bundle" "$dest/winapps"
cp "$dest/recovery/staging/private/windows.env" "$dest/windows/integration/.env"
chmod 600 "$dest/windows/integration/.env"
echo 'Extraction complete. Read windows/integration/RECOVERY.md before loading the image or starting Windows.'
