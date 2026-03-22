# 21. สร้างกล่องเครื่องมือ Shell AI ของคุณ

---

## 21.1 ทำไมต้องมีกล่องเครื่องมือ

เมื่อคุณพบว่าตัวเองทำสิ่งเดิมซ้ำๆ ก็ถึงเวลาที่ต้องทำให้เป็นอัตโนมัติและรวบรวมไว้ในกล่องเครื่องมือ

AI เก่งเป็นพิเศษใน:
- สร้างเครื่องมืออย่างรวดเร็ว
- ห่อเวิร์กโฟลว์ที่ซับซ้อนเป็นคำสั่งง่ายๆ
- ปรับปรุงสคริปต์ที่ใช้บ่อยอย่างต่อเนื่อง

---

## 21.2 โครงสร้างไดเรกทอรีของกล่องเครื่องมือ

```
~/bin/
├── lib/              # ไลบรารีที่ใช้ร่วมกัน
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── project/          # เทมเพลตโปรเจกต์
│   ├── python/
│   ├── nodejs/
│   └── static-site/
├── scripts/          # สคริปต์เครื่องมือ
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # เครื่องมือที่รันได้
    └── monitor       # เครื่องมือที่รันได้
```

---

## 21.3 สร้างไลบรารีของคุณ

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

## 21.4 เครื่องมือที่ใช้งานได้จริง: git-clean

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

## 21.5 เครื่องมือที่ใช้งานได้จริง: docker-clean

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

echo "Docker cleanup complete"
docker system df
EOF

chmod +x ~/bin/docker-clean
```

---

## 21.6 ทำให้เครื่องมือพร้อมใช้ใน PATH

```bash
# ตรวจสอบว่า ~/bin อยู่ใน PATH หรือไม่
echo $PATH | grep -q "$HOME/bin" && echo "Set" || echo "Not set"

# เพิ่มใน PATH (เพิ่มใน ~/.bashrc หรือ ~/.zshrc)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 21.7 ให้ AI ช่วยขยายกล่องเครื่องมือ

```bash
# มนุษย์: ช่วยสร้างเครื่องมือวิเคราะห์ Nginx access logs

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

## 21.8 การปรับปรุงอย่างต่อเนื่อง

```bash
# ทบทวนกล่องเครื่องมือทุกปี
# - เครื่องมือไหนไม่ค่อยได้ใช้? ลบ
# - เครื่องมือไหนปรับปรุงได้?
# - งานซ้ำๆ อะไรที่ทำอัตโนมัติได้?

# ใส่กล่องเครื่องมือใน Git version control
cd ~/bin
git init
git add .
git commit -m "Initial version"
```

---

## 21.9 แบบฝึกหัด

1. สร้างโครงสร้างไดเรกทอรี ~/bin ของคุณ
2. เขียนฟังก์ชันที่ใช้บ่อยลงในไลบรารีที่ใช้ซ้ำได้
3. เขียนเครื่องมือสำหรับงานที่ทำซ้ำทุกวัน
4. ให้ AI ช่วยสร้างเครื่องมือวิเคราะห์ Nginx log
5. นำกล่องเครื่องมือของคุณใส่ใน Git version control
