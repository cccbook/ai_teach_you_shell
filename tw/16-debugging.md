# 16. 除錯心法

---

## 16.1 AI 的除錯思維

人類遇到錯誤時：慌張、上網搜尋、複製貼上
AI 遇到錯誤時：分析錯誤訊息、推論原因、執行修復

AI 的除錯流程：
```
觀察錯誤輸出 → 理解錯誤類型 → 定位問題 → 修復 → 驗證
```

---

## 16.2 `bash -x`：追蹤執行

最簡單的除錯方法：加 `-x` 參數

```bash
bash -x script.sh
```

會輸出每一行執行的命令前面加 `+`：

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### 只想除錯某一段

```bash
#!/bin/bash

# 正常執行
echo "這行不會顯示"
set -x
# 這裡開始除錯
name="Alice"
echo "Hello, $name"
set +x
# 除錯結束
echo "這行不會顯示"
```

---

## 16.3 `set -v`：原始輸入模式

```bash
bash -v script.sh
```

會輸出 Shell 讀到的**原始行**，在命令擴展之前：

```bash
echo "Hello"
# 輸出：echo "Hello"
Hello
```

---

## 16.4 在腳本中設定除錯模式

```bash
#!/bin/bash

# 在腳本開頭開啟除錯
set -x
set -v

# ... 腳本內容 ...

set +x
set +v
```

### ERRDEBUG

```bash
#!/bin/bash
set -euo pipefail

# 每個命令失敗時輸出
DEBUGGING=true
if $DEBUGGING; then
    trap 'echo "失敗的命令: $BASH_COMMAND"' ERR
fi
```

---

## 16.5 常見錯誤及修復

### 錯誤 1：檔案權限不足

```bash
# 錯誤
./script.sh
# 輸出：Permission denied

# 修復
chmod +x script.sh
./script.sh
```

### 錯誤 2：找不到命令

```bash
# 錯誤
python script.py
# 輸出：command not found: python

# 修復：用完整路徑
/usr/bin/python3 script.py

# 或確認路徑
which python3
```

### 錯誤 3：變數未定義

```bash
#!/bin/bash
set -u

echo $undefined_var
# 輸出：bash: undefined_var: unbound variable

# 修復：給預設值
echo ${undefined_var:-default}
```

### 錯誤 4：引號問題

```bash
# 錯誤
file="my document.txt"
ls $file
# 輸出：ls: my: No such file or directory

# 修復：加引號
ls "$file"
```

### 錯誤 5：空格當分隔符

```bash
# 錯誤
for f in $(ls *.txt); do
    echo "$f"
done
# 輸出可能不預期

# 修復：用 IFS 或 read
while IFS= read -r f; do
    echo "$f"
done < <(ls *.txt)
```

---

## 16.6 `echo` 除錯法

當 `-x` 不夠用時，手動加入 `echo`：

```bash
#!/bin/bash

echo "DEBUG: 進入函式"
echo "DEBUG: 參數 = $@"

process() {
    echo "DEBUG: 在 process 中"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
    echo "DEBUG: 離開 process"
}
```

---

## 16.7 使用 `set -e`

```bash
#!/bin/bash
set -euo pipefail

# 任何命令失敗就停止
mkdir -p backup
cp important.txt backup/  # 如果失敗，腳本就停止
rm important.txt         # 不會執行到這裡
```

### 排除特定命令

```bash
#!/bin/bash
set -euo pipefail

# 這個命令可能失敗，但我們不在乎
command_that_might_fail || true

# 或用子 shell
(set +e; command_might_fail; true)
```

---

## 16.8 trace-trap：追蹤函式呼叫

```bash
#!/bin/bash

# 每執行一個命令就呼叫一次
trap 'echo "執行: $BASH_COMMAND (行: $LINENO)"' DEBUG

func1() {
    echo "在 func1 中"
    func2
}

func2() {
    echo "在 func2 中"
}

func1
```

---

## 16.9 檢查退出碼

```bash
#!/bin/bash

command1
echo "command1 退出碼: $?"

command2
echo "command2 退出碼: $?"

# 或組合
command1 || echo "command1 失敗了"
command2 && echo "command2 成功了"
```

---

## 16.10 常用除錯命令

```bash
# 檢查語法（不執行）
bash -n script.sh

# 追蹤執行
bash -x script.sh

# 詳細模式
bash -v script.sh

# 顯示所有命令
bash -x script.sh

# 組合
bash -xv script.sh
```

---

## 16.11 練習題

1. 用 `bash -x` 執行一個腳本，觀察輸出格式
2. 在腳本中使用 `set -x` 只除錯某個函式
3. 找一個會失敗的命令，分析錯誤訊息並修復
4. 用 `trap` 製作一個優雅的錯誤處理
