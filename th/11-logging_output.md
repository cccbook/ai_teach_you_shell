# 11. การบันทึกล็อกและการแสดงผล

---

## 11.1 ทำไมการบันทึกล็อกจึงสำคัญ

ไม่มีการบันทึกล็อก:
- ไม่รู้ว่าสคริปต์อยู่ตรงไหน
- ไม่รู้ว่าทำไมมันล้มเหลว
- ไม่รู้ว่ามันทำอะไรเมื่อสำเร็จ

มีการบันทึกล็อก:
- สามารถติดตามความคืบหน้า
- มีข้อมูลเพียงพอสำหรับแก้ไขข้อผิดพลาด
- สามารถตรวจสอบประวัติการทำงาน

---

## 11.2 ระดับล็อกพื้นฐาน

```bash
#!/bin/bash

DEBUG=0
INFO=1
WARN=2
ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$INFO}

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ $level -ge $LOG_LEVEL ]]; then
        echo "[$timestamp] $message"
    fi
}

log $DEBUG "นี่คือ debug"
log $INFO "นี่คือ info"
log $WARN "นี่คือ warning"
log $ERROR "นี่คือ error"
```

---

## 11.3 การแสดงผลสี

```bash
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

log_info "การติดตั้งเสร็จสมบูรณ์"
log_warn "กำลังใช้ค่าเริ่มต้น"
log_error "การเชื่อมต่อล้มเหลว"
```

---

## 11.4 ส่งออกไปไฟล์

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "แอปพลิเคชันเริ่มทำงาน"
```

---

## 11.5 `tee`: แสดงผลทั้งหน้าจอและไฟล์พร้อมกัน

```bash
# แสดงและบันทึกพร้อมกัน
echo "Hello" | tee output.txt

# โหมดเพิ่มต่อ
echo "World" | tee -a output.txt

# จับ stderr ด้วย
./script.sh 2>&1 | tee output.log
```

---

## 11.6 ตัวบอกความคืบหน้า

### จุดง่ายๆ

```bash
echo -n "กำลังประมวลผล"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " เสร็จแล้ว"
```

### แถบความคืบหน้า

```bash
draw_progress() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local chars=$((width * current / total))
    
    printf "\r[%s%s] %3d%%" \
        "$(printf '%*s' $chars | tr ' ' '=')" \
        "$(printf '%*s' $((width - chars)) | tr ' ' '-')" \
        "$percent"
    
    [[ $current -eq $total ]] && echo
}
```

---

## 11.7 อธิบาย `2>&1`

```bash
# 1 = stdout, 2 = stderr

# เปลี่ยนเส้นทาง stderr ไปยัง stdout
command 2>&1

# เปลี่ยนเส้นทาง stdout ไปยังไฟล์, stderr ไปหน้าจอ
command > output.txt

# เปลี่ยนเส้นทางทั้งคู่ไปยังไฟล์
command > output.txt 2>&1

# เปลี่ยนเส้นทางทั้งคู่ไปยัง /dev/null (ซ่อน)
command > /dev/null 2>&1
```

---

## 11.8 สรุปย่อ

| ไวยากรณ์ | คำอธิบาย |
|---------|-------------|
| `echo "text"` | แสดงผลพื้นฐาน |
| `echo -e "\033[31m"` | แสดงผลสี |
| `2>&1` | เปลี่ยนเส้นทาง stderr ไปยัง stdout |
| `> file` | เขียนทับไฟล์ |
| `>> file` | เพิ่มต่อไฟล์ |
| `tee file` | แสดงผลและบันทึก |
| `tee -a file` | โหมดเพิ่มต่อ |
| `/dev/null` | ละเว้นผลลัพธ์ |

---

## 11.9 แบบฝึกหัด

1. เขียนสคริปต์ที่แสดงข้อความ INFO, WARN, ERROR ในสีที่ต่างกัน
2. ใช้ `tee` เพื่อแสดงผลและบันทึกลงไฟล์ล็อกพร้อมกัน
3. สร้างสคริปต์ประมวลผลไฟล์ที่มีแถบความคืบหน้า
4. สร้างไลบรารียูทิลิตี้การบันทึกที่รองรับการส่งออกไฟล์และระดับล็อก
