# 14. Script Triển Khai

---

## 14.1 Yếu Tố Cần Thiết Của Script Triển Khai Tốt

Script triển khai tốt nên:
1. Hỗ trợ chế độ dry-run
2. Có đầu ra log rõ ràng
3. Rollback khi thất bại
4. Xử lý gián đoạn
5. Theo dõi phiên bản

---

## 14.2 Script Triển Khai Đơn Giản

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
    command -v rsync &>/dev/null || { error "Cần rsync"; exit 1; }
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "Không thể kết nối đến $DEPLOY_HOST"
        exit 1
    fi
    log "Kiểm tra trước triển khai đạt"
}

backup() {
    log "Đang tạo backup..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "Backup xong: $DEPLOY_PATH.backup.$TIMESTAMP"
}

deploy() {
    log "Bắt đầu triển khai..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "Đã đồng bộ file"
}

restart() {
    log "Đang khởi động lại dịch vụ..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "Dịch vụ khởi động thành công"
    else
        error "Dịch vụ khởi động thất bại"
        exit 1
    fi
}

main() {
    log "🚀 Bắt đầu triển khai"
    log "Đích: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
    check
    backup
    deploy
    restart
    
    log "✅ Triển khai hoàn tất!"
}

main
EOF

chmod +x deploy.sh
```

---

## 14.3 Hỗ Trợ Dry-run

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
        log "[DRY-RUN] Sẽ đồng bộ file đến $DEPLOY_HOST"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "Bắt đầu triển khai..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 Triển Khai Đa Môi Trường

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
        echo "Môi trường không xác định: $ENVIRONMENT"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

if [[ "$CONFIRM" == "true" ]]; then
    echo "Sắp triển khai lên production: $HOST"
    read -p "Tiếp tục? (c/k) " -n 1 -r
    echo
    [[ $REPLY =~ ^[CcKk]$ ]] || exit 0
fi

log "Bắt đầu triển khai đến $HOST"

rsync -avz --delete \
    --exclude='.env' \
    ./ "$HOST:$PATH/"

ssh "$HOST" "cd $PATH && npm install --production"

log "Triển khai hoàn tất"
EOF
```

---

## 14.5 Bài Tập

1. Viết script triển khai hỗ trợ tùy chọn `--dry-run`
2. Thêm chức năng backup vào script triển khai
3. Viết script triển khai đa môi trường (dev/staging/production)
4. Tạo script rollback liệt kê và cho phép chọn phiên bản để rollback
