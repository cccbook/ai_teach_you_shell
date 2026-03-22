# 15. Scheduled Tasks and Monitoring

---

## 15.1 crontab Basics

### Basic Format

```
min hour day month weekday  command
┬   ┬    ┬   ┬     ┬        ┬
│   │    │   │     │        │
│   │    │   │     │        └─ command
│   │    │   │     └─ day of week (0-7, 0 and 7 are Sunday)
│   │    │   └─ month (1-12)
│   │    └─ day of month (1-31)
│   └─ hour (0-23)
└─ minute (0-59)
```

### Common Examples

```bash
# Every minute
* * * * * /path/to/script.sh

# Every hour at minute 30
30 * * * * /path/to/script.sh

# Daily at 3 AM
0 3 * * * /path/to/script.sh

# Weekly on Monday at 9 AM
0 9 * * 1 /path/to/script.sh

# Every 5 minutes
*/5 * * * * /path/to/script.sh
```

---

## 15.2 Managing crontab

```bash
# Show current crontab
crontab -l

# Edit crontab
crontab -e

# Remove crontab
crontab -r

# Create crontab file
cat > mycron << 'EOF'
# Daily backup
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# Weekly cleanup
0 4 * * 0 /scripts/clean-logs.sh

# Health check every 5 minutes
*/5 * * * * /scripts/health-check.sh
EOF

crontab mycron
crontab -l
```

---

## 15.3 Health Check Script

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
        log "WEB: FAILED"
        return 1
    fi
}

check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $usage -gt 90 ]]; then
        log "DISK: WARNING (${usage}%)"
        return 1
    fi
    log "DISK: OK (${usage}%)"
    return 0
}

FAILED=0

check_web || ((FAILED++))
check_disk || ((FAILED++))

if [[ $FAILED -gt 0 ]]; then
    echo "Health check failed, $FAILED items abnormal" | mail -s "Alert" "$ALERT_EMAIL"
fi

exit $FAILED
EOF

chmod +x scripts/health-check.sh
```

---

## 15.4 Auto Cleanup Script

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# Delete old logs
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# Compress old logs
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

echo "Cleanup complete: $(date)"
EOF

chmod +x scripts/clean-logs.sh
```

---

## 15.5 Exercises

1. Set up a crontab that echoes "hello" every hour and logs to a file
2. Write a disk space monitoring script that alerts when over 80%
3. Create a script that automatically backs up a MySQL database
4. Use systemd timer instead of cron to run health check every minute
