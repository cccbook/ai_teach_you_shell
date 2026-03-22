# 20. การเชื่อมต่อ Shell กับภาษาอื่น

---

## 20.1 งานใดควรใช้ Shell

งานที่ Shell ทำได้ดี:
- การจัดการไฟล์
- การดูแลระบบ
- เวิร์กโฟลว์อัตโนมัติ
- การต่อ pipeline
- ต้นแบบอย่างรวดเร็ว

งานที่เหมาะกับภาษาอื่นมากกว่า:
- การประมวลผลข้อมูลที่ซับซ้อน (Python, AWK)
- การเขียนเว็บ (JavaScript, Go)
- การคำนวณตัวเลข (Python, R, Julia)
- การเขียนโปรแกรมระดับระบบ (C, Rust)

---

## 20.2 Shell เรียก Python

### การเรียกแบบง่าย

```bash
#!/bin/bash

# เรียก Python script
python3 process_data.py input.csv

# ส่ง argument
python3 script.py arg1 arg2

# รับ output
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### ฝัง Python ใน Shell

```bash
#!/bin/bash

python3 << 'PYEOF'
import csv

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['amount']) for row in reader)
    print(f"Total: {total}")
PYEOF
```

---

## 20.3 Python เรียก Shell

### ใช้ `subprocess`

```python
import subprocess

# รันคำสั่งง่าย
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# รันคำสั่งซับซ้อน
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
```

---

## 20.4 Shell เรียก JavaScript/Node.js

```bash
#!/bin/bash

# รันคำสั่ง Node.js
node -e "console.log('hello from node')"

# รัน Node.js script
node process-json.js data.json
```

---

## 20.5 เครื่องมือเชื่อมต่อ

### `jq`: การประมวลผล JSON

```bash
# แยกวิเคราะห์ JSON
echo '{"name": "Alice", "age": 25}' | jq '.name'

# อ่านจากไฟล์
jq '.users[] | select(.age > 18)' data.json
```

### `yq`: การประมวลผล YAML

```bash
# แยกวิเคราะห์ YAML
yq '.database.host' config.yaml

# แปลง YAML เป็น JSON
yq -o=json config.yaml
```

---

## 20.6 คำสั่งอ้างอิงฉบับย่อ

| เชื่อมต่อ | ไวยากรณ์ |
|--------|--------|
| Shell→Python | `python3 script.py` หรือ `python3 << PYEOF` |
| Python→Shell | `subprocess.run(['ls'])` |
| Shell→Node | `node script.js` หรือ `node << JSEOF` |
| แยกวิเคราะห์ JSON | `jq '.key' file.json` |
| แยกวิเคราะห์ YAML | `yq '.key' file.yaml` |
| ประสานงาน | `make` |

---

## 20.7 แบบฝึกหัด

1. ใช้ Shell เรียก Python เพื่อประมวลผลไฟล์ CSV
2. ใช้ Python `subprocess` รันคำสั่ง Shell
3. ใช้ `jq` แยกวิเคราะห์ JSON จาก API response
4. ใช้ Makefile ประสานงาน Shell, Python, และ Node.js
