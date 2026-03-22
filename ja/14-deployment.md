# 14. デプロイスクリプト

---

## 14.1 優れたデプロイスクリプトの必須要素

優れたデプロイスクリプトは:
1. ドライランモードをサポートする
2. 明確なログ出力を提供する
3. 失敗時にロールバックする
4. 割り込みを処理する
5. バージョン管理がある

---

## 14.2 シンプルなデプロイスクリプト

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
    command -v rsync &>/dev/null || { error "rsync が必要です"; exit 1; }
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "$DEPLOY_HOST に接続できません"
        exit 1
    fi
    log "事前チェック完了"
}

backup() {
    log "バックアップを作成中..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "バックアップ完了: $DEPLOY_PATH.backup.$TIMESTAMP"
}

deploy() {
    log "デプロイを開始..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "ファイル同期完了"
}

restart() {
    log "サービスを再起動中..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "サービスが正常に開始されました"
    else
        error "サービスの開始に失敗しました"
        exit 1
    fi
}

main() {
    log "🚀 デプロイを開始します"
    log "対象: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
    check
    backup
    deploy
    restart
    
    log "✅ デプロイ完了！"
}

main
EOF

chmod +x deploy.sh
```

---

## 14.3 ドライランモードのサポート

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
        log "[DRY-RUN] $DEPLOY_HOST にファイルを同期します"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "デプロイを開始..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 マルチ環境デプロイ

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
        echo "不明な環境: $ENVIRONMENT"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

if [[ "$CONFIRM" == "true" ]]; then
    echo "本番環境にデプロイします: $HOST"
    read -p "続行しますか? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

log "$HOST へのデプロイを開始"

rsync -avz --delete \
    --exclude='.env' \
    ./ "$HOST:$PATH/"

ssh "$HOST" "cd $PATH && npm install --production"

log "デプロイ完了"
EOF
```

---

## 14.5 演習問題

1. `--dry-run` オプションをサポートするデプロイスクリプトを書く
2. デプロイスクリプトにバックアップ機能を追加する
3. マルチ環境（開発/ステージング/本番）デプロイスクリプトを書く
4. バージョン一覧を表示し、どのバージョンにロールバックするか選択できるロールバックスクリプトを作成する
