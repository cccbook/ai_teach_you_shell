# 11. 日志与输出

---

## 11.1 为什么日志重要

没有日志的脚本：
- 你不知道脚本执行到哪里了
- 失败时不知道原因
- 执行成功但不知道做了什么

有日志的脚本：
- 可以追踪执行进度
- 失败时有足够信息调试
- 可以审计执行历史

---

## 11.2 基本日志级别

```bash
#!/bin/bash

# 定义日志级别
DEBUG=0
INFO=1
WARN=2
ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$INFO}

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ $level -ge $LOG_LEVEL ]]; then
        echo "[$timestamp] $message"
    fi
}

log $DEBUG "这是调试消息"
log $INFO "这是信息消息"
log $WARN "这是警告消息"
log $ERROR "这是错误消息"
```

---

## 11.3 颜色输出

```bash
#!/bin/bash

# ANSI 颜色码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# 彩色日志
log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }
log_debug() { echo -e "${CYAN}[DEBUG]${NC} $@"; }

# 使用
log_info "安装完成"
log_warn "使用默认设置"
log_error "连接失败"
log_debug "变量值：$var"
```

### 进阶样式

```bash
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
REVERSE='\033[7m'

# 组合
ERROR_BOLD="${RED}${BOLD}"
echo -e "${ERROR_BOLD}这是粗体红色错误${NC}"
```

---

## 11.4 输出到文件

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "应用程序启动"
log "处理请求..."
log "应用程序关闭"
```

---

## 11.5 `tee`：同时输出到屏幕和文件

```bash
# 把输出同时显示和保存
echo "Hello" | tee output.txt

# 附加模式
echo "World" | tee -a output.txt

# 错误输出也捕获
./script.sh 2>&1 | tee output.log

# 隐藏进度的 tee
make 2>&1 | tee build.log

# 安静模式（不显示进度）
make 2>&1 | grep -v "^make" | tee build.log
```

---

## 11.6 进度指示器

### 简单点

```bash
echo -n "处理中"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " 完成"
```

### 进度条

```bash
#!/bin/bash

draw_progress() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local chars=$((width * current / total))
    
    printf "\r["
    printf "%${chars}s" | tr ' ' '='
    printf "%$((width - chars))s" | tr ' ' '-'
    printf "] %3d%%" "$percent"
    
    [[ $current -eq $total ]] && echo
}

# 使用
total=100
for i in $(seq 1 $total); do
    draw_progress $i $total
    # 实际工作
    sleep 0.05
done
```

### 计数器

```bash
#!/bin/bash

count=0
total=50

while read -r file; do
    ((count++))
    echo -ne "\r已处理 $count / $total"
    # 实际工作
done < <(find . -type f -name "*.txt")

echo
```

---

## 11.7 安静模式

```bash
#!/bin/bash

VERBOSE=false

log() {
    $VERBOSE && echo "[LOG] $@" || true
}

while getopts "v" opt; do
    case $opt in
        v) VERBOSE=true ;;
    esac
done

log "这只在 verbose 模式显示"
```

---

## 11.8 完整的日志工具

```bash
cat > lib/logging.sh << 'EOF'
#!/bin/bash

# 日志工具

declare -A LOG_COLORS=(
    [DEBUG]='\033[0;36m'
    [INFO]='\033[0;32m'
    [WARN]='\033[1;33m'
    [ERROR]='\033[0;31m'
)

declare LOG_LEVEL=INFO
declare LOG_FILE=""
declare LOG_TIMESTAMP=true

_log() {
    local level=$1
    shift
    local message="$@"
    local color="${LOG_COLORS[$level]:-}"
    local timestamp=""
    
    $LOG_TIMESTAMP && timestamp=$(date '+%Y-%m-%d %H:%M:%S')" "
    
    local output="${color}[${level}]${NC} ${timestamp}${message}"
    echo -e "$output"
    
    if [[ -n "$LOG_FILE" ]]; then
        echo "[${level}] ${timestamp}${message}" >> "$LOG_FILE"
    fi
}

debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && _log DEBUG "$@"; }
info() { _log INFO "$@"; }
warn() { _log WARN "$@"; }
error() { _log ERROR "$@"; }

log_set_level() {
    case "$1" in
        debug|DEBUG) LOG_LEVEL=DEBUG ;;
        info|INFO) LOG_LEVEL=INFO ;;
        warn|WARN) LOG_LEVEL=WARN ;;
        error|ERROR) LOG_LEVEL=ERROR ;;
    esac
}

log_to_file() {
    LOG_FILE="$1"
    touch "$LOG_FILE" || return 1
}

log_set_timestamp() {
    LOG_TIMESTAMP=${1:-true}
}
EOF
```

### 使用日志工具

```bash
#!/bin/bash

source lib/logging.sh

log_set_level DEBUG
log_to_file "/tmp/app.log"

info "应用程序启动"
debug "读取配置文件..."
warn "使用默认值"
error "无法连接到数据库"
info "应用程序关闭"
```

---

## 11.9 `2>&1` 详解

```bash
# 1 = stdout（标准输出）
# 2 = stderr（标准错误）

# 把 stderr 导向 stdout
command 2>&1

# 把 stdout 导向文件，stderr 显示在屏幕
command > output.txt

# 把两者都导向文件
command > output.txt 2>&1

# 把两者都导向 /dev/null（隐藏输出）
command > /dev/null 2>&1

# 顺序很重要！
command > output.txt 2>&1   # 正确：先导向文件，再复制 stderr
command 2>&1 > output.txt    # 错误：先复制 stderr 到 stdout（此时还是屏幕），再导向文件
```

---

## 11.10 速查表

| 语法 | 说明 |
|------|------|
| `echo "text"` | 基本输出 |
| `echo -e "\033[31m"` | 彩色输出 |
| `2>&1` | 把 stderr 导向 stdout |
| `> file` | 覆盖写入文件 |
| `>> file` | 附加到文件 |
| `tee file` | 同时输出和保存 |
| `tee -a file` | 附加模式 |
| `/dev/null` | 丢弃输出 |
| `printf` | 格式化输出 |

---

## 11.11 练习题

1. 写一个脚本，用不同颜色显示 INFO、WARN、ERROR 消息
2. 用 `tee` 把输出同时显示和保存到日志文件
3. 制作一个有进度条的文件处理脚本
4. 创建一个日志工具函数库，支持文件输出和日志级别
