# 14. Deployment Scripts

---

## 14.1 Essential Elements of a Good Deployment Script

A good deployment script should:
1. Support dry-run mode
2. Have clear log output
3. Rollback on failure
4. Handle interrupts
5. Have version tracking

---

## 14.2 Simple Deployment Script

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
    command -v rsync &>/dev/null || { error "rsync required"; exit 1; }
    if ! ssh -o ConnectTimeout=5 "$DEPLOY_USER@$DEPLOY_HOST" "exit 0" 2>/dev/null; then
        error "Cannot connect to $DEPLOY_HOST"
        exit 1
    fi
    log "Pre-checks passed"
}

backup() {
    log "Creating backup..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$TIMESTAMP"
    log "Backup done: $DEPLOY_PATH.backup.$TIMESTAMP"
}

deploy() {
    log "Starting deployment..."
    rsync -avz --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env' \
        ./ "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
    log "Files synced"
}

restart() {
    log "Restarting service..."
    ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl restart myapp"
    sleep 2
    
    if ssh "$DEPLOY_USER@$DEPLOY_HOST" "systemctl is-active myapp" | grep -q "active"; then
        log "Service started successfully"
    else
        error "Service failed to start"
        exit 1
    fi
}

main() {
    log "🚀 Deployment starting"
    log "Target: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
    
    check
    backup
    deploy
    restart
    
    log "✅ Deployment complete!"
}

main
EOF

chmod +x deploy.sh
```

---

## 14.3 Support Dry-run

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
        log "[DRY-RUN] Would sync files to $DEPLOY_HOST"
        rsync -avz --dry-run ./ "$DEPLOY_HOST:/tmp/test/"
    else
        log "Starting deployment..."
        rsync -avz ./ "$DEPLOY_HOST:/var/www/app/"
    fi
}

deploy
EOF
```

---

## 14.4 Multi-Environment Deployment

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
        echo "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac

log() { echo "🚀 [$ENVIRONMENT] $@"; }

if [[ "$CONFIRM" == "true" ]]; then
    echo "About to deploy to production: $HOST"
    read -p "Continue? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

log "Starting deployment to $HOST"

rsync -avz --delete \
    --exclude='.env' \
    ./ "$HOST:$PATH/"

ssh "$HOST" "cd $PATH && npm install --production"

log "Deployment complete"
EOF
```

---

## 14.5 Exercises

1. Write a deployment script supporting `--dry-run` option
2. Add backup functionality to the deployment script
3. Write a multi-environment (dev/staging/production) deployment script
4. Create a rollback script that lists and allows choosing which version to rollback to
