# 16. เทคนิคการ Debug

---

## 16.1 มุมมองการ Debug ของ AI

เมื่อมนุษย์เจอข้อผิดพลาด: ตกใจ, ค้นหาออนไลน์, คัดลอกวาง
เมื่อ AI เจอข้อผิดพลาด: วิเคราะห์ข้อความ, อนุมานสาเหตุ, ดำเนินการแก้ไข

ขั้นตอนการ debug ของ AI:
```
สังเกต output ข้อผิดพลาด → เข้าใจประเภทข้อผิดพลาด → หาตำแหน่งปัญหา → แก้ไข → ตรวจสอบ
```

---

## 16.2 `bash -x`: ติดตามการทำงาน

วิธี debug ที่ง่ายที่สุด: เพิ่ม flag `-x`

```bash
bash -x script.sh
```

แสดงแต่ละบรรทัดที่ทำงานพร้อมคำนำหน้า `+`:

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### Debug เฉพาะส่วน

```bash
#!/bin/bash

echo "This won't show"
set -x
# Debug เริ่มตรงนี้
name="Alice"
echo "Hello, $name"
set +x
# Debug จบตรงนี้
echo "This won't show"
```

---

## 16.3 ข้อผิดพลาดที่พบบ่อยและวิธีแก้

### ข้อผิดพลาด 1: Permission Denied

```bash
# ข้อผิดพลาด
./script.sh
# Output: Permission denied

# แก้ไข
chmod +x script.sh
./script.sh
```

### ข้อผิดพลาด 2: Command Not Found

```bash
# ข้อผิดพลาด
python script.py
# Output: command not found: python

# แก้ไข: ใช้ path เต็ม
/usr/bin/python3 script.py
```

### ข้อผิดพลาด 3: Undefined Variable

```bash
#!/bin/bash
set -u

echo $undefined_var
# Output: bash: undefined_var: unbound variable

# แก้ไข: กำหนดค่าเริ่มต้น
echo ${undefined_var:-default}
```

---

## 16.4 Debug ด้วย `echo`

เมื่อ `-x` ไม่เพียงพอ, เพิ่ม `echo` ด้วยตนเอง:

```bash
#!/bin/bash

echo "DEBUG: Entering function"
echo "DEBUG: Parameter = $@"

process() {
    echo "DEBUG: In process"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
}
```

---

## 16.5 คำสั่งอ้างอิงฉบับย่อ

| คำสั่ง | คำอธิบาย |
|--------|----------|
| `bash -n script.sh` | ตรวจสอบไวยากรณ์เท่านั้น |
| `bash -x script.sh` | ติดตามการทำงาน |
| `set -x` | เปิดโหมด debug |
| `set +x` | ปิดโหมด debug |
| `trap 'echo cmd' DEBUG` | ติดตามทุกคำสั่ง |

---

## 16.6 แบบฝึกหัด

1. รันสคริปต์ด้วย `bash -x` และสังเกตรูปแบบ output
2. ใช้ `set -x` ในสคริปต์เพื่อ debug เฉพาะฟังก์ชัน
3. หาคำสั่งที่ล้มเหลว, วิเคราะห์ข้อความข้อผิดพลาด, และแก้ไข
4. สร้างการจัดการข้อผิดพลาดที่ดีด้วย `trap`
