# 8. 變數與函式

---

## 8.1 變數的基礎

### 基本賦值

```bash
# 字串
name="Alice"
greeting="Hello, World!"

# 數字
age=25
count=0

# 空值
empty=
empty2=""
```

### 讀取變數

```bash
echo $name
echo ${name}    # 建議用這個形式，更明確

# 在雙引號中使用
echo "我叫 ${name}"
```

### 避免常見錯誤

```bash
# 錯誤：等號兩邊有空格
name = "Alice"   # 會被當成命令執行

# 錯誤：未加引號
greeting=Hello World  # 只會 echo "Hello"

# 正確：
name="Alice"
greeting="Hello World"
```

---

## 8.2 引號的藝術

### 雙引號 `"`

會展開變數和命令替換

```bash
name="Alice"
echo "Hello, $name"           # Hello, Alice
echo "今天是 $(date +%Y)"     # 今天 是 2026
```

### 單引號 `'`

原樣輸出，不展開任何東西

```bash
name="Alice"
echo 'Hello, $name'           # Hello, $name
echo '今天是 $(date +%Y)'     # 今天 是 $(date +%Y)
```

### 無引號

盡量避免使用，除非你確定變數值不包含空白

```bash
# 有風險
file=my document.txt
ls $file  # 會出錯

# 安全
file="my document.txt"
ls "$file"
```

---

## 8.3 特殊變數

```bash
$0          # 腳本名稱
$1, $2...   # 命令列參數
$#          # 參數個數
$@          # 所有參數（個別）
$*          # 所有參數（合併成一個）
$?          # 上一個命令的退出碼
$$          # 目前程序的 PID
$!          # 上一個背景程序的 PID
$-          # 目前 shell 的選項
```

### 範例

```bash
#!/bin/bash
echo "腳本名：$0"
echo "第一個參數：$1"
echo "第二個參數：$2"
echo "參數總數：$#"
echo "所有參數：$@"

# 執行 ./script.sh foo bar
# 輸出：
# 腳本名：./script.sh
# 第一個參數：foo
# 第二個參數：bar
# 參數總數：2
# 所有參數：foo bar
```

---

## 8.4 陣列

### 基本用法

```bash
# 定義陣列
colors=("red" "green" "blue")

# 讀取元素
echo ${colors[0]}    # red
echo ${colors[1]}    # green
echo ${colors[2]}    # blue

# 讀取所有元素
echo ${colors[@]}    # red green blue

# 陣列長度
echo ${#colors[@]}   # 3

# 取得最後一個元素
echo ${colors[-1]}   # blue
```

### 關聯陣列（Bash 4+）

```bash
declare -A user
user["name"]="Alice"
user["email"]="alice@example.com"

echo ${user["name"]}    # Alice
echo ${!user[@]}        # name email
```

### 實用範例

```bash
# 讀取目錄中的檔案
files=(*.txt)
echo "找到 ${#files[@]} 個 .txt 檔案"

# 讀取命令輸出到陣列
mapfile -t lines < file.txt
echo "檔案有 ${#lines[@]} 行"
```

---

## 8.5 函式的基礎

### 定義函式

```bash
# 方式 1：function 關鍵字
function greet {
    echo "Hello!"
}

# 方式 2：直接定義（推薦）
greet() {
    echo "Hello!"
}
```

### 函式參數

```bash
greet() {
    echo "Hello, $1!"
}

greet "Alice"    # Hello, Alice!
greet "Bob"      # Hello, Bob!
```

### 返回值

```bash
# return：用於退出碼（0-255）
check() {
    if [[ $1 -gt 10 ]]; then
        return 0  # 成功
    else
        return 1  # 失敗
    fi
}

if check 15; then
    echo "大於 10"
fi
```

---

## 8.6 區域變數

```bash
counter() {
    local count=0
    ((count++))
    echo $count
}
```

### 為什麼要 `local`？

```bash
count=0

increment() {
    local count=1
    ((count++))
    echo "函式內: $count"
}

increment
echo "函式外: $count"  # 仍是 0，因為 local 保護了外部變數
```

---

## 8.7 函式庫

### 建立函式庫

```bash
cat > lib.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date +%H:%M:%S)] $@"
}

error() {
    echo "[$(date +%H:%M:%S)] ERROR: $@" >&2
}

confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}
EOF
```

### 使用函式庫

```bash
#!/bin/bash

source lib.sh

log "開始處理"
error "發生了問題"
confirm "確定要繼續？" && echo "繼續執行"
```

---

## 8.8 遞迴函式

```bash
# 計算階乘
factorial() {
    if [[ $1 -le 1 ]]; then
        echo 1
    else
        local prev=$(factorial $(( $1 - 1 )))
        echo $(( $1 * prev ))
    fi
}

factorial 5  # 輸出：120
```

---

## 8.9 實戰：完整的專案初始化腳本

```bash
cat > init-project.sh << 'EOF'
#!/bin/bash
set -euo pipefail

PROJECT_NAME="${1:-myproject}"

log() { echo "📦 $@"; }
success() { echo "✅ $@"; }
error() { echo "❌ $@" >&2; }

create_project() {
    log "建立專案：${PROJECT_NAME}"
    
    mkdir -p "${PROJECT_NAME}"/{src,tests,docs,scripts}
    
    cat > "${PROJECT_NAME}/README.md" << MD
# ${PROJECT_NAME}

MD

    cat > "${PROJECT_NAME}/src/__init__.py" << MD
"""${PROJECT_NAME}"""
MD

    success "專案建立完成"
    tree "${PROJECT_NAME}"
}

create_project
EOF

chmod +x init-project.sh
./init-project.sh myblog
```

---

## 8.10 速查表

| 主題 | 語法 | 說明 |
|------|------|------|
| 賦值 | `var=value` | 等號兩邊不能有空格 |
| 讀取 | `$var` 或 `${var}` | 建議用 `${var}` |
| 雙引號 | `"..."` | 展開變數和命令 |
| 單引號 | `'...'` | 不展開任何東西 |
| 命令列參數 | `$1`, `$2`, `$@` | 取得參數 |
| 函式 | `name() { }` | 推薦的函式定義方式 |
| 區域變數 | `local var=value` | 只在函式內有效 |
| 陣列 | `arr=(a b c)` | 支援索引和關聯 |
| source | `source file.sh` | 載入函式庫 |

---

## 8.11 練習題

1. 寫一個腳本，接受名字和年齡參數，輸出「X 歲的 Y 你好！」
2. 建立一個包含 `log` 和 `error` 函式的函式庫，並在另一個腳本中使用它
3. 寫一個遞迴函式計算費波那契數列
4. 用 `mapfile` 讀取一個檔案的每一行到陣列，然後倒序輸出
