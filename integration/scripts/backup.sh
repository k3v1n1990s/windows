#!/usr/bin/env bash
set -euo pipefail
umask 077
# Run as the desktop user; use individually authorized Docker commands first.
base=$(cd "$(dirname "$0")/../../.." && pwd)
stage="$base/recovery/staging"
out="$base/recovery/output"
key="$base/recovery/recovery.key"
mkdir -p "$stage/private" "$out"
[[ -f "$key" ]] || python3 -c 'import secrets; print(secrets.token_urlsafe(48))' > "$key"
chmod 600 "$key"
[[ -f "$stage/image.tar" ]] || { echo 'Export Docker image to recovery/staging/image.tar first'; exit 1; }
[[ -f "$stage/windows.bundle" && -f "$stage/winapps.bundle" ]] || { echo 'Create offline Git bundles first'; exit 1; }
cp "$base/windows/integration/.env" "$stage/private/windows.env"
cp "$HOME/.config/winapps/mir-game-account.json" "$stage/private/game-account.json"
docker_cmd=(docker)
[[ ${DOCKER_AUTH:-} != pkexec ]] || docker_cmd=(pkexec docker)
state=$("${docker_cmd[@]}" inspect -f '{{.State.Status}}' WinApps-Mir)
[[ "$state" == exited ]] || { echo 'Stop WinApps-Mir normally before backup'; exit 1; }
tar --sparse -C "$base" -cf - runtime/storage runtime/shared recovery/staging |
 zstd -T2 -3 | gpg --batch --yes --pinentry-mode loopback --passphrase-file "$key" --symmetric --cipher-algo AES256 --compress-algo none --output "$out/winapps-mir.tar.zst.gpg"
(cd "$out" && sha256sum winapps-mir.tar.zst.gpg > SHA256SUMS)
echo 'Encrypted backup complete. Keep recovery.key separately from the public repository.'
