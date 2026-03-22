# 9. 錯誤處理

---

## 9.1 為什麼錯誤處理重要

沒有錯誤處理的腳本：
- 一個命令失敗後，繼續執行錯誤的操作
- 可能刪除錯誤的檔案
- 可能覆蓋重要的資料
- 可能讓系統進入不一致的狀態

有錯誤處理的腳本：
- 遇到錯誤立即停止
- 提供有意義的錯誤訊息
- 可以在退出前做清理工作

---

## 9.2 退出碼（Exit Code）

每一個命令執行後，都會返回一個退出碼：

- `0`：成功
- `非 0`：失敗

```bash
# 查看上一個命令的退出碼
ls /tmp
echo $?  # 輸出：0（如果成功）

ls /nonexistent
echo $?  # 輸出：2（如果失敗，數字因命令而異）
```

### 在條件判斷中使用

```bash
# 如果成功才執行
if ls /tmp &>/dev/null; then
    echo "目錄存在"
fi

# 或用 && 和 ||
ls /tmp && echo "成功" || echo "失敗"
```

---

## 9.3 `set -e`：遇到錯誤就停止

```bash
#!/bin/bash
set -e

mkdir -p backup
cp important.txt backup/  # 如果這個失敗，腳本就會停止
rm important.txt          # 不會執行到這裡
```

### 何時使用

幾乎所有腳本都應該用 `set -e`：
- 初始化腳本
- 部署腳本
- 自動化測試腳本

### 何時不使用

- 允許某個步驟失敗的腳本
- 需要嘗試多個選項的腳本

```bash
# 錯誤示範：set -e 下，這會導致腳本提前退出
#!/bin/bash
set -e

# 嘗試多種可能的工具
which rg || which grep  # 如果都找不到，腳本就退出
```

---

## 9.4 `set -u`：使用未定義變數时报错

```bash
#!/bin/bash
set -u

echo $undefined_var
# 輸出：bash: undefined_var: unbound variable
```

### 組合使用

```bash
#!/bin/bash
set -euo pipefail

# -e：遇到錯誤停止
# -u：使用未定義變數时报错
# -o pipefail：管道中任何一個命令失敗就失敗
```

**這是 AI 寫腳本時的標準開頭！**

---

## 9.5 `trap`：優雅地處理錯誤

### 基本用法

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "清理中..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# 主程式
echo "開始處理..."
```

### 捕獲錯誤

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    echo "❌ 腳本在第 $1 行失敗，退出碼：$exit_code"
    exit $exit_code
}

trap 'error_handler $LINENO' ERR

# 主程式
echo "開始..."
false  # 這會失敗
echo "這行不會執行"
```

### 常見的 trap 用途

```bash
# Ctrl+C 中斷時清理
trap 'echo "中斷，正在清理..."; rm -f /tmp/lock; exit 130' INT TERM

# 當腳本被 kill 時清理
trap 'cleanup' EXIT

# 偵錯模式（見下一章）
trap 'echo "執行: $BASH_COMMAND"' DEBUG
```

---

## 9.6 自訂錯誤函式

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "❌ $@" >&2
    exit 1
}

warn() {
    echo "⚠️ $@"
}

need_command() {
    command -v "$1" &>/dev/null || die "需要命令：$1"
}

need_file() {
    [[ -f "$1" ]] || die "需要檔案：$1"
}

need_dir() {
    [[ -d "$1" ]] || die "需要目錄：$1"
}

# 使用
need_command git
need_file config.yaml
need_dir data/

echo "所有檢查通過"
```

---

## 9.7 實戰：安全的部署腳本

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $@"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

# 清理函式
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "部署失敗，正在回滾..."
        # 回滾邏輯
        ssh "$DEPLOY_HOST" "cp -r $DEPLOY_PATH.backup/* $DEPLOY_PATH/"
    fi
    rm -f /tmp/deploy.lock
    exit $exit_code
}
trap cleanup EXIT

# 檢查參數
if [[ $# -lt 2 ]]; then
    error "用法: $0 <host> <path>"
    exit 1
fi

DEPLOY_HOST="$1"
DEPLOY_PATH="$2"

# 檢查必要工具
for cmd in ssh rsync; do
    command -v "$cmd" &>/dev/null || die "需要命令：$cmd"
done

# 檢查是否有其他部署在執行
if ssh "$DEPLOY_HOST" "test -f $DEPLOY_PATH/.deploying" 2>/dev/null; then
    die "主機 $DEPLOY_HOST 正在部署中"
fi

log "開始部署到 $DEPLOY_HOST:$DEPLOY_PATH"

# 建立備份
ssh "$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$(date +%s)"
log "備份完成"

# 建立部署標記
ssh "$DEPLOY_HOST" "touch $DEPLOY_PATH/.deploying"

# 上傳新版本
rsync -avz --delete ./dist/ "$DEPLOY_HOST:$DEPLOY_PATH/"

# 移除部署標記
ssh "$DEPLOY_HOST" "rm $DEPLOY_PATH/.deploying"

# 重啟服務
ssh "$DEPLOY_HOST" "systemctl restart myapp"

log "部署完成！"
EOF

chmod +x deploy.sh
```

---

## 9.8 驗證函式

```bash
#!/bin/bash
set -euo pipefail

# 驗證 email 格式
is_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# 驗證數字範圍
is_between() {
    [[ $1 =~ ^[0-9]+$ ]] && [[ $1 -ge $2 ]] && [[ $1 -le $3 ]]
}

# 驗證 URL
is_url() {
    [[ "$1" =~ ^https?:// ]]
}

# 使用
if is_email "user@example.com"; then
    echo "有效的 email"
fi
```

---

## 9.9 速查表

| 指令 | 說明 |
|------|------|
| `$?` | 上一個命令的退出碼 |
| `set -e` | 遇到錯誤就停止 |
| `set -u` | 使用未定義變數时报错 |
| `set -o pipefail` | 管道中任何命令失敗就失敗 |
| `set -euo pipefail` | 組合使用（推薦） |
| `trap 'func' EXIT` | 退出時執行 |
| `trap 'func' ERR` | 發生錯誤時執行 |
| `trap 'func' INT` | Ctrl+C 時執行 |
| `exit 1` | 以錯誤碼 1 退出 |

---

## 9.10 練習題

1. 寫一個腳本，用 `set -euo pipefail` 並在失敗時輸出「發生錯誤」
2. 建立一個 `die()` 函式，在錯誤時輸出訊息並退出
3. 用 `trap` 在腳本退出時顯示「再見」
4. 寫一個部署腳本，在失敗時自動回滾
