# 15. งานที่กำหนดเวลาและการตรวจสอบ

---

## 15.1 พื้นฐาน crontab

### รูปแบบพื้นฐาน

```
min hour day month weekday  command
┬   ┬    ┬   ┬     ┬        ┬
│   │    │   │     │        │
│   │    │   │     │        └─ คำสั่ง
│   │    │   │     └─ วันในสัปดาห์ (0-7, 0 และ 7 คือวันอาทิตย์)
│   │    │   └─ เดือน (1-12)
│   │    └─ วันที่ (1-31)
│   └─ ชั่วโมง (0-23)
└─ นาที (0-59)
```

### ตัวอย่างที่ใช้บ่อย

```bash
# ทุกนาที
* * * * * /path/to/script.sh

# ทุกชั่วโมง นาทีที่ 30
30 * * * * /path/to/script.sh

# ทุกวัน เวลา 03:00 น.
0 3 * * * /path/to/script.sh

# ทุกสัปดาห์ วันจันทร์ เวลา 09:00 น.
0 9 * * 1 /path/to/script.sh

# ทุก 5 นาที
*/5 * * * * /path/to/script.sh
```

---

## 15.2 การจัดการ crontab

```bash
# แสดง crontab ปัจจุบัน
crontab -l

# แก้ไข crontab
crontab -e

# ลบ crontab
crontab -r

# สร้างไฟล์ crontab
cat > mycron << 'EOF'
# สำรองข้อมูลรายวัน
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# ลบไฟล์ที่ไม่ใช้งานรายสัปดาห์
0 4 * * 0 /scripts/clean-logs.sh

# ตรวจสอบสถานะทุก 5 นาที
*/5 * * * * /scripts/health-check.sh
EOF

crontab mycron
crontab -l
```

---

## 15.3 สคริปต์ตรวจสอบสุขภาพ

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

## 15.4 สคริปต์ล้างข้อมูลอัตโนมัติ

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# ลบไฟล์ log เก่า
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# บีบอัดไฟล์ log เก่า
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

echo "Cleanup complete: $(date)"
EOF

chmod +x scripts/clean-logs.sh
```

---

## 15.5 แบบฝึกหัด

1. ตั้งค่า crontab ให้แสดง "hello" ทุกชั่วโมงและบันทึกลงไฟล์
2. เขียนสคริปต์ตรวจสอบพื้นที่ดิสก์ที่แจ้งเตือนเมื่อเกิน 80%
3. สร้างสคริปต์สำรองฐานข้อมูล MySQL อัตโนมัติ
4. ใช้ systemd timer แทน cron เพื่อรัน health check ทุกนาที
