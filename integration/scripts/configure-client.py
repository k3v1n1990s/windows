#!/usr/bin/env python3
"""Configure the upstream WinApps client without Docker socket permissions."""
from pathlib import Path
import argparse, shutil, shlex, time
p=argparse.ArgumentParser()
p.add_argument('--winapps',type=Path,required=True,help='Upstream WinApps checkout')
p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--launcher-path',help='Override the installed Windows executable path')
a=p.parse_args()
repo=Path(__file__).resolve().parents[2]
source=(a.winapps.resolve()/'bin/winapps')
if not source.is_file():raise SystemExit('WinApps bin/winapps missing')
secret=(repo/'integration/.env').read_text().strip().split('=',1)[1]
h=Path.home();cfg=h/'.config/winapps';cfg.mkdir(parents=True,exist_ok=True)
conf=cfg/'winapps.conf'
if conf.exists():shutil.copy2(conf,cfg/('winapps.conf.bak.'+str(int(time.time()))))
pw=cfg/'mir-password';pw.write_text(secret+'\n');pw.chmod(0o600)
ask=cfg/'mir-askpass';ask.write_text('#!/bin/sh\nexec cat '+shlex.quote(str(pw))+'\n');ask.chmod(0o700)
shared=a.runtime.resolve()/'shared'
target_file=shared/'evidence/launcher-target.txt'
target=a.launcher_path or (target_file.read_text(encoding='utf-8-sig').strip() if target_file.exists() else r'C:\AgentLab\launcher.exe')
conf.write_text(f'''RDP_USER="Agent"
RDP_ASKPASS="{ask}"
RDP_IP="127.0.0.1"
RDP_PORT="3389"
RDP_DOMAIN="."
WAFLAVOR="manual"
RDP_SCALE="100"
RDP_FLAGS="/cert:tofu /auth-pkg-list:none,ntlm /sound /drive:exchange,{shared}"
FREERDP_COMMAND="xfreerdp3"
AUTOPAUSE="off"
DEBUG="false"
HIDEF="on"
PORT_TIMEOUT="10"
''');conf.chmod(0o600)
b=h/'.local/bin';b.mkdir(parents=True,exist_ok=True)
for name,cmd in [('winapps-mir',shlex.quote(str(source))+' "$@"'),('mir-launcher',shlex.quote(str(b/'winapps-mir'))+' manual '+shlex.quote(target))]:
 f=b/name;f.write_text('#!/bin/sh\nexec '+cmd+'\n');f.chmod(0o755)
d=h/'.local/share/applications';d.mkdir(parents=True,exist_ok=True)
for name,label,cmd,icon in [('mir-launcher','Mir Launcher (Windows)',str(b/'mir-launcher'),'applications-games'),('winapps-mir-windows','Windows Agent Lab',str(b/'winapps-mir')+' windows','computer')]:
 (d/(name+'.desktop')).write_text(f'[Desktop Entry]\nType=Application\nName={label}\nExec={cmd}\nIcon={icon}\nTerminal=false\nCategories=System;\n')
print('WinApps manual backend configured; credentials saved with mode 600')
