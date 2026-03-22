# 4. การสร้างและเขียนข้อความ

---

## 4.1 ทำไม AI ไม่ต้องการ Editor

workflow การเขียนโค้ดของวิศวกรมนุษย์ส่วนใหญ่:
1. เปิด editor (VS Code, Vim, Emacs...)
2. พิมพ์โค้ด
3. บันทึกไฟล์
4. ปิด editor

สำหรับ AI:
```
"เขียนโปรแกรม Python" = สร้าง text บางอย่าง
"บันทึกโปรแกรมนี้ลงไฟล์" = เขียน text ลง disk
```

กระบวนการสร้างโค้ดของ AI คือ **กระบวนการสร้าง text** ดังนั้น AI ใช้ text tools ของ Shell:

- `echo`: output บรรทัดเดียว
- `printf`: output ที่จัดรูปแบบ
- `heredoc`: output หลายบรรทัด (สำคัญที่สุด!)

---

## 4.2 `echo`: Output ที่เรียบง่ายที่สุด

### การใช้พื้นฐาน

```bash
# Output string
echo "Hello, World!"

# Output ตัวแปร
name="Alice"
echo "Hello, $name!"

# Output หลายค่า
echo "Today is $(date +%Y-%m-%d)"
```

### กับดักของ `echo`

```bash
# echo เพิ่ม newline โดยค่าเริ่มต้น
echo -n "Loading: "  # ไม่มี newline
```

### เขียนไฟล์ด้วย `echo`

```bash
# เขียนทับ
echo "Hello, World!" > file.txt

# เพิ่มต่อ
echo "Second line" >> file.txt
```

**หมายเหตุ**: ใช้ `echo` สำหรับไฟล์หลายบรรทัดเจ็บปวดมาก, ดังนั้น AI แทบไม่เคยใช้มันสำหรับโค้ด `heredoc` คือดาวเด่น

---

## 4.3 `printf`: Output ที่จัดรูปแบบได้มากกว่า

### เปรียบเทียบกับ `echo`

```bash
# printf รองรับการจัดรูปแบบแบบ C
printf "Value: %.2f\n" 3.14159
# Output: Value: 3.14

printf "%s\t%s\n" "Name" "Age"
```

### สร้างตาราง

```bash
printf "%-15s %10s\n" "Name" "Price"
printf "%-15s %10.2f\n" "iPhone" 999.99
printf "%-15s %10.2f\n" "MacBook" 1999.99
```

---

## 4.4 heredoc: อาวุธหลักของ AI สำหรับเขียนโค้ด

### heredoc คืออะไร?

heredoc คือไวยากรณ์พิเศษของ Shell สำหรับ **output text หลายบรรทัดตรงๆ**

```bash
cat << 'EOF'
All this content
will be output verbatim
including newlines, spaces
EOF
```

### เขียนไฟล์ (การใช้ที่พบบ่อยที่สุดของ AI)

```bash
cat > program.py << 'EOF'
#!/usr/bin/env python3

def hello(name):
    print(f"Hello, {name}!")

if __name__ == "__main__":
    hello("World")
EOF
```

### ทำไมต้องใช้ `'EOF'` (Single Quote)?

```bash
# Single quote EOF: ไม่ expand อะไรเลย
cat << 'EOF'
HOME is: $HOME
Today is: $(date)
EOF
# Output: HOME is: $HOME (ไม่ได้ expand)

# Double quote EOF หรือไม่มี quotes: จะ expand
cat << EOF
HOME is: $HOME
EOF
# Output: HOME is: /home/ai (ได้ expand)
```

**ทางเลือกของ AI**: แทบจะใช้ `'EOF'` (single quote) เสมอ เพราะโค้ดปกติไม่ต้องการ Shell variable expansion

---

## 4.5 AI เขียนไฟล์ต่างๆ ด้วย heredoc

### เขียนโปรแกรม Python

```bash
cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""Main entry point"""

import sys
import os

def main():
    print("Python + C Hybrid Project")
    print(f"Working directory: {os.getcwd()}")

if __name__ == "__main__":
    main()
EOF
```

### เขียน Shell Script

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

DEPLOY_HOST="server.example.com"

echo "🚀 Deploying to $DEPLOY_HOST"
rsync -avz --delete ./dist/ "$DEPLOY_HOST:/var/www/app/"
ssh "$DEPLOY_HOST" "systemctl restart myapp"
echo "✅ Deploy complete!"
EOF

chmod +x scripts/deploy.sh
```

### เขียน Config File

```bash
cat > config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF
```

### เขียน Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "http.server", "8000"]
EOF
```

---

## 4.6 กับดักและวิธีแก้ของ heredoc

### กับดัก 1: มี Single Quotes

```bash
# ปัญหา: single quote EOF ไม่อนุญาตให้มี single quotes
cat << 'EOF'
He's going.
EOF
# Output: syntax error

# วิธีแก้: ใช้ double quote EOF
cat << "EOF"
He's going.
EOF
```

### กับดัก 2: มี `$` (แต่ไม่ต้องการให้ expand)

```bash
# ปัญหา: double quote EOF expand $
cat << "EOF"
Price is $100
EOF
# Output: Price is (ว่างเปล่า)

# วิธีแก้: escape แต่ละตัว
cat << "EOF"
Price is $$100
EOF
# Output: Price is $100
```

---

## 4.7 การฝึก: สร้างโปรเจกต์ที่สมบูรณ์จากจุดเริ่มต้น

```bash
# 1. สร้างโครงสร้างไดเรกทอรี
mkdir -p myblog/{src,themes,content}

# 2. สร้าง config file
cat > myblog/config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF

# 3. สร้างโปรแกรม Python หลัก
cat > myblog/src/blog.py << 'EOF'
#!/usr/bin/env python3
"""Simple blog generator"""
import json
from pathlib import Path

def load_config():
    config_path = Path(__file__).parent.parent / "config.json"
    with open(config_path) as f:
        return json.load(f)

if __name__ == "__main__":
    config = load_config()
    print(f"Generating: {config['site_name']}")
EOF

# 4. สร้าง build script
cat > myblog/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🔨 Building blog..."
cd "$(dirname "$0")"
python3 src/blog.py
echo "✅ Build complete!"
EOF

chmod +x myblog/build.sh

# 5. ยืนยันโครงสร้าง
find myblog -type f | sort
```

---

## 4.8 คู่มืออ้างอิงฉบับย่อ

| เครื่องมือ | จุดประสงค์ | ตัวอย่าง |
|------------|-----------|---------|
| `echo` | Output บรรทัดเดียว | `echo "Hello"` |
| `echo -n` | ไม่มี newline | `echo -n "Loading..."` |
| `printf` | Output ที่จัดรูปแบบ | `printf "%s: %d\n" "age" 25` |
| `>` | เขียนทับไฟล์ | `echo "hi" > file.txt` |
| `>>` | เพิ่มต่อไฟล์ | `echo "hi" >> file.txt` |
| `<< 'EOF'` | heredoc (ไม่ expand) | เลือกใช้สำหรับโค้ด |
| `<< "EOF"` | heredoc (expand) | ใช้นานๆ ที |

---

## 4.9 แบบฝึกหัด

1. สร้าง Loading animation ด้วย `echo -n` และ `for` loop
2. สร้างตารางที่จัดรูปแบบ (name, age, job) ด้วย `printf`
3. เขียนโปรแกรม Python 20 บรรทัดด้วย heredoc
4. เขียน docker-compose.yml ด้วย heredoc