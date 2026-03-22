# 21. Xây Dựng Bộ Công Cụ Shell AI Của Bạn

---

## 21.1 Tại Sao Bạn Cần Một Bộ Công Cụ

Khi bạn thấy mình lặp đi lặp lại cùng một việc, đã đến lúc tự động hóa và thu thập vào bộ công cụ.

AI đặc biệt giỏi:
- Nhanh chóng tạo công cụ
- Bao bọc complex workflows thành commands đơn giản
- Liên tục cải thiện các scripts thường dùng

---

## 21.2 Cấu Trúc Thư Mục Bộ Công Cụ

```
~/bin/
├── lib/              # Shared libraries
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── project/          # Project templates
│   ├── python/
│   ├── nodejs/
│   └── static-site/
├── scripts/          # Tool scripts
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # Executable tool
    └── monitor       # Executable tool
```

---

## 21.3 Tạo Thư Viện Của Bạn

### logging.sh

```bash
cat > ~/bin/lib/logging.sh << 'EOF'
#!/bin/bash

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

need_command() {
    command -v "$1" &>/dev/null || {
        echo "Required command: $1"
        exit 1
    }
}

need_file() {
    [[ -f "$1" ]] || {
        echo "Required file: $1"
        exit 1
    }
}

need_dir() {
    [[ -d "$1" ]] || {
        echo "Required directory: $1"
        exit 1
    }
}
EOF
```

---

## 21.4 Công Cụ Thực Tế: git-clean

```bash
cat > ~/bin/git-clean << 'EOF'
#!/bin/bash
set -euo pipefail

DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=true; shift ;;
        *) shift ;;
    esac
done

if $DRY_RUN; then
    echo "[DRY-RUN] Would delete:"
fi

git branch --merged main | grep -v "main\|master\|develop" | while read branch; do
    if $DRY_RUN; then
        echo "  Delete branch: $branch"
    else
        git branch -d "$branch"
        echo "Deleted: $branch"
    fi
done

git clean -n -d
EOF

chmod +x ~/bin/git-clean
```

---

## 21.5 Công Cụ Thực Tế: docker-clean

```bash
cat > ~/bin/docker-clean << 'EOF'
#!/bin/bash
set -euo pipefail

echo "Stopping all containers..."
docker stop $(docker ps -aq) 2>/dev/null || true

echo "Removing stopped containers..."
docker container prune -f

echo "Removing unused images..."
docker image prune -af

echo "Removing unused networks..."
docker network prune -f

echo "Removing build cache..."
docker builder prune -af

echo "✅ Docker cleanup complete"
docker system df
EOF

chmod +x ~/bin/docker-clean
```

---

## 21.6 Đưa Công Cụ Vào PATH

```bash
# Check if ~/bin is in PATH
echo $PATH | grep -q "$HOME/bin" && echo "Set" || echo "Not set"

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 21.7 Để AI Giúp Mở Rộng Bộ Công Cụ

```bash
# Human: help me create a tool to analyze Nginx access logs

# AI:
cat > ~/bin/nginx-analyze << 'EOF'
#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <access_log_file>"
    exit 1
fi

FILE=$1

echo "=== Nginx Analysis: $FILE ==="
echo ""

echo "File size: $(du -h "$FILE" | cut -f1)"
echo "Total lines: $(wc -l < "$FILE")"
echo ""

echo "=== Top 10 IPs ==="
awk '{print $1}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== Top 10 URLs ==="
awk '{print $7}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== Status Code Distribution ==="
awk '{print $9}' "$FILE" | sort | uniq -c | sort -rn
EOF

chmod +x ~/bin/nginx-analyze
```

---

## 21.8 Cải Thiện Liên Tục

```bash
# Review toolkit annually
# - Which tools rarely used? Delete
# - Which tools can be improved?
# - Which repetitive tasks can be automated?

# Version control your toolkit
cd ~/bin
git init
git add .
git commit -m "Initial version"
```

---

## 21.9 Bài Tập

1. Tạo cấu trúc thư mục ~/bin của bạn
2. Viết các hàm thường dùng vào các thư viện có thể tái sử dụng
3. Viết một công cụ cho các tác vụ bạn lặp lại hàng ngày
4. Để AI giúp tạo công cụ phân tích Nginx log
5. Đưa bộ công cụ của bạn vào Git version control
