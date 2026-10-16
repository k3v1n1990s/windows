# WinApps + patched QEMU Windows lab

QEMU 10.2.2 source is checksum pinned. Patch is copied unmodified from zhaodice/qemu-anti-detection commit 2750c86d2d045243ba6617951487e41b25c05557.
The unmodified patch changes VirtIO PCI vendor IDs. This lab therefore uses SATA storage, e1000 networking and standard VGA so stock Windows drivers remain usable. Guest-agent availability is not assumed.

This build replaces the QEMU binary **inside** dockur/windows; it does not modify host QEMU or the host kernel. Run-time guest compatibility still requires testing; the patch is not a guarantee against VM detection.

## Build

Run from the repository root. Pin BASE_IMAGE to a tested digest before publishing/reproducing a deployment.

```sh
docker build --progress=plain -f integration/Dockerfile -t local/windows-zhaodice:10.2.2 .
```

## Run

Create integration/.env with WINDOWS_PASSWORD (random nonempty password); chmod 600. Never commit it.
Place the selected launcher in `../runtime/shared/launcher.exe` (relative to repo root). Persist Windows under `../runtime/storage/` on local SSD, never Google Drive.

```sh
docker compose --env-file integration/.env -f integration/compose.yaml up -d
docker logs -f WinApps-Mir
```

VNC: http://127.0.0.1:8006 ; RDP: 127.0.0.1:3389. Ports bind to loopback only. Only the dedicated exchange folder is shared; host home, Docker socket and Google Drive are not exposed to the guest. The optional OEM hook configures RemoteApp and launches the selected client after first login. It does not disable Defender.

## WinApps

Use the upstream winapps-org/winapps client with `WAFLAVOR="manual"`, RDP_IP="127.0.0.1", RDP_USER="Agent", RDP_PORT="3389", and the generated password. Manual backend intentionally avoids granting the desktop user Docker socket access. Start/stop the container separately with an individually authorized Docker command.

Use only a dedicated file redirection folder in RDP_FLAGS; omit +home-drive. A full RDP desktop and the web console remain available if RemoteApp is incompatible with the launcher.

## Verification

Check patched QEMU version and binary SHA-256, actual QEMU process arguments, successful Windows boot, RDP authentication, then the launcher window and screenshot. A running container alone is not success. Separate launcher-visible, server-list-loaded and in-game statuses. No login account, purchases or recharge are required for the launcher test.

Configure the local client after Windows completes first login (requires FreeRDP 3, `dialog`, and `openbsd-netcat`). The OEM helper resolves installers that relocate themselves and writes `runtime/shared/evidence/launcher-target.txt`; the client helper reads that path. An explicit `--launcher-path` overrides it:

```sh
python3 integration/scripts/configure-client.py --winapps ../winapps --runtime ../runtime
winapps-mir windows   # Full Windows desktop
mir-launcher          # Launcher through RemoteApp
```

The client remains the upstream WinApps script; desktop entries select a specific executable rather than scanning the whole host home folder. Existing WinApps configuration is backed up by the helper.

WinApps registry files are copied from winapps-org/winapps under its MIT license (see WINAPPS-LICENSE.md).

## Recovery

For reinstall/offline recovery, read [RECOVERY.md](RECOVERY.md). Encrypted backups include private credentials; never commit backup files or recovery keys.
