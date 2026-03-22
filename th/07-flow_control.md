# 7. การควบคุมการไหลและการวนซ้ำแบบมีเงื่อนไข

---

## 7.1 การรวมคำสั่ง: แก่นของ Shell

คำสั่งเดี่ยวมีความสามารถจำกัด ต่อเมื่อ **รวม** กันจึงทำ task ที่ซับซ้อนได้

AI ทรงพลังส่วนหนึ่งเพราะชอบการรวมเหล่านี้:

```bash
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -10
```

นี่หมายความว่า: "จาก access.log, หา errors, นับจำนวน, แสดง top 10"

---

## 7.2 `|` (Pipe): ศิลปะของการไหลของข้อมูล

pipe เปลี่ยน **output** ของคำสั่งก่อนหน้าเป็น **input** ของคำสั่งถัดไป

```bash
# เรียงเนื้อหาไฟล์
cat unsorted.txt | sort

# หาคำสั่งที่ใช้บ่อยที่สุด
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

# แยก IPs จาก log และนับ
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

### Piping stderr

```bash
# ส่ง stderr ไปที่ pipe
command1 2>&1 | command2

# หรือ Bash 4+
command1 |& command2
```

---

## 7.3 `&&`: รันถัดไปก็ต่อเมื่อสำเร็จ

**เฉพาะถ้า `command1` สำเร็จ (exit code = 0) `command2` ถึงจะรัน**

```bash
# สร้างไดเรกทอรีแล้ว cd เข้าไป
mkdir -p project && cd project

# คอมไพล์แล้วรัน
gcc -o program source.c && ./program

# ดาวน์โหลดแล้ว extract
curl -L -o archive.tar.gz http://example.com/file && tar -xzf archive.tar.gz
```

---

## 7.4 `||`: รันถัดไปก็ต่อเมื่อล้มเหลว

**เฉพาะถ้า `command1` ล้มเหลว (exit code ≠ 0) `command2` ถึงจะรัน**

```bash
# สร้างไฟล์ถ้ายังไม่มี
[ -f config.txt ] || echo "Config missing" > config.txt

# ลองวิธีหนึ่ง, ถ้าไม่ได้ใช้อีกวิธี
cd /opt/project || cd /home/user/project

# ทำให้สำเร็จแม้ล้มเหลว (พบบ่อยใน makefiles)
cp file.txt file.txt.bak || true
```

### รวม `&&` และ `||`

```bash
# นิพจน์แบบมีเงื่อนไข
[ -f config ] && echo "Found" || echo "Not found"

# เทียบเท่ากับ:
if [ -f config ]; then
    echo "Found"
else
    echo "Not found"
fi
```

---

## 7.5 `;`: รันไม่ว่าจะเกิดอะไร

```bash
# ทั้งสามรัน
mkdir /tmp/test ; cd /tmp/test ; pwd
```

---

## 7.6 `$()`: Command Substitution

**รันคำสั่ง, แทนที่ `$()` ด้วย output ของมัน**

```bash
# การใช้พื้นฐาน
echo "Today is $(date +%Y-%m-%d)"
# Output: Today is 2026-03-22

# ในตัวแปร
FILES=$(ls *.txt)

# หา directory name
DIR=$(dirname /path/to/file.txt)
BASE=$(basename /path/to/file.txt)

# คำนวณ
echo "Result is $((10 + 5))"
# Output: Result is 15
```

### เทียบกับ Backticks

```bash
# ทั้งสองเทียบเท่ากัน
echo "Today is $(date +%Y)"
echo "Today is `date +%Y`"

# แต่ $() ดีกว่าเพราะซ้อนได้
echo $(echo $(echo nested))
```

---

## 7.7 `[[ ]]` และ `[ ]`: การทดสอบแบบมีเงื่อนไข

### ทดสอบไฟล์

```bash
[[ -f file.txt ]]      # ไฟล์ปกติมีอยู่
[[ -d directory ]]     # ไดเรกทอรีมีอยู่
[[ -e path ]]           # มีอยู่ทุกประเภท
[[ -L link ]]           # symbolic link มีอยู่
[[ -r file ]]           # อ่านได้
[[ -w file ]]           # เขียนได้
[[ -x file ]]           # รันได้
[[ file1 -nt file2 ]]  # file1 ใหม่กว่า file2
```

### ทดสอบ String

```bash
[[ -z "$str" ]]        # string ว่างเปล่า
[[ -n "$str" ]]        # string ไม่ว่างเปล่า
[[ "$str" == "value" ]] # เท่ากัน
[[ "$str" =~ pattern ]]  # ตรง regex
```

### ทดสอบตัวเลข

```bash
[[ $num -eq 10 ]]      # เท่ากัน
[[ $num -ne 10 ]]      # ไม่เท่ากัน
[[ $num -gt 10 ]]      # มากกว่า
[[ $num -lt 10 ]]      # น้อยกว่า
```

---

## 7.8 `if`: คำสั่งแบบมีเงื่อนไข

```bash
if [[ condition ]]; then
    # ทำอะไรบางอย่าง
elif [[ condition2 ]]; then
    # ทำอย่างอื่น
else
    # fallback
fi
```

### ตัวอย่างสมบูรณ์

```bash
#!/bin/bash

FILE="config.yaml"

if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE does not exist"
    exit 1
fi

if [[ -r "$FILE" ]]; then
    echo "File is readable"
else
    echo "File is not readable"
fi
```

---

## 7.9 `for`: การวนซ้ำ

### ไวยากรณ์พื้นฐาน

```bash
for variable in list; do
    # ใช้ $variable
done
```

### รูปแบบที่ AI ใช้บ่อย

```bash
# ประมวลผลไฟล์ .txt ทั้งหมด
for file in *.txt; do
    echo "Processing $file"
done

# ช่วงตัวเลข
for i in {1..10}; do
    echo "Iteration $i"
done

# array
for color in red green blue; do
    echo $color
done

# loop แบบ C (Bash 3+)
for ((i=0; i<10; i++)); do
    echo $i
done
```

---

## 7.10 `while`: การวนซ้ำแบบมีเงื่อนไข

```bash
# อ่านบรรทัด
while IFS= read -r line; do
    echo "Read: $line"
done < file.txt

# loop นับ
count=0
while [[ $count -lt 10 ]]; do
    echo $count
    ((count++))
done
```

---

## 7.11 `case`: การจับคู่รูปแบบ

```bash
case $ACTION in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

### รูปแบบ Wildcard

```bash
case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.jpg|*.png|*.gif)
        echo "Image file"
        ;;
    *)
        echo "Unknown type"
        ;;
esac
```

---

## 7.12 คู่มืออ้างอิงฉบับย่อ

| สัญลักษณ์ | ชื่อ | คำอธิบาย |
|-----------|------|----------|
| `|` | Pipe | ส่ง output ไป input ถัดไป |
| `&&` | AND | รันถัดไปก็ต่อเมื่อก่อนสำเร็จ |
| `||` | OR | รันถัดไปก็ต่อเมื่อก่อนล้มเหลว |
| `;` | Semicolon | รันไม่ว่าจะเกิดอะไร |
| `$()` | Command substitution | รัน, แทนที่ด้วย output |
| `[[ ]]` | Conditional test | ไวยากรณ์ทดสอบที่แนะนำ |
| `if` | Conditional | แยกสาขาตามเงื่อนไข |
| `for` | Count loop | วนผ่าน list |
| `while` | Conditional loop | ทำซ้ำตราบที่เงื่อนไขจริง |
| `case` | Pattern match | หลายทางเลือก |

---

## 7.13 แบบฝึกหัด

1. ใช้ `|` รวม `ls`, `grep`, `wc` เพื่อนับไฟล์ `.log`
2. ใช้ `&&` ทำให้ `cd` สำเร็จก่อนทำต่อ
3. ใช้ `for` loop สร้าง 10 ไดเรกทอรี (dir1 ถึง dir10)
4. ใช้ `while read` อ่านและแสดง /etc/hosts
5. เขียนเครื่องคิดเลขง่ายๆ ด้วย `case` (add, sub, mul, div)