# 13. 自動化測試

---

## 13.1 為什麼要用 Shell 做測試

- 快速執行簡單的驗證
- 測試系統命令和腳本
- CI/CD 流程中的整合測試
- 迴歸測試現有腳本

---

## 13.2 基本測試框架

```bash
#!/bin/bash
set -euo pipefail

# 測試計數
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# 測試函式
test() {
    local name=$1
    local command=$2
    local expected=$3
    
    ((TESTS_RUN++))
    
    local actual
    actual=$(eval "$command" 2>/dev/null)
    
    if [[ "$actual" == "$expected" ]]; then
        echo "✓ $name"
        ((TESTS_PASSED++))
    else
        echo "✗ $name"
        echo "  預期：$expected"
        echo "  實際：$actual"
        ((TESTS_FAILED++))
    fi
}

# 執行測試
test "加法" "echo \$((1 + 1))" "2"
test "字串相等" "echo hello" "hello"
test "陣列長度" "echo \${#arr[@]}" "3"

# 報告結果
echo ""
echo "測試結果：$TESTS_PASSED/$TESTS_RUN 通過"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 測試檔案和目錄

```bash
#!/bin/bash
set -euo pipefail

# 測試檔案存在
test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ 檔案不存在：$file"; return 1; }
}

# 測試目錄存在
test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ 目錄不存在：$dir"; return 1; }
}

# 測試檔案內容包含
test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ 檔案不包含：$pattern"; return 1; }
}

# 測試檔案行數
test_file_lines() {
    local file=$1
    local expected=$2
    local actual=$(wc -l < "$file")
    [[ "$actual" -eq "$expected" ]] || { echo "✗ 行數錯誤：$actual vs $expected"; return 1; }
}
```

---

## 13.4 測試命令輸出

```bash
#!/bin/bash

# 測試命令成功執行
test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (退出碼: $?)"
        return 1
    fi
}

# 測試命令失敗
test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (正確失敗)"
    else
        echo "✗ $name (應該失敗但成功了)"
        return 1
    fi
}

# 測試輸出包含
test_output() {
    local name=$1
    local expected=$2
    shift 2
    
    local output=$("$@" 2>/dev/null)
    if [[ "$output" == *"$expected"* ]]; then
        echo "✓ $name"
    else
        echo "✗ $name"
        echo "  輸出不包含：$expected"
        return 1
    fi
}

# 使用
test_success "mkdir" mkdir -p testdir
test_success "ls" ls -la
test_failure "rm 不存在檔案" rm /nonexistent
test_output "echo hello" "hello" echo hello
```

---

## 13.5 實戰：測試一個專案初始化腳本

```bash
cat > test-init.sh << 'EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="testproject"

# 清理
rm -rf "$PROJECT_NAME"

# 執行初始化
"$SCRIPT_DIR/init-project.sh" "$PROJECT_NAME"

# 驗證目錄結構
test -d "$PROJECT_NAME" || { echo "✗ 專案目錄未建立"; exit 1; }
test -d "$PROJECT_NAME/src" || { echo "✗ src 目錄未建立"; exit 1; }
test -d "$PROJECT_NAME/tests" || { echo "✗ tests 目錄未建立"; exit 1; }
test -d "$PROJECT_NAME/docs" || { echo "✗ docs 目錄未建立"; exit 1; }

# 驗證檔案
test -f "$PROJECT_NAME/README.md" || { echo "✗ README 未建立"; exit 1; }
test -f "$PROJECT_NAME/src/__init__.py" || { echo "✗ __init__.py 未建立"; exit 1; }

# 清理測試資料
rm -rf "$PROJECT_NAME"

echo "✅ 所有測試通過"
EOF

chmod +x test-init.sh
```

---

## 13.6 測試覆蓋率

```bash
#!/bin/bash

# 計算測試覆蓋率
calculate_coverage() {
    local total=$1
    local covered=$2
    
    local percent=$((covered * 100 / total))
    echo "覆蓋率：${percent}%"
    
    if [[ $percent -lt 50 ]]; then
        echo "⚠️ 覆蓋率過低"
        return 1
    fi
}

# 測試每個函式是否被呼叫
TRACE_FILE="/tmp/trace.log"
> "$TRACE_FILE"

test_with_trace() {
    local name=$1
    local func=$2
    
    # 執行並追蹤
    "$@" 2>&1 | tee -a "$TRACE_FILE"
    
    if grep -q "$func" "$TRACE_FILE"; then
        echo "✓ $name (函式 $func 被呼叫)"
    else
        echo "✗ $name (函式 $func 未被呼叫)"
    fi
}
```

---

## 13.7 持續測試

```bash
cat > scripts/test.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔬 執行測試..."

# 設定顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAILED=0

run_test() {
    local name=$1
    local cmd=$2
    
    echo -n "測試：$name ... "
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
    fi
}

# 測試初始化腳本
run_test "初始化腳本存在" "[[ -x scripts/init-project.sh ]]"
run_test "初始化腳本執行成功" "scripts/init-project.sh testrun"

# 測試建置腳本
run_test "建置腳本存在" "[[ -f scripts/build.sh ]]"

# 測試部署腳本
run_test "部署腳本存在" "[[ -f scripts/deploy.sh ]]"

# 清理測試資料
rm -rf testrun

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ 所有測試通過${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED 個測試失敗${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.8 練習題

1. 寫一個測試框架，包含 `test_eq`、`test_contains`、`test_success` 函式
2. 為你的一個腳本寫 5 個測試案例
3. 建立一個 CI 友好的測試腳本，輸出 TAP 格式
4. 測試一個批次處理腳本，確保它正確處理所有檔案
