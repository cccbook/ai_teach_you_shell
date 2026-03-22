# 15. 定时タスクと監視

---

## 15.1 crontab の基本

### 基本フォーマット

```
分 時 日 月 曜日  コマンド
┬  ┬  ┬ ┬  ┬     ┬
│  │  │ │  │     │
│  │  │ │  │     └─ コマンド
│  │  │ │  └─ 曜日 (0-7、0と7は日曜日)
│  │  │ └─ 月 (1-12)
│  │  └─ 日 (1-31)
│  └─ 時 (0-23)
└─ 分 (0-59)
```

### よく使う例

```bash
# 毎分
* * * * * /path/to/script.sh

# 毎時30分
30 * * * * /path/to/script.sh

# 毎日午前3時
0 3 * * * /path/to/script.sh

# 毎週月曜日午前9時
0 9 * * 1 /path/to/script.sh

# 5分ごと
*/5 * * * * /path/to/script.sh
```

---

## 15.2 crontab の管理

```bash
# 現在のcrontabを表示
crontab -l

# crontabを編集
crontab -e

# crontabを削除
crontab -r

# crontabファイルを作成
cat > mycron << 'EOF'
# 毎日のバックアップ
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# 毎週のクリーンアップ
0 4 * * 0 /scripts/clean-logs.sh

# 5分ごとのヘルスチェック
*/5 * * * * /scripts/health-check.sh
EOF

crontab mycron
crontab -l
```

---

## 15.3 ヘルスチェックスクリプト

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

check_web() {
    if curl -sf "$WEB_URL" &>/dev/null; then
        log "WEB: OK"
        return 0
    else
        log "WEB: 失敗"
        return 1
    fi
}

check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $usage -gt 90 ]]; then
        log "DISK: 警告 (${usage}%)"
        return 1
    fi
    log "DISK: OK (${usage}%)"
    return 0
}

FAILED=0

check_web || ((FAILED++))
check_disk || ((FAILED++))

if [[ $FAILED -gt 0 ]]; then
    echo "ヘルスチェック失敗、$FAILED 項目異常" | mail -s "アラート" "$ALERT_EMAIL"
fi

exit $FAILED
EOF

chmod +x scripts/health-check.sh
```

---

## 15.4 自動クリーンアップスクリプト

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# 古いログを削除
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# 古いログを圧縮
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

echo "クリーンアップ完了: $(date)"
EOF

chmod +x scripts/clean-logs.sh
```

---

## 15.5 練習問題

1. 毎時 "hello" を出力し、ファイルにログを記録するcrontabを設定する
2. ディスク使用率が80%を超えたらアラートを出すスクリプトを書く
3. MySQLデータベースを自動バックアップするスクリプトを作成する
4. cronの代わりにsystemd timerを使用して1分ごとにヘルスチェックを実行する
