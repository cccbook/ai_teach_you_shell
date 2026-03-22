# 20. Kết Nối Shell Với Ngôn Ngữ Khác

---

## 20.1 Những Tác Vụ Nào Nên Dùng Shell?

Tác vụ Shell giỏi:
- Thao tác file
- Quản lý hệ thống
- Tự động hóa workflows
- Pipeline composition
- Prototypes nhanh

Tác vụ phù hợp hơn với ngôn ngữ khác:
- Xử lý dữ liệu phức tạp (Python, AWK)
- Lập trình web (JavaScript, Go)
- Tính toán số (Python, R, Julia)
- Lập trình hệ thống (C, Rust)

---

## 20.2 Shell Gọi Python

### Gọi Đơn Giản

```bash
#!/bin/bash

# Call Python script
python3 process_data.py input.csv

# Pass arguments
python3 script.py arg1 arg2

# Get output
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### Nhúng Python Trong Shell

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

## 20.3 Python Gọi Shell

### Sử dụng `subprocess`

```python
import subprocess

# Run simple command
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# Run complex command
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
```

---

## 20.4 Shell Gọi JavaScript/Node.js

```bash
#!/bin/bash

# Execute Node.js command
node -e "console.log('hello from node')"

# Execute Node.js script
node process-json.js data.json
```

---

## 20.5 Công Cụ Kết Nối

### `jq`: Xử Lý JSON

```bash
# Parse JSON
echo '{"name": "Alice", "age": 25}' | jq '.name'

# Read from file
jq '.users[] | select(.age > 18)' data.json
```

### `yq`: Xử Lý YAML

```bash
# Parse YAML
yq '.database.host' config.yaml

# Convert YAML to JSON
yq -o=json config.yaml
```

---

## 20.6 Tham Khảo Nhanh

| Bridge | Syntax |
|--------|--------|
| Shell→Python | `python3 script.py` hoặc `python3 << PYEOF` |
| Python→Shell | `subprocess.run(['ls'])` |
| Shell→Node | `node script.js` hoặc `node << JSEOF` |
| Parse JSON | `jq '.key' file.json` |
| Parse YAML | `yq '.key' file.yaml` |
| Orchestrate | `make` |

---

## 20.7 Bài Tập

1. Sử dụng Shell gọi Python xử lý file CSV
2. Sử dụng Python `subprocess` thực thi Shell commands
3. Sử dụng `jq` parse JSON API response
4. Sử dụng Makefile orchestrate Shell, Python, và Node.js tasks
