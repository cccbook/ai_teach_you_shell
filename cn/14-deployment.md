# 14. 部署脚本

---

## 14.1 部署脚本的基本要素

一个好的部署脚本应该：
1. 支持模拟模式（dry-run）
2. 有清晰的日志输出
3. 失败时能回滚
4. 能处理中断
5. 有版本追踪

---

## 14.2 简单的部署脚本

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 设置
DEPLOY_HOST="server.example.com"
DEPLOY_PATH="/var/www/myapp"
DEPLOY_USER="deploy"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $@"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

# 预检查
check() {
    command -v rsync &>/dev/null || { error "需要 rsync"; exit 1; }
    command -v ssh &>/dev/null || { error "需要 ssh"; exit 1; }
    
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "无法连接到 $DEPLOY_HOST"
        exit 1
    fi
    
    log "预检查通过"
}

# 备份
backup() {
    log "建立备份..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "备份完成：$DEPLOY_PATH.backup.$TIMESTAMP"
}

# 部署
deploy() {
    log "开始部署..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "文件同步完成"
}

# 重启服务
restart() {
    log "重启服务..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "服务启动成功"
    else
        error "服务启动失败"
        exit 1
    fi
}

# 主流程
main() {
    log "🚀 部署开始"
    log "目标：$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
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

## 14.3 支持 Dry-run

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
        log "[DRY-RUN] 即将同步文件到 $DEPLOY_HOST"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "开始部署..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 支持回滚

```bash
cat > rollback.sh << 'EOF'
#!/bin/bash
set -euo pipefail

DEPLOY_HOST="server.example.com"
DEPLOY_PATH="/var/www/myapp"
DEPLOY_USER="deploy"

log() { echo "[INFO] $@"; }

# 列出可用备份
list_backups() {
    log "可用备份："
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "ls -lt $DEPLOY_PATH.backup.*" | head -10
}

# 回滚到指定版本
rollback() {
    local backup=$1
    
    log "回滚到：$backup"
    
    ssh "$DEPLOY_USER@$DEPLOY_HOST" << SSH
        systemctl stop myapp
        rm -rf $DEPLOY_PATH
        cp -r $backup $DEPLOY_PATH
        systemctl start myapp
SSH
    
    log "回滚完成"
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

## 14.5 多环境部署

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
        echo "未知环境：$ENVIRONMENT"
        echo "可用：staging, production"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

# 确认生产环境部署
if [[ "$CONFIRM" == "true" ]]; then
    echo "即将部署到生产环境：$HOST"
    read -p "确定继续？(y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

log "开始部署到 $HOST"

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

# 构建镜像
build() {
    log "构建 Docker 镜像..."
    docker build -t "$IMAGE" .
    log "构建完成"
}

# 推送镜像
push() {
    log "推送镜像..."
    docker push "$IMAGE"
    log "推送完成"
}

# 远程部署
deploy() {
    log "远程部署..."
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

# 健康检查
health_check() {
    log "健康检查..."
    for i in {1..10}; do
        if ssh "$HOST" "curl -sf http://localhost/health" &>/dev/null; then
            log "服务正常"
            return 0
        fi
        sleep 2
    done
    log "健康检查失败"
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

## 14.7 练习题

1. 写一个部署脚本，支持 `--dry-run` 参数
2. 为部署脚本加入备份功能
3. 写一个多环境（dev/staging/production）部署脚本
4. 建立一个回滚脚本，能列出并选择要回滚的版本