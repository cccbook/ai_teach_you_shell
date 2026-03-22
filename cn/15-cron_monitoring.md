# 15. 定时任务与监控

---

## 15.1 crontab 基础

### 基本格式

```
分 时 日 月 星期  命令
┬  ┬  ┬  ┬  ┬
│  │  │  │  │
│  │  │  │  └─── 星期 (0-7, 0 和 7 都是周日)
│  │  │  └────── 月 (1-12)
│  │  └───────── 日 (1-31)
│  └──────────── 时 (0-23)
└─────────────── 分 (0-59)
```

### 常见示例

```bash
# 每分钟执行
* * * * * /path/to/script.sh

# 每小时的第 30 分执行
30 * * * * /path/to/script.sh

# 每天凌晨 3 点执行
0 3 * * * /path/to/script.sh

# 每天 3:30 执行
30 3 * * * /path/to/script.sh

# 每周一 9 点执行
0 9 * * 1 /path/to/script.sh

# 每月 1 号 6 点执行
0 6 1 * * /path/to/script.sh

# 每 5 分钟执行
*/5 * * * * /path/to/script.sh

# 周一到五 9-17 点每小时执行
0 9-17 * * 1-5 /path/to/script.sh
```

---

## 15.2 管理 crontab

```bash
# 显示当前 crontab
crontab -l

# 编辑 crontab
crontab -e

# 删除 crontab
crontab -r

# 删除 crontab（需确认）
crontab -i
```

### 写入 crontab 文件

```bash
# 建立 crontab 文件
cat > mycron << 'EOF'
# 每天备份
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# 每周清理日志
0 4 * * 0 /scripts/clean-logs.sh

# 每 5 分钟检查服务
*/5 * * * * /scripts/health-check.sh
EOF

# 载入 crontab
crontab mycron

# 确认
crontab -l
```

---

## 15.3 crontab 环境问题

### 问题：路径和环境变量

crontab 中默认没有 PATH，需要完整路径或设置：

```bash
# 在 crontab 开头设置
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
HOME=/home/user

# 或使用完整路径
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

## 15.4 系统监控脚本

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

# 检查 HTTP
check_web() {
    if curl -sf "$WEB_URL" &>/dev/null; then
        log "WEB: OK"
        return 0
    else
        log "WEB: FAILED"
        return 1
    fi
}

# 检查磁盘空间
check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $usage -gt 90 ]]; then
        log "DISK: WARNING (${usage}%)"
        return 1
    fi
    log "DISK: OK (${usage}%)"
    return 0
}

# 检查内存
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
    # 发送警报（可以用 mail、sendmail、或 API）
    echo "健康检查失败，$FAILED 个项目异常" | mail -s "Alert" "$ALERT_EMAIL"
fi

exit $FAILED
EOF

chmod +x scripts/health-check.sh
```

---

## 15.5 自动清理脚本

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# 删除旧日志
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# 压缩旧日志
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

# 删除过大的文件
find "$LOG_DIR" -name "*.log" -size +100M -delete

echo "清理完成：$(date)"
EOF

chmod +x scripts/clean-logs.sh

# 加入 crontab
# 0 4 * * 0 /scripts/clean-logs.sh
```

---

## 15.6 自动备份脚本

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

# 备份数据库
if command -v pg_dump &>/dev/null; then
    pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "${BACKUP_PATH}/db.sql.gz"
fi

# 备份文件
tar -czvf "${BACKUP_PATH}/files.tar.gz" "$DATA_DIR"

# 建立 md5 校验
cd "$BACKUP_DIR"
md5sum "${BACKUP_NAME}/"* > "${BACKUP_NAME}/checksum.md5"

# 删除 7 天前的备份
find "$BACKUP_DIR" -name "backup_*" -mtime +7 -exec rm -rf {} \;

echo "备份完成：$BACKUP_PATH"
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

# 启用
systemctl daemon-reload
systemctl enable health-check.timer
systemctl start health-check.timer

# 查看状态
systemctl list-timers
```

---

## 15.8 练习题

1. 设置一个 crontab，每小时执行一次 `echo "hello"` 并记录到日志
2. 写一个磁盘空间监控脚本，超过 80% 时发送警报
3. 建立一个自动备份 MySQL 数据库的脚本
4. 用 systemd timer 取代 cron，设定每分钟执行健康检查