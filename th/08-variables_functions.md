# 8. ตัวแปรและฟังก์ชัน

---

## 8.1 พื้นฐานตัวแปร

### การกำหนดค่าพื้นฐาน

```bash
# สตริง
name="Alice"
greeting="Hello, World!"

# ตัวเลข
age=25
count=0

# ค่าว่าง
empty=
empty2=""
```

### การอ่านตัวแปร

```bash
echo $name
echo ${name}    # รูปแบบที่แนะนำ ชัดเจนกว่า

# ในเครื่องหมายคำพูดคู่
echo "My name is ${name}"
```

### ข้อผิดพลาดที่พบบ่อย

```bash
# ผิด: มีช่องว่างรอบ =
name = "Alice"   # ถูกตีความว่าเป็นคำสั่ง

# ผิด: ไม่มีเครื่องหมายคำพูด
greeting=Hello World  # แสดงผลเฉพาะ "Hello"

# ถูกต้อง:
name="Alice"
greeting="Hello World"
```

---

## 8.2 ศิลปะของเครื่องหมายคำพูด

### เครื่องหมายคำพูดคู่ `"`
ขยายตัวแปรและการแทนที่คำสั่ง

```bash
name="Alice"
echo "Hello, $name"           # Hello, Alice
echo "Today is $(date +%Y)"     # Today is 2026
```

### เครื่องหมายคำพูดเดี่ยว `'`
แสดงผลตามตัวอักษร ไม่ขยายอะไรเลย

```bash
name="Alice"
echo 'Hello, $name'           # Hello, $name
echo 'Today is $(date +%Y)'     # Today is $(date +%Y)
```

### ไม่มีเครื่องหมายคำพูด
หลีกเลี่ยง ยกเว้นคุณแน่ใจว่าตัวแปรไม่มีช่องว่าง

---

## 8.3 ตัวแปรพิเศษ

```bash
$0          # ชื่อสคริปต์
$1, $2...   # พารามิเตอร์ตำแหน่ง
$#          # จำนวนอาร์กิวเมนต์
$@          # อาร์กิวเมนต์ทั้งหมด (แยกกัน)
$*          # อาร์กิวเมนต์ทั้งหมด (เป็นสตริงเดียว)
$?          # รหัสออกของคำสั่งล่าสุด
$$          # PID ของกระบวนการปัจจุบัน
$!          # PID ของกระบวนการเบื้องหลังล่าสุด
$-          # ตัวเลือกของ shell ปัจจุบัน
```

---

## 8.4 อาร์เรย์

### การใช้งานพื้นฐาน

```bash
# กำหนดอาร์เรย์
colors=("red" "green" "blue")

# อ่านองค์ประกอบ
echo ${colors[0]}    # red
echo ${colors[1]}    # green

# อ่านทั้งหมด
echo ${colors[@]}    # red green blue

# ความยาวของอาร์เรย์
echo ${#colors[@]}   # 3
```

### อาร์เรย์เชื่อมโยง (Bash 4+)

```bash
declare -A user
user["name"]="Alice"
user["email"]="alice@example.com"

echo ${user["name"]}    # Alice
```

---

## 8.5 พื้นฐานฟังก์ชัน

### การกำหนดฟังก์ชัน

```bash
# วิธีที่ 1: คีย์เวิร์ด function
function greet {
    echo "Hello!"
}

# วิธีที่ 2: กำหนดโดยตรง (แนะนำ)
greet() {
    echo "Hello!"
}
```

### พารามิเตอร์ของฟังก์ชัน

```bash
greet() {
    echo "Hello, $1!"
}

greet "Alice"    # Hello, Alice!
```

### ค่าส่งกลับ

```bash
# return: สำหรับรหัสออก (0-255)
check() {
    if [[ $1 -gt 10 ]]; then
        return 0  # สำเร็จ
    else
        return 1  # ล้มเหลว
    fi
}

if check 15; then
    echo "Greater than 10"
fi
```

---

## 8.6 ตัวแปรท้องถิ่น

```bash
counter() {
    local count=0
    ((count++))
    echo $count
}
```

---

## 8.7 ไลบรารีฟังก์ชัน

### สร้างไลบรารี

```bash
cat > lib.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date +%H:%M:%S)] $@"
}

error() {
    echo "[$(date +%H:%M:%S)] ERROR: $@" >&2
}

confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}
EOF
```

### ใช้งานไลบรารี

```bash
#!/bin/bash

source lib.sh

log "Starting process"
error "Something went wrong"
confirm "Continue?" && echo "Continuing"
```

---

## 8.8 สรุปย่อ

| หัวข้อ | ไวยากรณ์ | คำอธิบาย |
|-------|---------|-------------|
| การกำหนดค่า | `var=value` | ไม่มีช่องว่างรอบ = |
| อ่านค่า | `$var` หรือ `${var}` | ใช้ `${var}` |
| คำพูดคู่ | `"..."` | ขยายตัวแปร |
| คำพูดเดี่ยว | `'...'` | ไม่ขยาย |
| อาร์กิวเมนต์ | `$1`, `$2`, `$@` | รับพารามิเตอร์ |
| ฟังก์ชัน | `name() { }` | รูปแบบที่แนะนำ |
| ตัวแปรท้องถิ่น | `local var=value` | ใช้ได้เฉพาะในฟังก์ชัน |
| อาร์เรย์ | `arr=(a b c)` | indexed และ associative |
| source | `source file.sh` | โหลดไลบรารี |

---

## 8.9 แบบฝึกหัด

1. เขียนสคริปต์ที่รับพารามิเตอร์ชื่อและอายุ แสดงผล "Hello, Y, you are X years old!"
2. สร้างไลบรารีที่มีฟังก์ชัน `log` และ `error` แล้วใช้ในสคริปต์อื่น
3. เขียนฟังก์ชันเรียกตัวเอง (recursive) เพื่อคำนวณเลขฟิโบนักชี
4. ใช้ `mapfile` เพื่ออ่านไฟล์ทีละบรรทัดลงในอาร์เรย์ แล้วแสดงผลแบบกลับหลัง
