# 17. 效能優化

---

## 17.1 為什麼 Shell 效能重要

Shell 腳本通常用於：
- 批次處理大量檔案
- 自動化任務
- CI/CD 流程

一個慢的腳本可能讓整個流程延遲數小時。優化 Shell 腳本可以大幅提升效率。

---

## 17.2 避免外部命令

```bash
# 慢：用外部命令
for f in *.txt; do
    name=$(basename "$f")
    echo "$name"
done

# 快：用 Shell 內建功能
for f in *.txt; do
    echo "${f##*/}"
done
```

### 內建 vs 外部命令

| 慢 | 快 | 說明 |
|----|-----|------|
| `$(cat file)` | `$(<file)` | 直接讀取 |
| `$(basename $f)` | `${f##*/}` | Shell 參數擴展 |
| `$(dirname $f)` | `${f%/*}` | Shell 參數擴展 |
| `$(expr $a + $b)` | `$((a + b))` | 算術 expansion |
| `$(echo $var)` | `"$var"` | 直接使用 |

---

## 17.3 用 `while read` 取代 `for`

```bash
# 慢：for + command substitution
for line in $(cat file.txt); do
    process "$line"
done

# 快：while read
while IFS= read -r line; do
    process "$line"
done < file.txt
```

### 為什麼？

`$(cat file)` 會一次把所有內容讀入記憶體，而 `while read` 是一行一行處理。

---

## 17.4 並行處理

### 用 `&` 和 `wait`

```bash
#!/bin/bash

# 同時執行 3 個任務
task1 &
task2 &
task3 &

# 等待所有任務完成
wait

echo "所有任務完成"
```

### 用 `xargs -P` 並行化

```bash
# 序列執行
cat files.txt | xargs -I {} process {}

# 並行執行（4 個並行）
cat files.txt | xargs -P 4 -I {} process {}
```

### 用 `parallel`（需安裝）

```bash
# 安裝
brew install parallel

# 平行處理
cat files.txt | parallel -j 4 "process {}"

# 保留目錄結構
find . -name "*.txt" | parallel -j 4 "gzip {}"
```

---

## 17.5 避免子 shell

```bash
# 慢：每個迴圈都建立子 shell
for f in *.txt; do
    content=$(cat "$f")
    echo "$content" | wc -l
done

# 快：使用子 shell 一次處理
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 使用 `find` 的 `-exec`

```bash
# 慢：迴圈
for f in $(find . -name "*.txt"); do
    gzip "$f"
done

# 快：find -exec
find . -name "*.txt" -exec gzip {} \;

# 更快：合併參數
find . -name "*.txt" -exec gzip {} +
```

---

## 17.7 字串操作

```bash
# 慢
upper=$(echo "$var" | tr '[:lower:]' '[:upper:]')

# 快：用 bash 功能
upper="${var^^}"

# 慢
trim=$(echo "$var" | xargs)

# 快
trim="${var#"${var%%[![:space:]]*}"}"
trim="${trim%"${trim##*[![:space:]]}"}"
```

---

## 17.8 陣列操作

```bash
# 慢：外部命令
count=$(echo "${array[@]}" | wc -w)

# 快：內建
count=${#array[@]}

# 慢：外部排序
sorted=$(echo "${array[@]}" | tr ' ' '\n' | sort)

# 快：用 Bash 4+ 內建排序
mapfile -t sorted < <(printf '%s\n' "${array[@]}" | sort)
```

---

## 17.9 延遲展開

```bash
#!/bin/bash
set -euo pipefail

# 在大迴圈中，避免重複展開不變的變數
for i in {1..10000}; do
    # 慢：每次都展開
    echo "$prefix $i $suffix"
    
    # 快：合併後只展開一次
    line="$prefix $i $suffix"
    echo "$line"
done
```

---

## 17.10 快取昂貴計算

```bash
#!/bin/bash

declare -A CACHE

expensive() {
    local key=$1
    if [[ -v CACHE[$key] ]]; then
        echo "${CACHE[$key]}"
        return
    fi
    
    local result=$(compute "$key")
    CACHE[$key]=$result
    echo "$result"
}
```

---

## 17.11 測量效能

```bash
#!/bin/bash

time my-slow-script.sh

# 或在腳本內
start=$(date +%s)
# ... 工作 ...
end=$(date +%s)
echo "耗時：$((end - start)) 秒"
```

### 用 `time`

```bash
time find . -name "*.txt" -exec gzip {} \;

# 輸出：
# real    0m2.345s
# user    0m1.234s
# sys     0m0.567s
```

---

## 17.12 速查表

| 優化技巧 | 慢 | 快 |
|----------|-----|-----|
| 讀檔案 | `$(cat file)` | `$(<file)` 或 `while read` |
| 路徑處理 | `$(basename $f)` | `${f##*/}` |
| 數學計算 | `$(expr $a + $b)` | `$((a + b))` |
| 排序 | `sort` | Bash 4+ 內建 |
| 找檔案 | for + find | `find -exec` |
| 並行 | 序列執行 | `&` + `wait` 或 `xargs -P` |
| 字串大寫 | `tr` | `${var^^}` |

---

## 17.13 練習題

1. 用 `time` 測量一個迴圈處理 1000 個檔案的時間
2. 把一個序列處理的腳本改成並行處理
3. 比較 `$(cat file)` 和 `while read` 的效能差異
4. 用 `xargs -P` 加速批次圖片處理
