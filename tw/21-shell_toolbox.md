# 21. 打造你的 AI Shell 工具箱

---

## 21.1 為什麼需要工具箱

當你發現自己在重複做同樣的事，就該把它自動化並收集到工具箱。

AI 特別擅長：
- 快速建立工具
- 把複雜流程封裝成簡單命令
- 持續優化常用腳本

---

## 21.2 工具箱目錄結構

```
~/bin/
├── lib/              # 共用函式庫
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── project/          # 專案範本
│   ├── python/
│   ├── nodejs/
│   └── static-site/
├── scripts/          # 工具腳本
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # 可執行工具
    └── monitor       # 可執行工具
```

---

## 21.3 建立你的函式庫

### logging.sh

```bash
cat > ~/bin/lib/logging.sh << 'EOF'
#!/bin/bash

# 日誌工具
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }
EOF

source ~/bin/lib/logging.sh
```

### utils.sh

```bash
cat > ~/bin/lib/utils.sh << 'EOF'
#!/bin/bash

# 確認命令存在
need_command() {
    command -v "$1" &>/dev/null || {
        echo "需要命令：$1"
        exit 1
    }
}

# 確認檔案存在
need_file() {
    [[ -f "$1" ]] || {
        echo "需要檔案：$1"
        exit 1
    }
}

# 確認目錄存在
need_dir() {
    [[ -d "$1" ]] || {
        echo "需要目錄：$1"
        exit 1
    }
}
EOF
```

---

## 21.4 實用工具：git-clean

```bash
cat > ~/bin/git-clean << 'EOF'
#!/bin/bash
set -euo pipefail

# 清理 Git 無用檔案

DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=true; shift ;;
        *) shift ;;
    esac
done

if $DRY_RUN; then
    echo "[DRY-RUN] 即將刪除："
fi

# 刪除合併完成的分支
git branch --merged main | grep -v "main\|master\|develop" | while read branch; do
    if $DRY_RUN; then
        echo "  刪除分支：$branch"
    else
        git branch -d "$branch"
        echo "已刪除：$branch"
    fi
done

# 清理暫存檔
git clean -n -d
EOF

chmod +x ~/bin/git-clean
```

---

## 21.5 實用工具：docker-clean

```bash
cat > ~/bin/docker-clean << 'EOF'
#!/bin/bash
set -euo pipefail

# 清理 Docker 資源

echo "停止所有容器..."
docker stop $(docker ps -aq) 2>/dev/null || true

echo "刪除已停止的容器..."
docker container prune -f

echo "刪除未使用的映像檔..."
docker image prune -af

echo "刪除未使用的網路..."
docker network prune -f

echo "刪除建置快取..."
docker builder prune -af

echo "✅ Docker 清理完成"
docker system df
EOF

chmod +x ~/bin/docker-clean
```

---

## 21.6 實用工具：log-parse

```bash
cat > ~/bin/log-parse << 'EOF'
#!/bin/bash

# 分析日誌檔案

if [[ $# -lt 1 ]]; then
    echo "用法: $0 <日誌檔案> [條件]"
    exit 1
fi

FILE=$1
PATTERN=${2:-""}

echo "=== 日誌分析：$FILE ==="
echo ""

echo "檔案大小：$(du -h "$FILE" | cut -f1)"
echo "總行數：$(wc -l < "$FILE")"
echo ""

if [[ -n "$PATTERN" ]]; then
    echo "包含 '$PATTERN' 的行數：$(grep -c "$PATTERN" "$FILE")"
fi

echo ""
echo "=== 錯誤統計 ==="
grep -i "error\|fail\|exception" "$FILE" | awk '{print $NF}' | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== HTTP 狀態碼分布 ==="
grep -oE '"[0-9]{3}"' "$FILE" | tr -d '"' | sort | uniq -c | sort -rn
EOF

chmod +x ~/bin/log-parse
```

---

## 21.7 專案範本：Python 專案

```bash
mkdir -p ~/bin/project/python
cat > ~/bin/project/python/init.sh << 'EOF'
#!/bin/bash

NAME=${1:-myproject}

mkdir -p "$NAME"/{src,tests,docs}
touch "$NAME/src/__init__.py"
touch "$NAME/tests/__init__.py"

cat > "$NAME/README.md" << MD
# $NAME

MD

cat > "$NAME/requirements.txt" << MD
# 你的依賴
MD

cat > "$NAME/.gitignore" << MD
__pycache__/
*.py[cod]
.env
.venv/
MD

echo "✅ Python 專案 $NAME 建立完成"
EOF
```

---

## 21.8 讓工具在 PATH 中

```bash
# 確認 ~/bin 在 PATH 中
echo $PATH | grep -q "$HOME/bin" && echo "已設定" || echo "未設定"

# 加入 PATH（加到 ~/.bashrc 或 ~/.zshrc）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 或直接在 ~/bin 建立連結
ln -s ~/bin/git-clean /usr/local/bin/git-clean
```

---

## 21.9 AI 幫你擴展工具箱

```bash
# 人類：幫我建立一個工具，分析 Nginx 存取日誌

# AI：
cat > ~/bin/nginx-analize << 'EOF'
#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "用法: $0 <存取日誌檔案>"
    exit 1
fi

FILE=$1

echo "=== Nginx 分析：$FILE ==="
echo ""

echo "總請求數：$(wc -l < "$FILE")"
echo ""

echo "=== Top 10 IP ==="
awk '{print $1}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== Top 10 URL ==="
awk '{print $7}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== 狀態碼分布 ==="
awk '{print $9}' "$FILE" | sort | uniq -c | sort -rn
echo ""

echo "=== 每秒請求峰值 ==="
awk '{print $4}' "$FILE" | cut -d: -f2 | sort | uniq -c | sort -rn | head -5
EOF

chmod +x ~/bin/nginx-analize
```

---

## 21.10 持續優化

```bash
# 每年回顧工具箱
# - 哪些工具很少用？刪除
# - 哪些工具可以改進？
# - 哪些重複任務可以自動化？

# 版本控制你的工具箱
cd ~/bin
git init
git add .
git commit -m "初始版本"
```

---

## 21.11 練習題

1. 建立你的 ~/bin 目錄結構
2. 把常用的函式寫成可重用的函式庫
3. 為你每天重複做的事情寫一個工具
4. 用 AI 幫你建立一個 Nginx 日誌分析工具
5. 把工具箱放進 Git 版本控制
