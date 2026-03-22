# 14. 部署腳本

---

## 14.1 部署腳本的基本要素

一個好的部署腳本應該：
1. 支援模擬模式（dry-run）
2. 有清楚的日誌輸出
3. 失敗時能回滾
4. 能處理中斷
5. 有版本追蹤

---

## 14.2 簡單的部署腳本

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 設定
DEPLOY_HOST="server.example.com"
DEPLOY_PATH="/var/www/myapp"
DEPLOY_USER="deploy"

# 顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $@"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

# 預檢查
check() {
    command -v rsync &>/dev/null || { error "需要 rsync"; exit 1; }
    command -v ssh &>/dev/null || { error "需要 ssh"; exit 1; }
    
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "無法連線到 $DEPLOY_HOST"
        exit 1
    fi
    
    log "預檢查通過"
}

# 備份
backup() {
    log "建立備份..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "備份完成：$DEPLOY_PATH.backup.$TIMESTAMP"
}

# 部署
deploy() {
    log "開始部署..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "檔案同步完成"
}

# 重啟服務
restart() {
    log "重啟服務..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "服務啟動成功"
    else
        error "服務啟動失敗"
        exit 1
    fi
}

# 主流程
main() {
    log "🚀 部署開始"
    log "目標：$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
    check
    backup
    deploy
    restart
    
    log "✅ 部署完成！"
}

main
EOF

chmod +x deploy.sh
```

---

## 14.3 支援 Dry-run

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
        -h|--host)
            DEPLOY_HOST="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

log() { echo "[INFO] $@"; }

deploy() {
    if $DRY_RUN; then
        log "[DRY-RUN] 即將同步檔案到 $DEPLOY_HOST"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "開始部署..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 支援回滾

```bash
cat > rollback.sh << 'EOF'
#!/bin/bash
set -euo pipefail

DEPLOY_HOST="server.example.com"
DEPLOY_PATH="/var/www/myapp"
DEPLOY_USER="deploy"

log() { echo "[INFO] $@"; }

# 列出可用備份
list_backups() {
    log "可用備份："
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "ls -lt $DEPLOY_PATH.backup.*" | head -10
}

# 回滾到指定版本
rollback() {
    local backup=$1
    
    log "回滾到：$backup"
    
    ssh "$DEPLOY_USER@$DEPLOY_HOST" << SSH
        systemctl stop myapp
        rm -rf $DEPLOY_PATH
        cp -r $backup $DEPLOY_PATH
        systemctl start myapp
SSH
    
    log "回滾完成"
}

# 主流程
case "${1:-}" in
    list)
        list_backups
        ;;
    *)
        if [[ -z "${1:-}" ]]; then
            echo "用法: $0 list | rollback <backup_path>"
            exit 1
        fi
        rollback "$1"
        ;;
esac
EOF
```

---

## 14.5 多環境部署

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
        echo "未知環境：$ENVIRONMENT"
        echo "可用：staging, production"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

# 確認生產環境部署
if [[ "$CONFIRM" == "true" ]]; then
    echo "即將部署到生產環境：$HOST"
    read -p "確定繼續？(y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

log "開始部署到 $HOST"

rsync -avz --delete \
    --exclude='.env' \
    --exclude='*.log' \
    ./ "$HOST:$PATH/"

ssh "$HOST" "cd $PATH && npm install --production"

log "部署完成"
EOF
```

---

## 14.6 Docker 部署

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

IMAGE="myapp:latest"
CONTAINER="myapp"
HOST="server.example.com"

log() { echo "[INFO] $@"; }

# 建置映像檔
build() {
    log "建置 Docker 映像檔..."
    docker build -t "$IMAGE" .
    log "建置完成"
}

# 推送映像檔
push() {
    log "推送映像檔..."
    docker push "$IMAGE"
    log "推送完成"
}

# 遠端部署
deploy() {
    log "遠端部署..."
    ssh "$HOST" << SSH
        docker pull $IMAGE
        docker stop $CONTAINER || true
        docker rm $CONTAINER || true
        docker run -d --name $CONTAINER \
            -p 80:8000 \
            --restart unless-stopped \
            $IMAGE
SSH
    log "部署完成"
}

# 健康檢查
health_check() {
    log "健康檢查..."
    for i in {1..10}; do
        if ssh "$HOST" "curl -sf http://localhost/health" &>/dev/null; then
            log "服務正常"
            return 0
        fi
        sleep 2
    done
    log "健康檢查失敗"
    return 1
}

# 主流程
build
push
deploy
health_check
EOF
```

---

## 14.7 練習題

1. 寫一個部署腳本，支援 `--dry-run` 參數
2. 為部署腳本加入備份功能
3. 寫一個多環境（dev/staging/production）部署腳本
4. 建立一個回滾腳本，能列出並選擇要回滾的版本
