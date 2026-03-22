# 14. Script การ deploy

---

## 14.1 องค์ประกอบสำคัญของสคริปต์ deploy ที่ดี

สคริปต์ deploy ที่ดีควรมี:
1. รองรับโหมด dry-run
2. มีผลลัพธ์ล็อกที่ชัดเจน
3. ย้อนกลับเมื่อล้มเหลว
4. จัดการการขัดจังหวะ
5. มีการติดตามเวอร์ชัน

---

## 14.2 สคริปต์ deploy แบบง่าย

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

DEPLOY_HOST="server.example.com"
DEPLOY_PATH="/var/www/myapp"
DEPLOY_USER="deploy"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $@"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

check() {
    command -v rsync &>/dev/null || { error "ต้องการ rsync"; exit 1; }
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "ไม่สามารถเชื่อมต่อกับ $DEPLOY_HOST"
        exit 1
    fi
    log "การตรวจสอบล่วงหน้าผ่านแล้ว"
}

backup() {
    log "กำลังสร้างการสำรองข้อมูล..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "การสำรองข้อมูลเสร็จแล้ว: $DEPLOY_PATH.backup.$TIMESTAMP"
}

deploy() {
    log "เริ่มการ deploy..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "ไฟล์ถูก同步แล้ว"
}

restart() {
    log "กำลังรีสตาร์ทบริการ..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "บริการเริ่มทำงานสำเร็จ"
    else
        error "บริการเริ่มทำงานไม่ได้"
        exit 1
    fi
}

main() {
    log "🚀 เริ่มการ deploy"
    log "เป้าหมาย: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
    check
    backup
    deploy
    restart
    
    log "✅ การ deploy เสร็จสมบูรณ์!"
}

main
EOF

chmod +x deploy.sh
```

---

## 14.3 รองรับ Dry-run

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

DRY_RUN=false
DEPLOY_HOST="server.example.com"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

log() { echo "[INFO] $@"; }

deploy() {
    if $DRY_RUN; then
        log "[DRY-RUN] จะ同步ไฟล์ไปยัง $DEPLOY_HOST"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "เริ่มการ deploy..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 Deploy หลาย Environment

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"

case "$ENVIRONMENT" in
    staging)
        HOST="staging.example.com"
        PATH="/var/www/staging"
        ;;
    production)
        HOST="prod.example.com"
        PATH="/var/www/production"
        CONFIRM=true
        ;;
    *)
        echo "ไม่รู้จัก environment: $ENVIRONMENT"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

if [[ "$CONFIRM" == "true" ]]; then
    echo "กำลังจะ deploy ไป production: $HOST"
    read -p "ดำเนินต่อ? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

log "เริ่มการ deploy ไปยัง $HOST"

rsync -avz --delete \
    --exclude='.env' \
    ./ "$HOST:$PATH/"

ssh "$HOST" "cd $PATH && npm install --production"

log "การ deploy เสร็จสมบูรณ์"
EOF
```

---

## 14.5 แบบฝึกหัด

1. เขียนสคริปต์ deploy ที่รองรับตัวเลือก `--dry-run`
2. เพิ่มฟังก์ชันการสำรองข้อมูลให้กับสคริปต์ deploy
3. เขียนสคริปต์ deploy หลาย environment (dev/staging/production)
4. สร้างสคริปต์ rollback ที่แสดงรายการและให้เลือกเวอร์ชันที่จะ rollback
