# 14. 배포 스크립트

---

## 14.1 좋은 배포 스크립트의 필수 요소

좋은 배포 스크립트는 다음을 지원해야 합니다:
1. 드라이 런 모드
2. 명확한 로그 출력
3. 실패 시 롤백
4.割り込み 처리
5. 버전 추적

---

## 14.2 간단한 배포 스크립트

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
    command -v rsync &>/dev/null || { error "rsync 필요"; exit 1; }
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "$DEPLOY_HOST에 연결할 수 없음"
        exit 1
    fi
    log "사전 검사 통과"
}

backup() {
    log "백업 생성 중..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "백업 완료: $DEPLOY_PATH.backup.$TIMESTAMP"
}

deploy() {
    log "배포 시작..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "파일 동기화 완료"
}

restart() {
    log "서비스 재시작 중..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "서비스가 성공적으로 시작됨"
    else
        error "서비스 시작 실패"
        exit 1
    fi
}

main() {
    log "🚀 배포 시작"
    log "대상: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
    check
    backup
    deploy
    restart
    
    log "✅ 배포 완료!"
}

main
EOF

chmod +x deploy.sh
```

---

## 14.3 드라이 런 지원

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
        log "[드라이 런] $DEPLOY_HOST에 파일 동기화 예정"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "배포 시작..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 다중 환경 배포

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
        echo "알 수 없는 환경: $ENVIRONMENT"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

if [[ "$CONFIRM" == "true" ]]; then
    echo "production 환경에 배포 예정: $HOST"
    read -p "계속하시겠습니까? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

log "$HOST에 배포 시작"

rsync -avz --delete \
    --exclude='.env' \
    ./ "$HOST:$PATH/"

ssh "$HOST" "cd $PATH && npm install --production"

log "배포 완료"
EOF
```

---

## 14.5 연습문제

1. `--dry-run` 옵션을 지원하는 배포 스크립트를 작성하세요
2. 배포 스크립트에 백업 기능을 추가하세요
3. 다중 환경 (dev/staging/production) 배포 스크립트를 작성하세요
4. 롤백할 버전 목록을 표시하고 선택할 수 있는 롤백 스크립트를 만드세요
