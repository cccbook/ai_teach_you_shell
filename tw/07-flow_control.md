# 7. 流程控制與條件迴圈

---

## 7.1 組合命令：Shell 的精髓

單一命令能做的事有限。把多個命令**組合起來**，才能完成複雜任務。

AI 之所以強大，很大程度上是因為它精通這些組合方式：

```bash
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -10
```

這行指令的意思：「從 access.log 找出錯誤，統計次數，找出最常見的 10 個」

---

## 7.2 `|`（管道）：資料流的藝術

管道把前一個命令的**輸出**變成下一個命令的**輸入**。

```bash
# 把檔案內容排序後顯示
cat unsorted.txt | sort

# 找出最常用的命令
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

# 把日誌中所有 IP 取出並統計
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

### 管道 stderr

```bash
# 把 stderr 也傳到管道
command1 2>&1 | command2

# 或 Bash 4+
command1 |& command2
```

---

## 7.3 `&&`：成功才執行下一個

**只有當 `command1` 成功（exit code = 0），才執行 `command2`。**

```bash
# 建立目錄後進入
mkdir -p project && cd project

# 編譯成功後執行
gcc -o program source.c && ./program

# 下載後解壓縮
curl -L -o archive.tar.gz http://example.com/file && tar -xzf archive.tar.gz
```

---

## 7.4 `||`：失敗才執行下一個

**只有當 `command1` 失敗（exit code ≠ 0），才執行 `command2`。**

```bash
# 檔案不存在就建立它
[ -f config.txt ] || echo "配置不存在" > config.txt

# 嘗試一種方式，失敗了用另一種
cd /opt/project || cd /home/user/project

# 確保即使失敗也當作成功（常用於 makefile）
cp file.txt file.txt.bak || true
```

### `&&` 和 `||` 的組合

```bash
# 條件表達式
[ -f config ] && echo "已找到" || echo "沒有配置"

# 等價於：
if [ -f config ]; then
    echo "已找到"
else
    echo "沒有配置"
fi
```

---

## 7.5 `;`：無論成功失敗都執行

```bash
# 三個都執行
mkdir /tmp/test ; cd /tmp/test ; pwd
```

---

## 7.6 `$()`：命令替換

**執行命令，用其輸出替換 `$()` 的位置。**

```bash
# 基本用法
echo "今天是 $(date +%Y-%m-%d)"
# 輸出：今天是 2026-03-22

# 在變數中使用
FILES=$(ls *.txt)

# 取得目錄名
DIR=$(dirname /path/to/file.txt)
BASE=$(basename /path/to/file.txt)

# 計算
echo "結果是 $((10 + 5))"
# 輸出：結果是 15
```

### 與反引號的對比

```bash
# 兩種語法等價
echo "今天是 $(date +%Y)"
echo "今天是 `date +%Y`"

# 但 $() 更好，因為可以巢狀
echo $(echo $(echo nested))
```

---

## 7.7 `[[ ]]` 和 `[ ]`：條件測試

### 檔案測試

```bash
[[ -f file.txt ]]      # 普通檔案存在
[[ -d directory ]]     # 目錄存在
[[ -e path ]]          # 任何類型存在
[[ -L link ]]          # 符號連結存在
[[ -r file ]]          # 可讀
[[ -w file ]]          # 可寫
[[ -x file ]]          # 可執行
[[ file1 -nt file2 ]]  # file1 比 file2 新
```

### 字串測試

```bash
[[ -z "$str" ]]        # 字串為空
[[ -n "$str" ]]        # 字串不為空
[[ "$str" == "value" ]] # 相等
[[ "$str" =~ pattern ]]  # 匹配正規表達式
```

### 數值測試

```bash
[[ $num -eq 10 ]]      # 等於
[[ $num -ne 10 ]]      # 不等於
[[ $num -gt 10 ]]      # 大於
[[ $num -lt 10 ]]      # 小於
```

---

## 7.8 `if`：條件判斷

```bash
if [[ 條件 ]]; then
    # 條件成立時執行
elif [[ 條件2 ]]; then
    # 條件2 成立時執行
else
    # 都不成立時執行
fi
```

### 完整範例

```bash
#!/bin/bash

FILE="config.yaml"

if [[ ! -f "$FILE" ]]; then
    echo "錯誤：$FILE 不存在"
    exit 1
fi

if [[ -r "$FILE" ]]; then
    echo "檔案可讀"
else
    echo "檔案不可讀"
fi
```

---

## 7.9 `for`：迴圈

### 基本語法

```bash
for variable in list; do
    # 使用 $variable
done
```

### AI 的常用模式

```bash
# 處理所有 .txt 檔案
for file in *.txt; do
    echo "處理 $file"
done

# 數字範圍
for i in {1..10}; do
    echo "第 $i 次"
done

# 陣列
for color in red green blue; do
    echo $color
done

# C 風格迴圈（Bash 3+）
for ((i=0; i<10; i++)); do
    echo $i
done
```

---

## 7.10 `while`：條件迴圈

```bash
# 讀取行
while IFS= read -r line; do
    echo "讀到: $line"
done < file.txt

# 計數迴圈
count=0
while [[ $count -lt 10 ]]; do
    echo $count
    ((count++))
done
```

---

## 7.11 `case`：模式匹配

```bash
case $ACTION in
    start)
        echo "啟動服務..."
        ;;
    stop)
        echo "停止服務..."
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "用法: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

### 萬用字元模式

```bash
case "$filename" in
    *.txt)
        echo "文字檔案"
        ;;
    *.jpg|*.png|*.gif)
        echo "圖片檔案"
        ;;
    *)
        echo "未知類型"
        ;;
esac
```

---

## 7.12 速查表

| 符號 | 名稱 | 說明 |
|------|------|------|
| `\|` | 管道 | 把輸出傳給下一個輸入 |
| `&&` | AND | 前一個成功才執行下一個 |
| `\|\|` | OR | 前一個失敗才執行下一個 |
| `;` | 分號 | 無論成功失敗都執行 |
| `$()` | 命令替換 | 執行命令，用輸出替換 |
| `[[ ]]` | 條件測試 | 推薦的測試語法 |
| `if` | 條件判斷 | 根據條件分支 |
| `for` | 計數迴圈 | 遍歷列表 |
| `while` | 條件迴圈 | 條件為真時重複 |
| `case` | 模式匹配 | 多條件分支 |

---

## 7.13 練習題

1. 用 `|` 組合 `ls`、`grep`、`wc` 統計某個目錄下 `.log` 檔案的數量
2. 用 `&&` 確保 `mkdir` 成功後才 `cd` 進去
3. 用 `for` 迴圈批次建立 10 個目錄（dir1 到 dir10）
4. 用 `while read` 讀取 `/etc/hosts` 並顯示內容
5. 用 `case` 寫一個簡單的計算機（add、sub、mul、div）
