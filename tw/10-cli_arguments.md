# 10. 參數解析與 CLI 工具

---

## 10.1 命令列參數基礎

```bash
#!/bin/bash

echo "腳本名：$0"
echo "第一個參數：$1"
echo "第二個參數：$2"
echo "第三個參數：${3:-default}"  # 預設值
echo "參數總數：$#"
echo "所有參數：$@"
```

### 執行

```bash
./script.sh foo bar
# 輸出：
# 腳本名：./script.sh
# 第一個參數：foo
# 第二個參數：bar
# 第三個參數：default
# 參數總數：2
# 所有參數：foo bar
```

---

## 10.2 簡單的參數解析

### 位置參數

```bash
#!/bin/bash

# 沒有參數時顯示幫助
if [[ $# -eq 0 ]]; then
    echo "用法: $0 <檔案>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "錯誤：檔案不存在"
    exit 1
fi

echo "處理 $FILE..."
```

### 處理可選參數

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "未知選項：$1"
            exit 1
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

$VERBOSE && echo "verbose 模式開啟"
[[ -n "$OUTPUT" ]] && echo "輸出到：$OUTPUT"
[[ -n "$FILE" ]] && echo "處理檔案：$FILE"
```

---

## 10.3 `getopts`：標準選項解析

```bash
#!/bin/bash

# 格式字串：每個字母是一個選項
# : 在前面表示選項後面需要參數
while getopts "hv:o:" opt; do
    case $opt in
        h)
            echo "幫助資訊"
            exit 0
            ;;
        v)
            echo "verbose 模式：$OPTARG"
            ;;
        o)
            echo "輸出檔案：$OPTARG"
            ;;
        \?)
            echo "無效選項：-$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "剩下的參數：$@"
```

### 選項格式

| 格式 | 意義 |
|------|------|
| `getopts "hv:"` | `-h` 無參數，`-v` 需要參數 |
| `getopts ":hv:"` | 忽略未知選項，用 `:` 開頭 |
| `OPTARG` | 當前選項的參數值 |
| `OPTIND` | 下一個要處理的參數索引 |

---

## 10.4 完整的 CLI 工具範例

```bash
cat > gitlike << 'EOF'
#!/bin/bash
set -euo pipefail

VERSION="1.0.0"

usage() {
    cat << USAGE
greet - 問候工具 v${VERSION}

用法:
    greet [選項] [名字]

選項:
    -h, --help      顯示幫助
    -v, --version   顯示版本
    -t, --time      顯示時間問候
    -f, --formal    正式問候

範例:
    greet Alice
    greet -f Alice
    greet -t
USAGE
}

main() {
    local formal=false
    local show_time=false
    local name="World"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                echo "greet v${VERSION}"
                exit 0
                ;;
            -t|--time)
                show_time=true
                shift
                ;;
            -f|--formal)
                formal=true
                shift
                ;;
            -*)
                echo "未知選項：$1"
                exit 1
                ;;
            *)
                name="$1"
                shift
                ;;
        esac
    done

    if $show_time; then
        local hour=$(date +%H)
        if [[ $hour -lt 12 ]]; then
            echo "早安"
        elif [[ $hour -lt 18 ]]; then
            echo "午安"
        else
            echo "晚安"
        fi
    fi

    if $formal; then
        echo "您好，尊貴的 ${name}。"
    else
        echo "你好，${name}！"
    fi
}

main "$@"
EOF

chmod +x gitlike
./gitlike Alice
./gitlike --formal --time Bob
```

---

## 10.5 互動式輸入

### `read`：讀取使用者輸入

```bash
#!/bin/bash

# 基本讀取
read -p "請輸入你的名字：" name
echo "你好，$name"

# 讀取密碼（不顯示）
read -sp "請輸入密碼：" password
echo

# 讀取多個值
read -p "輸入名字和年齡：" name age
echo "$name 是 $age 歲"

# 超時
read -t 5 -p "5 秒內輸入：" value
```

### 確認提示

```bash
confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

if confirm "確定要刪除嗎？"; then
    echo "執行刪除..."
fi
```

---

## 10.6 選單式介面

```bash
#!/bin/bash

PS3="請選擇操作: "

select choice in "建立專案" "刪除專案" "退出"; do
    case $choice in
        "建立專案")
            echo "建立中..."
            ;;
        "刪除專案")
            echo "刪除中..."
            ;;
        "退出")
            echo "再見！"
            exit 0
            ;;
        *)
            echo "無效選擇，請重新選擇"
            ;;
    esac
done
```

### 輸出

```
1) 建立專案
2) 刪除專案
3) 退出
請選擇操作: 1
建立中...
```

---

## 10.7 進度條

```bash
progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r[%s%s] %3d%%" \
        "$(printf '#%.0s' $(seq 1 $completed))" \
        "$(printf '.%.0s' $(seq 1 $remaining))" \
        "$percent"
    
    [[ $current -eq $total ]] && echo
}

# 使用
for i in {1..100}; do
    progress $i 100
    sleep 0.05
done
```

---

## 10.8 速查表

| 語法 | 說明 |
|------|------|
| `$0` | 腳本名稱 |
| `$1`, `$2`... | 位置參數 |
| `$#` | 參數個數 |
| `${var:-default}` | 預設值 |
| `getopts "hv:" opt` | 解析選項 |
| `$OPTARG` | 當前選項的參數 |
| `$OPTIND` | 下一個參數索引 |
| `read -p "提示：" var` | 讀取輸入 |
| `read -s var` | 隱藏輸入（密碼） |
| `read -t 5 var` | 5 秒超時 |
| `select` | 選單介面 |

---

## 10.9 練習題

1. 寫一個 CLI 工具，接受 `-n` 參數指定次數，`-v` 顯示詳細資訊
2. 用 `getopts` 解析 `-h`（幫助）、`-o`（輸出檔案）選項
3. 寫一個確認函式，只有回答 y 才執行刪除
4. 用 `select` 製作一個簡易的計算機選單
