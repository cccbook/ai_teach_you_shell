# 20. Shell 與其他語言的橋接

---

## 20.1 什麼任務該用 Shell？

Shell 擅長的任務：
- 檔案操作
- 系統管理
- 自動化流程
- 管道組合
- 快速原型

其他語言更擅長的任務：
- 複雜的資料處理（Python, AWK）
- 網頁程式（JavaScript, Go）
- 數值計算（Python, R, Julia）
- 系統程式（C, Rust）

---

## 20.2 Shell 呼叫 Python

### 簡單呼叫

```bash
#!/bin/bash

# 呼叫 Python 腳本
python3 process_data.py input.csv

# 傳入參數
python3 script.py arg1 arg2

# 取得輸出
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### 在 Shell 腳本中嵌入 Python

```bash
#!/bin/bash

# 用 Python 處理複雜資料
python3 << 'PYEOF'
import csv
import sys

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['amount']) for row in reader)
    print(f"總計: {total}")
PYEOF
```

### 讀取 Shell 變數

```bash
#!/bin/bash

name="Alice"
age=25

python3 << PYEOF
name = "$name"
age = $age
print(f"Hello, {name}, you are {age} years old")
PYEOF
```

---

## 20.3 Python 呼叫 Shell

### 用 `subprocess`

```python
import subprocess

# 執行簡單命令
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# 執行複雜命令
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
print(f"Python 檔案數量: {result.stdout.strip()}")
```

### 用 `os.system`

```python
import os

# 簡單執行（不回傳輸出）
os.system('mkdir -p backup')

# 回傳值
os.system('date > timestamp.txt')
```

---

## 20.4 Shell 呼叫 JavaScript/Node.js

```bash
#!/bin/bash

# 執行 Node.js 命令
node -e "console.log('hello from node')"

# 呼叫 Node.js 腳本
node process-json.js data.json

# 取得輸出
result=$(node -e "console.log(JSON.stringify({a:1}))")
echo "$result"
```

### 在 Shell 中嵌入 Node.js

```bash
#!/bin/bash

node << 'JSEOF'
const data = [1, 2, 3, 4, 5];
const sum = data.reduce((a, b) => a + b, 0);
console.log('Sum:', sum);
JSEOF
```

---

## 20.5 橋接工具

### `jq`：JSON 處理

```bash
# 解析 JSON
echo '{"name": "Alice", "age": 25}' | jq '.name'

# 從檔案讀取
jq '.users[] | select(.age > 18)' data.json

# 轉換格式
jq -c '.[] | {name: .name, value: .count * 2}' data.json
```

### `yq`：YAML 處理

```bash
# 解析 YAML
yq '.database.host' config.yaml

# 轉換 YAML 到 JSON
yq -o=json config.yaml
```

### `date`：日期處理

```bash
# Shell 處理簡單日期
date +%Y-%m-%d

# Python 處理複雜日期
python3 -c "from datetime import datetime; print(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))"
```

---

## 20.6 實際範例：Shell + Python + SQL

```bash
#!/bin/bash
set -euo pipefail

# 1. Shell：下載資料
echo "下載資料..."
curl -o data.csv "https://api.example.com/export"

# 2. Python：清理資料
python3 << 'PYEOF'
import csv
with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    with open('cleaned.csv', 'w', newline='') as out:
        writer = csv.DictWriter(out, fieldnames=reader.fieldnames)
        writer.writeheader()
        for row in reader:
            row['price'] = float(row['price']) * 1.1  # 加價 10%
            writer.writerow(row)
print("資料清理完成")
PYEOF

# 3. Shell：匯入資料庫
echo "匯入資料庫..."
psql -U user -d mydb -c "\COPY products FROM 'cleaned.csv' CSV HEADER"
```

---

## 20.7 Makefile：任務協調

```makefile
.PHONY: build test deploy clean

build:
	@echo "Building..."
	gcc -o app main.c -Wall

test: build
	@echo "Testing..."
	python3 test_app.py

deploy: test
	@echo "Deploying..."
	scp app user@server:/opt/

clean:
	@echo "Cleaning..."
	rm -f app *.o
	rm -f test_output.txt
```

```bash
make build    # 只建置
make test     # 建置並測試
make deploy   # 完整部署
```

---

## 20.8 速查表

| 橋接方式 | 語法 |
|----------|------|
| Shell 呼叫 Python | `python3 script.py` 或 `python3 << PYEOF` |
| Python 呼叫 Shell | `subprocess.run(['ls'])` |
| Shell 呼叫 Node | `node script.js` 或 `node << JSEOF` |
| 解析 JSON | `jq '.key' file.json` |
| 解析 YAML | `yq '.key' file.yaml` |
| 協調任務 | `make` |

---

## 20.9 練習題

1. 用 Shell 呼叫 Python 處理一個 CSV 檔案
2. 用 Python 的 `subprocess` 執行 Shell 命令
3. 用 `jq` 解析一個 JSON API 回應
4. 用 Makefile 協調 Shell、Python、Node.js 任務
