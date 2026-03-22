# 20. Shell 与其他语言的桥接

---

## 20.1 什么任务该用 Shell？

Shell 擅长的任务：
- 文件操作
- 系统管理
- 自动化流程
- 管道组合
- 快速原型

其他语言更擅长的任务：
- 复杂的数据处理（Python, AWK）
- 网页程序（JavaScript, Go）
- 数值计算（Python, R, Julia）
- 系统程序（C, Rust）

---

## 20.2 Shell 调用 Python

### 简单调用

```bash
#!/bin/bash

# 调用 Python 脚本
python3 process_data.py input.csv

# 传入参数
python3 script.py arg1 arg2

# 取得输出
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### 在 Shell 脚本中嵌入 Python

```bash
#!/bin/bash

# 用 Python 处理复杂数据
python3 << 'PYEOF'
import csv
import sys

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['amount']) for row in reader)
    print(f"总计: {total}")
PYEOF
```

### 读取 Shell 变量

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

## 20.3 Python 调用 Shell

### 用 `subprocess`

```python
import subprocess

# 执行简单命令
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# 执行复杂命令
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
print(f"Python 文件数量: {result.stdout.strip()}")
```

### 用 `os.system`

```python
import os

# 简单执行（不返回输出）
os.system('mkdir -p backup')

# 返回值
os.system('date > timestamp.txt')
```

---

## 20.4 Shell 调用 JavaScript/Node.js

```bash
#!/bin/bash

# 执行 Node.js 命令
node -e "console.log('hello from node')"

# 调用 Node.js 脚本
node process-json.js data.json

# 取得输出
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

## 20.5 桥接工具

### `jq`：JSON 处理

```bash
# 解析 JSON
echo '{"name": "Alice", "age": 25}' | jq '.name'

# 从文件读取
jq '.users[] | select(.age > 18)' data.json

# 转换格式
jq -c '.[] | {name: .name, value: .count * 2}' data.json
```

### `yq`：YAML 处理

```bash
# 解析 YAML
yq '.database.host' config.yaml

# 转换 YAML 到 JSON
yq -o=json config.yaml
```

### `date`：日期处理

```bash
# Shell 处理简单日期
date +%Y-%m-%d

# Python 处理复杂日期
python3 -c "from datetime import datetime; print(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))"
```

---

## 20.6 实际示例：Shell + Python + SQL

```bash
#!/bin/bash
set -euo pipefail

# 1. Shell：下载数据
echo "下载数据..."
curl -o data.csv "https://api.example.com/export"

# 2. Python：清理数据
python3 << 'PYEOF'
import csv
with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    with open('cleaned.csv', 'w', newline='') as out:
        writer = csv.DictWriter(out, fieldnames=reader.fieldnames)
        writer.writeheader()
        for row in reader:
            row['price'] = float(row['price']) * 1.1  # 加价 10%
            writer.writerow(row)
print("数据清理完成")
PYEOF

# 3. Shell：导入数据库
echo "导入数据库..."
psql -U user -d mydb -c "\COPY products FROM 'cleaned.csv' CSV HEADER"
```

---

## 20.7 Makefile：任务协调

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
make build    # 只构建
make test     # 构建并测试
make deploy   # 完整部署
```

---

## 20.8 速查表

| 桥接方式 | 语法 |
|----------|------|
| Shell 调用 Python | `python3 script.py` 或 `python3 << PYEOF` |
| Python 调用 Shell | `subprocess.run(['ls'])` |
| Shell 调用 Node | `node script.js` 或 `node << JSEOF` |
| 解析 JSON | `jq '.key' file.json` |
| 解析 YAML | `yq '.key' file.yaml` |
| 协调任务 | `make` |

---

## 20.9 练习题

1. 用 Shell 调用 Python 处理一个 CSV 文件
2. 用 Python 的 `subprocess` 执行 Shell 命令
3. 用 `jq` 解析一个 JSON API 响应
4. 用 Makefile 协调 Shell、Python、Node.js 任务