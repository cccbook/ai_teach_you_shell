# 21. 나만의 AI Shell 도구 상자 만들기

---

## 21.1 왜 도구 상자가 필요한가

같은 일을 반복해서 하고 있다면, 자동화하여 도구 상자에 수집할 때입니다.

AI는 특히 다음과 같은 데 뛰어납니다:
- 빠르게 도구 생성
- 복잡한 워크플로우를 간단한 명령어로 래핑
- 자주 사용하는 스크립트 지속 개선

---

## 21.2 도구 상자 디렉토리 구조

```
~/bin/
├── lib/              # 공유 라이브러리
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── project/          # 프로젝트 템플릿
│   ├── python/
│   ├── nodejs/
│   └── static-site/
├── scripts/          # 도구 스크립트
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # 실행 가능한 도구
    └── monitor       # 실행 가능한 도구
```

---

## 21.3 라이브러리 만들기

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

## 21.4 실용적 도구: git-clean

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

## 21.5 실용적 도구: docker-clean

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

## 21.6 도구를 PATH에서 사용 가능하게 만들기

```bash
# ~/bin이 PATH에 있는지 확인
echo $PATH | grep -q "$HOME/bin" && echo "Set" || echo "Not set"

# PATH에 추가 (.bashrc 또는 .zshrc에 추가)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 21.7 AI에게 도구 확장 도와달라고 하기

```bash
# 인간: Nginx 액세스 로그를 분석하는 도구를 만들어줘

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

## 21.8 지속적 개선

```bash
# 매년 도구 상자 검토
# - 사용하지 않는 도구는 삭제
# - 개선할 수 있는 도구는 개선
# - 자동화할 수 있는 반복 작업은 무엇인가

# 도구 상자를 버전 관리
cd ~/bin
git init
git add .
git commit -m "Initial version"
```

---

## 21.9 연습 문제

1. ~/bin 디렉토리 구조를 만드세요
2. 자주 사용하는 함수를 재사용 가능한 라이브러리로 작성하세요
3. 매일 반복하는 작업에 대한 도구를 작성하세요
4. AI에게 Nginx 로그 분석 도구를 만들어달라고 하세요
5. 도구 상자를 Git 버전 관리 하세요
