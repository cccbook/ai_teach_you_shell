# 18. 讀懂並修改別人的腳本

---

## 18.1 為什麼要讀懂別人的腳本

- 接手維護專案
- 使用開源工具
- Debug 問題
- 學習新技巧

AI 每天都會遇到陌生的腳本，所以學習如何快速理解他人寫的 Shell 腳本是必備技能。

---

## 18.2 初步觀察

### 第一步：看 shebang

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # 使用 bash
#!/bin/sh        # 使用 POSIX sh（兼容性更好）
#!/usr/bin/env python3  # Python 腳本
```

### 第二步：看許可權和大小

```bash
ls -la script.sh
wc -l script.sh
```

### 第三步：快速語法檢查

```bash
bash -n script.sh  # 只檢查語法，不執行
```

---

## 18.3 理解結構

### 典型結構

```bash
#!/bin/bash
# 註釋：腳本功能說明

# 設定
set -euo pipefail
VAR="value"

# 函式定義
function help() { ... }

# 主流程
main() { ... }

# 執行
main "$@"
```

### 快速找到主流程

```bash
# 找最後幾行
tail -20 script.sh

# 找函式定義
grep -n "^function\|^[a-z_]+\(\)" script.sh
```

---

## 18.4 追蹤變數

### 找出所有變數

```bash
# 找賦值
grep -E '^[A-Za-z_][A-Za-z0-9_]*=' script.sh

# 找使用
grep -o '\$[A-Za-z_][A-Za-z0-9_]*' script.sh | sort -u
```

### 理解變數作用域

```bash
# 全域變數（開頭）
MY_VAR="global"

# 區域變數（在函式內）
my_function() {
    local MY_LOCAL="local"
}
```

---

## 18.5 常用 grep 分析

```bash
# 找所有函式定義
grep -n "^[[:space:]]*function" script.sh

# 找所有條件判斷
grep -n "if\|\[\[" script.sh

# 找所有迴圈
grep -n "for\|while\|do\|done" script.sh

# 找所有命令替換
grep -n '\$(' script.sh

# 找所有 exit
grep -n "exit" script.sh
```

---

## 18.6 用 `awk` 提取結構

```bash
# 提取函式名稱
awk '/^[a-z_]+\(\)/ {print NR": "$0}' script.sh

# 提取條件分支
awk '/^\s*(if|case)/ {print NR": "$0}' script.sh

# 提取命令列參數
awk '/\$\{?[0-9]/{print NR": "$0}' script.sh
```

---

## 18.7 視覺化腳本結構

```bash
#!/bin/bash
# 視覺化工具

script=$1

echo "=== 結構分析：$script ==="
echo ""

echo "--- 函式 ---"
grep -n "^[[:space:]]*function\|^[[:space:]]*[a-z_][a-z_0-9]*\(\)" "$script"

echo ""
echo "--- 條件判斷 ---"
grep -n "if\|\[\[$\|case\|^[[:space:]]*then\|^[[:space:]]*esac" "$script"

echo ""
echo "--- 迴圈 ---"
grep -n "for\|while\|^do$\|^done$" "$script"

echo ""
echo "--- 外部命令 ---"
grep -oE '^[^#]*[a-z][a-z0-9-]+' "$script" | sort -u
```

---

## 18.8 安全檢查

### 檢查危險命令

```bash
# 找 rm -rf
grep -n "rm -rf" script.sh

# 找 sudo
grep -n "sudo" script.sh

# 找 >
grep -n ">" script.sh

# 找 `eval`
grep -n "eval" script.sh
```

### 檢查變數注入風險

```bash
# 找未加引號的變數
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh

# 找 user input
grep -n '\$1\|\$2\|read' script.sh
```

---

## 18.9 改寫陌生腳本

### 步驟 1：註釋理解

```bash
#!/bin/bash
# 讀取腳本，一邊讀一邊加註釋
# 2024-03-22 分析：這是備份腳本
# 作者：某人
# 用途：每日備份資料庫

# Step 1: 設定變數
# BACKUP_DIR: 備份目標目錄
BACKUP_DIR="/backup"
```

### 步驟 2：測試片段

```bash
# 提取並測試函式
# 把函式複製到新檔案測試
```

### 步驟 3：簡化

```bash
# 用更清晰的方式重寫
```

---

## 18.10 常見模式識別

### 初始化模式

```bash
# 常用初始化
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### 參數解析模式

```bash
# while + case 解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) help; exit 0 ;;
        -*) echo "Unknown"; exit 1 ;;
    esac
done
```

### 錯誤處理模式

```bash
# 典型錯誤處理
command || { echo "Failed"; exit 1; }
```

---

## 18.11 用 AI 幫你理解

```bash
#!/bin/bash
# 把腳本貼給 AI 讓它解釋

cat > /tmp/analyze.sh << 'HELPER'
#!/bin/bash
# 分析輸入的腳本，解釋每個部分

script=$(cat)

echo "=== AI 腳本分析 ==="
echo ""
echo "## 檔案頭"
head -10

echo ""
echo "## 函式列表"
grep -n "^function\|^[[:space:]]*[a-z_]*\(\)" 

echo ""
echo "## 可能的問題"
# 檢查危險操作
grep -n "rm -rf\|eval\|\$($" || echo "未發現明顯危險操作"

echo ""
echo "## 建議"
echo "- 可加入 set -euo pipefail"
echo "- 變數應加引號"
HELPER
```

---

## 18.12 練習題

1. 用 `grep` 和 `awk` 分析一個現有的 Shell 腳本
2. 找出腳本中的所有變數並理解它們的用途
3. 用 `bash -n` 檢查一個腳本的語法
4. 為一個沒有註釋的腳本加入註釋，說明每個部分的功能
