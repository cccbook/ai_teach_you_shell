# 5. 文字處理

---

## 5.1 AI 的文字處理哲學

在 AI 的世界裡，**一切都是文字**。

- 程式碼是文字
- 設定檔是文字
- 日誌是文字
- JSON、HTML、Markdown 都是文字

所以文字處理命令是 AI 工具箱中最核心的部分。

人類工程師遇到問題時：「我要找一個工具来处理这个...」
AI 遇到問題時：「這個用 `grep | sed | awk` 一行就能解決。」

---

## 5.2 `cat`：讀取檔案的藝術

### 基本用法

```bash
# 顯示檔案內容
cat file.txt

# 合併檔案
cat part1.txt part2.txt > whole.txt

# 顯示行號
cat -n script.sh
```

### `cat` 的真正用途：組合與建立

```bash
# 從 stdin 建立檔案
cat << 'EOF' > newfile.txt
這是檔案內容
可以寫很多行
EOF
```

---

## 5.3 `head` 和 `tail`：只看需要的部分

### `head`：看前面

```bash
# 看前 10 行（預設）
head file.txt

# 看前 5 行
head -n 5 file.txt

# 看前 100 位元組
head -c 100 file.txt
```

### `tail`：看後面

```bash
# 看最後 10 行（預設）
tail file.txt

# 看最後 5 行
tail -n 5 file.txt

# 即時監看檔案（最常用！）
tail -f /var/log/syslog

# 即時監看日誌，發現錯誤就停止
tail -f app.log | grep --line-buffered ERROR
```

### 看特定行範圍

```bash
# 看第 100-150 行
tail -n +100 file.txt | head -n 50
```

---

## 5.4 `wc`：計數工具

```bash
# 計算行數
wc -l file.txt

# 計算多個檔案的行數
wc -l *.py

# 統計資料夾中有多少個檔案
ls | wc -l
```

---

## 5.5 `grep`：文字搜尋之王

### 基本用法

```bash
# 搜尋包含 "error" 的行
grep "error" log.txt

# 忽略大小寫
grep -i "error" log.txt

# 顯示行號
grep -n "error" log.txt

# 只顯示檔名
grep -l "TODO" *.md

# 反向（不匹配的行）
grep -v "debug" log.txt

# 只顯示完全匹配的單字
grep -w "error" log.txt
```

### 正規表達式

```bash
# 開頭匹配
grep "^Error" log.txt

# 結尾匹配
grep "done.$" log.txt

# 任意字元
grep "e.or" log.txt

# 範圍
grep -E "[0-9]{3}-" log.txt
```

### 高級技巧

```bash
# 遞迴搜尋
grep -r "TODO" src/

# 只搜尋特定副檔名
grep -r "TODO" --include="*.py" src/

# 顯示前後行
grep -B 2 -A 2 "ERROR" log.txt

# 多重條件（OR）
grep -E "error|warning|fatal" log.txt
```

---

## 5.6 `sed`：文字替換利器

### 基本替換

```bash
# 替換第一個匹配
sed 's/old/new/' file.txt

# 替換所有匹配
sed 's/old/new/g' file.txt

# 原地替換
sed -i 's/old/new/g' file.txt

# 備份後原地替換
sed -i.bak 's/old/new/g' file.txt
```

### 刪除行

```bash
# 刪除空行
sed '/^$/d' file.txt

# 刪除以 # 開頭的行（註解）
sed '/^#/d' file.txt

# 刪除行尾空白
sed 's/[[:space:]]*$//' file.txt
```

### 實用範例

```bash
# 批次改副檔名（.txt → .md）
for f in *.txt; do
    mv "$f" "$(sed 's/.txt$/.md/' <<< "$f")"
done

# 移除 Windows 換行符
sed -i 's/\r$//' file.txt

# 把所有空白變成 Tab
sed 's/  */\t/g' file.txt
```

---

## 5.7 `awk`：文字處理的瑞士刀

### 基本概念

`awk` 會逐行讀取文字，自動分割成欄位（$1, $2, $3...），對每一行執行指定的動作。

### 基本用法

```bash
# 預設以空白分割欄位
awk '{print $1}' file.txt

# 指定分隔符
awk -F: '{print $1}' /etc/passwd

# 輸出多個欄位
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### 條件判斷

```bash
# 只處理符合條件的行
awk -F: '$3 > 1000 {print $1}' /etc/passwd

# BEGIN 和 END
awk 'BEGIN {print "開始"} {print} END {print "完成"}' file.txt
```

### 實用範例

```bash
# 計算 CSV 的總和
awk -F, '{sum += $3} END {print sum}' data.csv

# 找最大值
awk 'NR==1 {max=$3} $3>max {max=$3} END {print max}' data.csv

# 格式化輸出
awk '{printf "%-20s %10.2f\n", $1, $2}' data.txt
```

---

## 5.8 實戰：組合使用所有工具

### 情境：分析伺服器日誌

```bash
# 1. 找出錯誤訊息
grep -i "error" access.log

# 2. 統計錯誤數量
grep -ci "error" access.log

# 3. 找出最常見的錯誤
grep "error" access.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# 4. 統計每小時的請求數
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

### 情境：批次修改程式碼

```bash
# 把所有 .py 檔案中的 "print" 改成 "logger.info"
find . -name "*.py" -exec sed -i 's/print(/logger.info(/g' {} +

# 把所有的 var 改成 const
find . -name "*.js" -exec sed -i 's/\bvar\b/const/g' {} +
```

---

## 5.9 速查表

| 命令 | 用途 | 常用參數 |
|------|------|----------|
| `cat` | 顯示/合併檔案 | `-n` 行號 |
| `head` | 看檔案開頭 | `-n` 行數, `-c` 位元組 |
| `tail` | 看檔案結尾 | `-n` 行數, `-f` 即時監看 |
| `wc` | 計數 | `-l` 行, `-w` 字, `-c` 位元組 |
| `grep` | 搜尋文字 | `-i` 忽略, `-n` 行號, `-r` 遞迴, `-c` 計數 |
| `sed` | 替換文字 | `s/old/new/g`, `-i` 原地 |
| `awk` | 欄位處理 | `-F` 分隔符, `{print}` 動作 |

---

## 5.10 練習題

1. 用 `head` 和 `tail` 組合看檔案的第 100-120 行
2. 用 `grep` 找出 `/etc/passwd` 中所有使用 `/bin/bash` 的使用者
3. 用 `sed` 把檔案中所有的 `\r\n` 換成 `\n`
4. 用 `awk` 計算一個包含數字的檔案的最大值、最小值、平均值
