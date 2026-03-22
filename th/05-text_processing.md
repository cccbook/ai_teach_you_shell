# 5. การประมวลผลข้อความ

---

## 5.1 ปรัชญาการประมวลผลข้อความของ AI

ในโลกของ AI, **ทุกอย่างคือ text**

- โค้ดคือ text
- config files คือ text
- logs คือ text
- JSON, HTML, Markdown ล้วนคือ text

ดังนั้นคำสั่งประมวลผล text คือ core ของ toolkit ของ AI

เมื่อวิศวกรมนุษย์เจอปัญหา: "ฉันต้องการ tool เพื่อจัดการนี่..."
เมื่อ AI เจอปัญหา: "นี่แก้ได้ด้วย `grep | sed | awk` ในบรรทัดเดียว"

---

## 5.2 `cat`: ศิลปะของการอ่านไฟล์

### การใช้พื้นฐาน

```bash
# แสดงเนื้อหาไฟล์
cat file.txt

# รวมไฟล์
cat part1.txt part2.txt > whole.txt

# แสดงเลขบรรทัด
cat -n script.sh
```

### จุดประสงค์ที่แท้จริง: รวมและสร้าง

```bash
cat << 'EOF' > newfile.txt
File content
Can write many lines
EOF
```

---

## 5.3 `head` และ `tail`: เห็นแค่สิ่งที่ต้องการ

### `head`: ดูส่วนต้น

```bash
# 10 บรรทัดแรก (ค่าเริ่มต้น)
head file.txt

# 5 บรรทัดแรก
head -n 5 file.txt

# 100 bytes แรก
head -c 100 file.txt
```

### `tail`: ดูส่วนท้าย

```bash
# 10 บรรทัดสุดท้าย (ค่าเริ่มต้น)
tail file.txt

# 5 บรรทัดสุดท้าย
tail -n 5 file.txt

# ติดตามไฟล์แบบ real-time (ใช้บ่อยที่สุด!)
tail -f /var/log/syslog

# ติดตามและ grep
tail -f app.log | grep --line-buffered ERROR
```

### ดูช่วงบรรทัดเฉพาะ

```bash
# ดูบรรทัด 100-150
tail -n +100 file.txt | head -n 50
```

---

## 5.4 `wc`: เครื่องมือนับ

```bash
# นับบรรทัด
wc -l file.txt

# นับบรรทัดหลายไฟล์
wc -l *.py

# นับไฟล์ในไดเรกทอรี
ls | wc -l
```

---

## 5.5 `grep`: ราชาแห่งการค้นหา text

### การใช้พื้นฐาน

```bash
# ค้นหาบรรทัดที่มี "error"
grep "error" log.txt

# ไม่สนใจตัวพิมพ์เล็กใหญ่
grep -i "error" log.txt

# แสดงเลขบรรทัด
grep -n "error" log.txt

# แสดงแค่ชื่อไฟล์
grep -l "TODO" *.md

# กลับกัน (บรรทัดที่ไม่ตรง)
grep -v "debug" log.txt

# จับคำทั้งคำ
grep -w "error" log.txt
```

### Regular Expressions

```bash
# จับต้น
grep "^Error" log.txt

# จับท้าย
grep "done.$" log.txt

# ตัวอักษรใดก็ได้
grep "e.or" log.txt

# ช่วง
grep -E "[0-9]{3}-" log.txt
```

### เทคนิคขั้นสูง

```bash
# ค้นหาแบบ recursive
grep -r "TODO" src/

# เฉพาะนามสกุลที่กำหนด
grep -r "TODO" --include="*.py" src/

# แสดง context lines
grep -B 2 -A 2 "ERROR" log.txt

# หลายเงื่อนไข (OR)
grep -E "error|warning|fatal" log.txt
```

---

## 5.6 `sed`: เครื่องมือแทนที่ text

### การแทนที่พื้นฐาน

```bash
# แทนที่การจับครั้งแรก
sed 's/old/new/' file.txt

# แทนที่ทุกการจับ
sed 's/old/new/g' file.txt

# แทนที่ในไฟล์
sed -i 's/old/new/g' file.txt

# backup แล้วแทนที่
sed -i.bak 's/old/new/g' file.txt
```

### ลบบรรทัด

```bash
# ลบบรรทัดว่าง
sed '/^$/d' file.txt

# ลบบรรทัด comment
sed '/^#/d' file.txt

# ลบ trailing whitespace
sed 's/[[:space:]]*$//' file.txt
```

### ตัวอย่างใช้งานจริง

```bash
# เปลี่ยนนามสกุลเป็นชุด (.txt → .md)
for f in *.txt; do
    mv "$f" "$(sed 's/.txt$/.md/' <<< "$f")"
done

# ลบ Windows line endings
sed -i 's/\r$//' file.txt
```

---

## 5.7 `awk`: มีดอันฟอร์สวิสของการประมวลผล text

### แนวคิดพื้นฐาน

`awk` ประมวลผล text ทีละบรรทัด, แบ่งอัตโนมัติเป็น fields ($1, $2, $3...), รัน actions ที่กำหนดสำหรับแต่ละบรรทัด

### การใช้พื้นฐาน

```bash
# แบ่งด้วย whitespace เริ่มต้น
awk '{print $1}' file.txt

# กำหนด delimiter
awk -F: '{print $1}' /etc/passwd

# แสดงหลาย fields
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### การประมวลผลแบบมีเงื่อนไข

```bash
# ประมวลผลเฉพาะบรรทัดที่ตรง
awk -F: '$3 > 1000 {print $1}' /etc/passwd

# BEGIN และ END
awk 'BEGIN {print "Start"} {print} END {print "Done"}' file.txt
```

### ตัวอย่างใช้งานจริง

```bash
# รวม CSV column
awk -F, '{sum += $3} END {print sum}' data.csv

# หาค่ามากที่สุด
awk 'NR==1 {max=$3} $3>max {max=$3} END {print max}' data.csv

# Output ที่จัดรูปแบบ
awk '{printf "%-20s %10.2f\n", $1, $2}' data.txt
```

---

## 5.8 การฝึก: รวมเครื่องมือทั้งหมด

### สถานการณ์: วิเคราะห์ Server Logs

```bash
# 1. หา error messages
grep -i "error" access.log

# 2. นับ errors
grep -ci "error" access.log

# 3. หา errors ที่พบบ่อยที่สุด
grep "error" access.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# 4. นับ requests ต่อชั่วโมง
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

### สถานการณ์: แก้ไขโค้ดเป็นชุด

```bash
# เปลี่ยน "print" เป็น "logger.info" ในทุก .py
find . -name "*.py" -exec sed -i 's/print(/logger.info(/g' {} +

# เปลี่ยน var เป็น const
find . -name "*.js" -exec sed -i 's/\bvar\b/const/g' {} +
```

---

## 5.9 คู่มืออ้างอิงฉบับย่อ

| คำสั่ง | จุดประสงค์ | Flags ที่ใช้บ่อย |
|--------|-----------|------------------|
| `cat` | แสดง/รวมไฟล์ | `-n` เลขบรรทัด |
| `head` | ดูต้นไฟล์ | `-n` บรรทัด, `-c` bytes |
| `tail` | ดูท้ายไฟล์ | `-n` บรรทัด, `-f` follow |
| `wc` | นับ | `-l` บรรทัด, `-w` คำ, `-c` bytes |
| `grep` | ค้นหา text | `-i` ignore, `-n` เลขบรรทัด, `-r` recursive, `-c` นับ |
| `sed` | แทนที่ text | `s/old/new/g`, `-i` in-place |
| `awk` | ประมวลผล fields | `-F` delimiter, `{print}` action |

---

## 5.10 แบบฝึกหัด

1. ใช้ `head` และ `tail` ดูบรรทัด 100-120
2. ใช้ `grep` หาผู้ใช้ที่มี `/bin/bash` ทั้งหมดใน /etc/passwd
3. ใช้ `sed` แทนที่ `\r\n` ทั้งหมดด้วย `\n`
4. ใช้ `awk` คำนวณ max, min และ average ของไฟล์ตัวเลข