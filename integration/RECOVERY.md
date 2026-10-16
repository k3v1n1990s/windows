# Agent 恢復手冊

本文件是這套 Windows/WinApps 環境的接手入口。先閱讀 integration/AGENTS.md。

## 重裝後恢復

1. 在 Linux 安裝 Docker Engine + Compose、git、GnuPG、zstd、Python 3。啟用 CPU 虛擬化，確認 `/dev/kvm` 可供 Docker 使用。WinApps 桌面另外需要 FreeRDP 3、dialog、netcat。
2. 從 Google Drive `50_DELIVERABLES/winapps-mir-recovery-2026-10-16/` 下載備份、SHA256SUMS、restore.sh、手冊到本機 SSD。從 `90_PRIVATE/winapps-mir-recovery-2026-10-16/recovery.key` 取得金鑰，不要列印或傳入命令列。
3. 執行 `bash restore.sh BACKUP_DIRECTORY KEY_FILE NEW_EMPTY_LOCAL_DIRECTORY`。目的目錄必須不存在；不在 Drive 掛載盤執行 VM。
4. 在恢復目錄執行 `docker load -i recovery/staging/image.tar`，確認映像 `local/windows-zhaodice:10.2.2` 載入成功。使用目前平台的個別 Docker 授權方式；不要放寬 socket ACL 或隨意加入 docker 群組。
5. 進入 `windows/`，執行 `docker compose --env-file integration/.env -f integration/compose.yaml up -d`。不能同時啟動原 VM 和恢復副本：同一 Windows/遊戲身分與 MAC 不可同時使用。
6. 查閱日誌，應顯示 QEMU 10.2.2；開啟 `http://127.0.0.1:8006/`，使用 Agent 帳號。密碼從 integration/.env 安全讀取，勿寫入聊天或公開文件。
7. 執行 `python3 integration/scripts/configure-client.py --winapps ../winapps --runtime ../runtime`，重新產生適合新電腦路徑的 WinApps 配置和捷徑。需要遊戲帳號時，從 recovery/staging/private/game-account.json 讀取；要保存至使用者設定時使用 mode 600，不覆蓋既有檔案。
8. `mir-launcher` 為 RemoteApp；`winapps-mir windows` 為完整桌面；舊遊戲輸入或視窗異常時使用 web console。不要同時連 RDP 和 console 進行控制，切換可能鎖住另一個工作階段。

## 驗收

檢查 QEMU 版本、Windows 實際開機、啟動器伺服器清單。帳號與正式進服需使用者授權；先前已驗證 16号03区 [电信]、戰士青云游侠、出生區移動，沒有驗證戰鬥或長時間穩定性。遊戲區服可能隨時間下線，不可當成恢復失敗的唯一依據。

## 備份範圍與限制

包含 Windows 完整稀疏磁碟、UEFI/NVRAM/MAC、共享目錄、Docker 映像、離線 Git bundles、Windows 及測試帳號設定。不包含主機 Google/OAuth 憑證、Docker socket、主機家目錄。解密後的資料含私密憑證，僅存本機 mode 700 目錄。

GitHub 為公開程式碼備援，不保存密碼或磁碟。雲端備份和金鑰依使用者要求放在同一 Google Drive，不保護該 Google 帳號整體失陷。重裝前應確認自己仍能登入 Google 帳號。

## 後續備份

正常停止容器，確認狀態為 exited，再匯出映像至 recovery/staging/image.tar。兩個 Git checkout 必須是完整倉庫（淺層倉庫先 fetch --unshallow）；備份腳本會自動生成離線 Git bundles，執行 integration/scripts/backup.sh。該腳本會更新本機固定檔名，先封存前次備份或使用新日期目錄。雲端採用版本目錄，不覆蓋歷史備份。加密上傳後以 rclone check --download 驗證，再在獨立本機目錄解密、檢查並開機驗收。
