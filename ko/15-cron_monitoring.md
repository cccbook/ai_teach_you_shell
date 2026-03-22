# 15. 예약 작업 및 모니터링

---

## 15.1 crontab 기본

### 기본 형식

```
min hour day month weekday  command
┬   ┬    ┬   ┬     ┬        ┬
│   │    │   │     │        │
│   │    │   │     │        └─ 명령어
│   │    │   │     └─ 요일 (0-7, 0과 7은 일요일)
│   │    │   └─ 월 (1-12)
│   │    └─ 일 (1-31)
│   └─ 시 (0-23)
└─ 분 (0-59)
```

### 일반적인 예시

```bash
# 매분
* * * * * /path/to/script.sh

# 매시 30분에
30 * * * * /path/to/script.sh

# 매일 새벽 3시
0 3 * * * /path/to/script.sh

# 매주 월요일 아침 9시
0 9 * * 1 /path/to/script.sh

# 5분마다
*/5 * * * * /path/to/script.sh
```

---

## 15.2 crontab 관리

```bash
# 현재 crontab 확인
crontab -l

# crontab 편집
crontab -e

# crontab 삭제
crontab -r

# crontab 파일 생성
cat > mycron << 'EOF'
# 일일 백업
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# 주간 정리
0 4 * * 0 /scripts/clean-logs.sh

# 5분마다 헬스체크
*/5 * * * * /scripts/health-check.sh
EOF

crontab mycron
crontab -l
```

---

## 15.3 헬스체크 스크립트

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

## 15.4 자동 정리 스크립트

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# 오래된 로그 삭제
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# 오래된 로그 압축
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

echo "Cleanup complete: $(date)"
EOF

chmod +x scripts/clean-logs.sh
```

---

## 15.5 연습 문제

1. 매시간 "hello"를 출력하고 파일에 기록하는 crontab을 설정하세요
2. 디스크 사용량이 80%를 넘으면 알림을 보내는 모니터링 스크립트를 작성하세요
3. MySQL 데이터베이스를 자동으로 백업하는 스크립트를 만드세요
4. cron 대신 systemd timer를 사용하여 1분마다 헬스체크를 실행하세요
