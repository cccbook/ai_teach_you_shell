# 21. 打造你的 AI Shell 工具箱

---

## 21.1 为什么需要工具箱

当你发现自己在重复做同样的事，就该把它自动化并收集到工具箱。

AI 特别擅长：
- 快速建立工具
- 把复杂流程封装成简单命令
- 持续优化常用脚本

---

## 21.2 工具箱目录结构

```
~/bin/
├── lib/              # 共用函数库
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── project/          # 项目模板
│   ├── python/
│   ├── nodejs/
│   └── static-site/
├── scripts/          # 工具脚本
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # 可执行工具
    └── monitor       # 可执行工具
```

---

## 21.3 建立你的函数库

### logging.sh

```bash
cat > ~/bin/lib/logging.sh << 'EOF'
#!/bin/bash

# 日志工具
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

# 确认命令存在
need_command() {
    command -v "$1" &>/dev/null || {
        echo "需要命令：$1"
        exit 1
    }
}

# 确认文件存在
need_file() {
    [[ -f "$1" ]] || {
        echo "需要文件：$1"
        exit 1
    }
}

# 确认目录存在
need_dir() {
    [[ -d "$1" ]] || {
        echo "需要目录：$1"
        exit 1
    }
}
EOF
```

---

## 21.4 实用工具：git-clean

```bash
cat > ~/bin/git-clean << 'EOF'
#!/bin/bash
set -euo pipefail

# 清理 Git 无用文件

DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=true; shift ;;
        *) shift ;;
    esac
done

if $DRY_RUN; then
    echo "[DRY-RUN] 即将删除："
fi

# 删除已合并的分支
git branch --merged main | grep -v "main\|master\|develop" | while read branch; do
    if $DRY_RUN; then
        echo "  删除分支：$branch"
    else
        git branch -d "$branch"
        echo "已删除：$branch"
    fi
done

# 清理暂存文件
git clean -n -d
EOF

chmod +x ~/bin/git-clean
```

---

## 21.5 实用工具：docker-clean

```bash
cat > ~/bin/docker-clean << 'EOF'
#!/bin/bash
set -euo pipefail

# 清理 Docker 资源

echo "停止所有容器..."
docker stop $(docker ps -aq) 2>/dev/null || true

echo "删除已停止的容器..."
docker container prune -f

echo "删除未使用的镜像..."
docker image prune -af

echo "删除未使用的网络..."
docker network prune -f

echo "删除构建缓存..."
docker builder prune -af

echo "✅ Docker 清理完成"
docker system df
EOF

chmod +x ~/bin/docker-clean
```

---

## 21.6 实用工具：log-parse

```bash
cat > ~/bin/log-parse << 'EOF'
#!/bin/bash

# 分析日志文件

if [[ $# -lt 1 ]]; then
    echo "用法: $0 <日志文件> [条件]"
    exit 1
fi

FILE=$1
PATTERN=${2:-""}

echo "=== 日志分析：$FILE ==="
echo ""

echo "文件大小：$(du -h "$FILE" | cut -f1)"
echo "总行数：$(wc -l < "$FILE")"
echo ""

if [[ -n "$PATTERN" ]]; then
    echo "包含 '$PATTERN' 的行数：$(grep -c "$PATTERN" "$FILE")"
fi

echo ""
echo "=== 错误统计 ==="
grep -i "error\|fail\|exception" "$FILE" | awk '{print $NF}' | sort | uniq -c | sort -rn | head -10

echo ""
echo "=== HTTP 状态码分布 ==="
grep -oE '"[0-9]{3}"' "$FILE" | tr -d '"' | sort | uniq -c | sort -rn
EOF

chmod +x ~/bin/log-parse
```

---

## 21.7 项目模板：Python 项目

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
# 你的依赖
MD

cat > "$NAME/.gitignore" << MD
__pycache__/
*.py[cod]
.env
.venv/
MD

echo "✅ Python 项目 $NAME 建立完成"
EOF
```

---

## 21.8 让工具在 PATH 中

```bash
# 确认 ~/bin 在 PATH 中
echo $PATH | grep -q "$HOME/bin" && echo "已设定" || echo "未设定"

# 加入 PATH（加到 ~/.bashrc 或 ~/.zshrc）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 或直接在 ~/bin 建立链接
ln -s ~/bin/git-clean /usr/local/bin/git-clean
```

---

## 21.9 AI 帮你扩展工具箱

```bash
# 人类：帮我建立一个工具，分析 Nginx 访问日志

# AI：
cat > ~/bin/nginx-analize << 'EOF'
#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "用法: $0 <访问日志文件>"
    exit 1
fi

FILE=$1

echo "=== Nginx 分析：$FILE ==="
echo ""

echo "总请求数：$(wc -l < "$FILE")"
echo ""

echo "=== Top 10 IP ==="
awk '{print $1}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== Top 10 URL ==="
awk '{print $7}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== 状态码分布 ==="
awk '{print $9}' "$FILE" | sort | uniq -c | sort -rn
echo ""

echo "=== 每秒请求峰值 ==="
awk '{print $4}' "$FILE" | cut -d: -f2 | sort | uniq -c | sort -rn | head -5
EOF

chmod +x ~/bin/nginx-analize
```

---

## 21.10 持续优化

```bash
# 每年回顾工具箱
# - 哪些工具很少用？删除
# - 哪些工具可以改进？
# - 哪些重复任务可以自动化？

# 版本控制你的工具箱
cd ~/bin
git init
git add .
git commit -m "初始版本"
```

---

## 21.11 练习题

1. 建立你的 ~/bin 目录结构
2. 把常用的函数写成可重用的函数库
3. 为你每天重复做的事情写一个工具
4. 用 AI 帮你建立一个 Nginx 日志分析工具
5. 把工具箱放进 Git 版本控制