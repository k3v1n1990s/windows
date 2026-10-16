# Windows lab maintenance

Work only in this fork branch. Keep passwords, .env, Windows disks, downloaded launchers and screenshots out of git. The bootstrap stock image is temporary; success requires the final patched QEMU image actually booted and the launcher visible. Preserve the upstream patch verbatim and record its commit/hash. Never run the game launcher on the Linux host. Keep host home, Docker socket and cloud drive out of Windows shares. Do not disable guest security software or change host kernel merely to force a test to pass. Do not treat game registration, payment or entering a live game as authorized by the launcher UI test.

This host uses individually authorized Docker commands. Do not add user groups or relax socket ACLs to get around permission failures. WinApps uses its manual RDP backend. Check the installed configuration before overwriting it.
