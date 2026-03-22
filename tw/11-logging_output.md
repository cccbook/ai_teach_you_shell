# 11. 日誌與輸出

---

## 11.1 為什麼日誌重要

沒有日誌的腳本：
- 你不知道腳本執行到哪裡了
- 失敗時不知道原因
- 執行成功但不知道做了什麼

有日誌的腳本：
- 可以追蹤執行進度
- 失敗時有足夠資訊除錯
- 可以審計執行歷史

---

## 11.2 基本日誌級別

```bash
#!/bin/bash

# 定義日誌級別
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

log $DEBUG "這是除錯訊息"
log $INFO "這是資訊訊息"
log $WARN "這是警告訊息"
log $ERROR "這是錯誤訊息"
```

---

## 11.3 顏色輸出

```bash
#!/bin/bash

# ANSI 顏色碼
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# 彩色日誌
log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }
log_debug() { echo -e "${CYAN}[DEBUG]${NC} $@"; }

# 使用
log_info "安裝完成"
log_warn "使用預設設定"
log_error "連線失敗"
log_debug "變數值：$var"
```

### 進階樣式

```bash
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
REVERSE='\033[7m'

# 組合
ERROR_BOLD="${RED}${BOLD}"
echo -e "${ERROR_BOLD}這是粗體紅色錯誤${NC}"
```

---

## 11.4 輸出到檔案

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "應用程式啟動"
log "處理請求..."
log "應用程式關閉"
```

---

## 11.5 `tee`：同時輸出到螢幕和檔案

```bash
# 把輸出同時顯示和儲存
echo "Hello" | tee output.txt

# 附加模式
echo "World" | tee -a output.txt

# 錯誤輸出也捕獲
./script.sh 2>&1 | tee output.log

# 隱藏進度的 tee
make 2>&1 | tee build.log

# 安靜模式（不顯示進度）
make 2>&1 | grep -v "^make" | tee build.log
```

---

## 11.6 進度指示器

### 簡單點

```bash
echo -n "處理中"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " 完成"
```

### 進度條

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
    # 實際工作
    sleep 0.05
done
```

### 計數器

```bash
#!/bin/bash

count=0
total=50

while read -r file; do
    ((count++))
    echo -ne "\r已處理 $count / $total"
    # 實際工作
done < <(find . -type f -name "*.txt")

echo
```

---

## 11.7 安靜模式

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

log "這只在 verbose 模式顯示"
```

---

## 11.8 完整的日誌工具

```bash
cat > lib/logging.sh << 'EOF'
#!/bin/bash

# 日誌工具

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

### 使用日誌工具

```bash
#!/bin/bash

source lib/logging.sh

log_set_level DEBUG
log_to_file "/tmp/app.log"

info "應用程式啟動"
debug "讀取設定檔..."
warn "使用預設值"
error "無法連線到資料庫"
info "應用程式關閉"
```

---

## 11.9 `2>&1` 詳解

```bash
# 1 = stdout（標準輸出）
# 2 = stderr（標準錯誤）

# 把 stderr 導向 stdout
command 2>&1

# 把 stdout 導向檔案，stderr 顯示在螢幕
command > output.txt

# 把兩者都導向檔案
command > output.txt 2>&1

# 把兩者都導向 /dev/null（隱藏輸出）
command > /dev/null 2>&1

# 順序很重要！
command > output.txt 2>&1   # 正確：先導向檔案，再複製 stderr
command 2>&1 > output.txt    # 錯誤：先複製 stderr 到 stdout（此時還是螢幕），再導向檔案
```

---

## 11.10 速查表

| 語法 | 說明 |
|------|------|
| `echo "text"` | 基本輸出 |
| `echo -e "\033[31m"` | 彩色輸出 |
| `2>&1` | 把 stderr 導向 stdout |
| `> file` | 覆蓋寫入檔案 |
| `>> file` | 附加到檔案 |
| `tee file` | 同時輸出和儲存 |
| `tee -a file` | 附加模式 |
| `/dev/null` | 丟棄輸出 |
| `printf` | 格式化輸出 |

---

## 11.11 練習題

1. 寫一個腳本，用不同顏色顯示 INFO、WARN、ERROR 訊息
2. 用 `tee` 把輸出同時顯示和儲存到日誌檔案
3. 製作一個有進度條的檔案處理腳本
4. 建立一個日誌工具函式庫，支援檔案輸出和日誌級別
