# Validation — 2026-10-16 (Asia/Shanghai)

## Result

The selected Pangu/Mir launcher was displayed as a native Linux RemoteApp window using upstream WinApps and the patched-QEMU Windows container. Its server list loaded. No account registration, recharge, login or in-game test was performed. This does not establish compatibility with other launchers, kernel anti-cheat or future server updates.

## Provenance

- Windows container source: dockur/windows 013ea27498e0e820a46b3861a0fa047d5b19d846 (v6.06).
- Base image: ghcr.io/dockur/windows@sha256:16fd7c39a3e48bb946d29c59dc6015942e5b900a1fa5d7e5552053bfc48ee2ea.
- QEMU: 10.2.2; source and patch checksums in Dockerfile.
- Patch source: zhaodice/qemu-anti-detection 2750c86d2d045243ba6617951487e41b25c05557; unmodified patch.
- WinApps source: 42c7e8318280c6fc3426c7afebfc7f43b895f4c8, manual backend.
- Local image: local/windows-zhaodice:10.2.2.
- Local image identity: sha256:b97697936852b486b9d7fa29f97a6cdc5001e67d3dfa9fca9d2489412669dab1.
- Compiled QEMU binary SHA-256: 16854b6c755b535e31276dda2afb6e86b032a0c3750974fccfc7d4ed9eee341c.
- Windows: Windows 10 Pro Chinese, build 19045, 4 vCPUs, 6 GiB RAM, 80 GiB sparse local disk.
- Launcher provenance and SHA-256: launcher-source.json. No launcher binary or Windows media is committed.

## Checks completed

- QEMU patch applied with `git apply --check`; QEMU compiled and final binary executed as version 10.2.2. No missing dynamic libraries.
- Docker Compose configuration validated. Runtime log reports QEMU v10.2.2 and actual process uses SATA, e1000, standard VGA and the configured CPU profile.
- Windows installed successfully using a temporary stock image, then shut down normally and restarted using the patched image with the same persistent disk.
- RDP session and RemoteApp execution verified through actual app windows, not just the auth-only return code.
- Hyprland reported a RAIL window titled `盘古复古[1011]`; a screenshot shows the launcher and populated server list.
- Guest Defender status reported AMServiceEnabled, AntivirusEnabled and RealTimeProtectionEnabled all true. No exclusions or security-disable changes were made by the integration.
- The launcher relocates its original download to a game directory. The configured executable was resolved from the installed desktop shortcut/files. Windows paths containing square brackets require LiteralPath during discovery.
- The final client configuration helper ran successfully against this deployment, preserved configuration permissions (600), and generated the correct launcher command.

## Local artifacts

`../runtime/evidence/` (relative to repository root) contains build.log, image-identity.txt, patched-runtime.log and remoteapp-window.png. Guest diagnostics and baseline screenshots are under `../runtime/shared/evidence/`. They are intentionally outside the repository.

Windows storage is local SSD, not Google Drive. RDP and web console bind to loopback. Only a dedicated exchange directory is shared. Docker is managed through individually authorized commands; the desktop user was not added to the Docker group and no socket ACL was relaxed.

## Daily use

- App menu: Mir Launcher (Windows), or run `mir-launcher`.
- Full desktop: `winapps-mir windows`.
- Web console: http://127.0.0.1:8006/.
- The manual backend expects the container to be running. To start it, use the Compose command in README with appropriate local Docker authorization.
- Do not run the bootstrap override after validation: it selects the temporary stock image. The committed compose.yaml selects the patched image.
