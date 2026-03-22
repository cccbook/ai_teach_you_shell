# 15. 定時任務與監控

---

## 15.1 crontab 基礎

### 基本格式

```
分 時 日 月 星期  命令
┬  ┬  ┬  ┬  ┬
│  │  │  │  │
│  │  │  │  └─── 星期 (0-7, 0 和 7 都是週日)
│  │  │  └────── 月 (1-12)
│  │  └───────── 日 (1-31)
│  └──────────── 時 (0-23)
└─────────────── 分 (0-59)
```

### 常見範例

```bash
# 每分鐘執行
* * * * * /path/to/script.sh

# 每小時的第 30 分執行
30 * * * * /path/to/script.sh

# 每天凌晨 3 點執行
0 3 * * * /path/to/script.sh

# 每天 3:30 執行
30 3 * * * /path/to/script.sh

# 每週一 9 點執行
0 9 * * 1 /path/to/script.sh

# 每月 1 號 6 點執行
0 6 1 * * /path/to/script.sh

# 每 5 分鐘執行
*/5 * * * * /path/to/script.sh

# 每週一到五 9-17 點每小時執行
0 9-17 * * 1-5 /path/to/script.sh
```

---

## 15.2 管理 crontab

```bash
# 顯示當前 crontab
crontab -l

# 編輯 crontab
crontab -e

# 刪除 crontab
crontab -r

# 刪除 crontab（需確認）
crontab -i
```

### 寫入 crontab 檔案

```bash
# 建立 crontab 檔案
cat > mycron << 'EOF'
# 每天備份
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# 每週清理日誌
0 4 * * 0 /scripts/clean-logs.sh

# 每 5 分鐘檢查服務
*/5 * * * * /scripts/health-check.sh
EOF

# 載入 crontab
crontab mycron

# 確認
crontab -l
```

---

## 15.3 crontab 環境問題

### 問題：路徑和環境變數

crontab 中預設沒有 PATH，需要完整路徑或設定：

```bash
# 在 crontab 開頭設定
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
HOME=/home/user

# 或使用完整路徑
0 3 * * * /usr/local/bin/python3 /home/user/scripts/backup.py
```

### 更好的做法：建立 wrapper

```bash
cat > /scripts/run-as-user.sh << 'EOF'
#!/bin/bash
source /home/user/.bashrc
source /home/user/scripts/env.sh
"$@"
EOF

# crontab 中使用
0 3 * * * /scripts/run-as-user.sh /home/user/scripts/backup.sh
```

---

## 15.4 系統監控腳本

```bash
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash
set -euo pipefail

ALERT_EMAIL="admin@example.com"
WEB_URL="https://myapp.com/health"
LOG_FILE="/var/log/health-check.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "$LOG_FILE"
}

# 檢查 HTTP
check_web() {
    if curl -sf "$WEB_URL" &>/dev/null; then
        log "WEB: OK"
        return 0
    else
        log "WEB: FAILED"
        return 1
    fi
}

# 檢查磁碟空間
check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $usage -gt 90 ]]; then
        log "DISK: WARNING (${usage}%)"
        return 1
    fi
    log "DISK: OK (${usage}%)"
    return 0
}

# 檢查記憶體
check_memory() {
    local usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
    if [[ $usage -gt 90 ]]; then
        log "MEMORY: WARNING (${usage}%)"
        return 1
    fi
    log "MEMORY: OK (${usage}%)"
    return 0
}

# 主流程
FAILED=0

check_web || ((FAILED++))
check_disk || ((FAILED++))
check_memory || ((FAILED++))

if [[ $FAILED -gt 0 ]]; then
    # 發送警報（可以用 mail、sendmail、或 API）
    echo "健康檢查失敗，$FAILED 個項目異常" | mail -s "Alert" "$ALERT_EMAIL"
fi

exit $FAILED
EOF

chmod +x scripts/health-check.sh
```

---

## 15.5 自動清理腳本

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# 刪除舊日誌
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# 壓縮舊日誌
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

# 刪除過大的檔案
find "$LOG_DIR" -name "*.log" -size +100M -delete

echo "清理完成：$(date)"
EOF

chmod +x scripts/clean-logs.sh

# 加入 crontab
# 0 4 * * 0 /scripts/clean-logs.sh
```

---

## 15.6 自動備份腳本

```bash
cat > scripts/backup.sh << 'EOF'
#!/bin/bash
set -euo pipefail

BACKUP_DIR="/backup"
DATA_DIR="/var/www/myapp"
DB_NAME="myapp"
DB_USER="backup"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

mkdir -p "$BACKUP_PATH"

# 備份資料庫
if command -v pg_dump &>/dev/null; then
    pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "${BACKUP_PATH}/db.sql.gz"
fi

# 備份檔案
tar -czvf "${BACKUP_PATH}/files.tar.gz" "$DATA_DIR"

# 建立 md5 校驗
cd "$BACKUP_DIR"
md5sum "${BACKUP_NAME}/"* > "${BACKUP_NAME}/checksum.md5"

# 刪除 7 天前的備份
find "$BACKUP_DIR" -name "backup_*" -mtime +7 -exec rm -rf {} \;

echo "備份完成：$BACKUP_PATH"
EOF

chmod +x scripts/backup.sh
```

---

## 15.7 Systemd Timer（取代 cron）

```bash
# health-check.service
cat > /etc/systemd/system/health-check.service << 'EOF'
[Unit]
Description=Health Check Service

[Service]
Type=oneshot
ExecStart=/scripts/health-check.sh
User=root
EOF

# health-check.timer
cat > /etc/systemd/system/health-check.timer << 'EOF'
[Unit]
Description=Run health check every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=health-check.service

[Install]
WantedBy=timers.target
EOF

# 啟用
systemctl daemon-reload
systemctl enable health-check.timer
systemctl start health-check.timer

# 查看狀態
systemctl list-timers
```

---

## 15.8 練習題

1. 設定一個 crontab，每小時執行一次 `echo "hello"` 並記錄到日誌
2. 寫一個磁碟空間監控腳本，超過 80% 時發送警報
3. 建立一個自動備份 MySQL 資料庫的腳本
4. 用 systemd timer 取代 cron，設定每分鐘執行健康檢查
