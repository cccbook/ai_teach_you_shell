# 3. การดำเนินการไฟล์

---

## 3.1 ภาพจิตของ AI เกี่ยวกับ Filesystem

ก่อนจะลงลึกในแต่ละคำสั่ง, เข้าใจว่า AI มอง filesystem อย่างไร

วิศวกรมนุษย์โดยทั่วไปเห็น filesystem **แบบ visual** - เหมือน Windows Explorer หรือ macOS Finder, เข้าใจผ่านไอคอนและรูปทรงโฟลเดอร์

มุมมองของ AI แตกต่างทั้งหมด:

```
path          = ตำแหน่งสัมบูรณ์ /home/user/project/src/main.py
relative      = เดินลงมาจากตำแหน่งปัจจุบัน
nodes         = ทุกไฟล์หรือไดเรกทอรีคือ "node"
attributes    = permissions, size, timestamps, owner
type          = regular file(-), directory(d), link(l), device(b/c)
```

เมื่อ AI รัน `ls -la`, มันเห็น:

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI สามารถอ่านได้ทันที:
- อันไหนคือไดเรกทอรี (`d`)
- อันไหนคือไฟล์ซ่อน (ขึ้นต้นด้วย `.`)
- ใครมี permissions อะไร
- ขนาดไฟล์ (ดูว่าใหญ่ไหม)
- เวลาแก้ไขล่าสุด

---

## 3.2 `ls`: คำสั่งแรกที่ AI ใช้บ่อยที่สุด

เกือบทุก operation, AI รัน `ls` ก่อนเพื่อยืนยันสถานะปัจจุบัน

### การรวม `ls` ที่ AI ใช้บ่อย

```bash
# Basic list
ls

# Show hidden files (very important!)
ls -a

# Long format (detailed info)
ls -l

# Long format + hidden files (most common)
ls -la

# Sort by modification time (newest first)
ls -lt

# Sort by modification time (oldest first)
ls -ltr

# Human-readable sizes (K, M, G)
ls -lh

# Only show directories
ls -d */

# Recursively show all files
ls -R

# Show inode numbers (useful for hard links)
ls -li
```

### Workflow จริงของ AI

```bash
cd ~/project && ls -la

# Result:
# drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
# drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
# -rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
# -rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
# drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
# drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
# -rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json

# AI analysis: มีไฟล์ .env, ไดเรกทอรี src และ tests, ไฟล์ package.json
# นี่คือโปรเจกต์ Node.js
```

---

## 3.3 `cd`: ไดเรกทอรีที่ AI ไม่เคยลืม

### ความเคยชินของ AI ในการใช้ `cd`

```bash
# ไป home directory
cd ~

# ไปไดเรกทอรีก่อนหน้า (มีประโยชน์มาก!)
cd -

# ไป parent directory
cd ..

# เข้า subdirectory
cd src

# นำทาง paths ที่ลึก (ความสามารถของ Tab completion)
cd ~/project/backend/api/v2/routes
```

### รูปแบบ `cd` + `&&` ของ AI

นี่คือรูปแบบที่ AI ใช้บ่อยที่สุด:

```bash
# ก่อน cd, รันคำสั่งถัดไปหลังยืนยันว่าสำเร็จเท่านั้น
cd ~/project && ls -la
```

### ข้อผิดพลาดที่พบบ่อย

```bash
# ข้อผิดพลาด: ไม่ยืนยันว่าไดเรกทอรีมีอยู่
cd nonexistent
# Output: bash: cd: nonexistent: No such file or directory

# วิธีของ AI: ตรวจสอบก่อน
[ -d "nonexistent" ] && cd nonexistent || echo "Directory does not exist"
```

---

## 3.4 `mkdir`: ศิลปะของการสร้างไดเรกทอรี

### การใช้พื้นฐาน

```bash
# สร้างไดเรกทอรีเดียว
mkdir myproject

# สร้างหลายไดเรกทอรี
mkdir src tests docs

# สร้างไดเรกทอรีซ้อนกัน (-p สำคัญ!)
mkdir -p project/src/components project/tests
```

### ทำไม AI แทบจะใช้ `-p` เสมอ

 flag `-p` (parents) หมายความว่า:
1. ถ้าไดเรกทอรีมีอยู่แล้ว, **ไม่เกิด error**
2. ถ้า parent ไม่มีอยู่, **สร้างอัตโนมัติ**

### รูปแบบการสร้างโปรเจกต์ทั่วไปของ AI

```bash
# สร้างโครงสร้างโปรเจกต์มาตรฐาน
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`: ศิลปะของการลบ

**คำเตือน**: นี่คือหนึ่งในคำสั่งที่อันตรายที่สุดใน Shell

### การใช้พื้นฐาน

```bash
# ลบไฟล์
rm file.txt

# ลบไดเรกทอรี (ต้องใช้ -r)
rm -r directory/

# ลบไดเรกทอรีและทุกอย่าง (อันตราย!)
rm -rf directory/
```

### อันตรายของ `rm -rf`

```bash
# อย่ารันอันนี้ในฐานะ root!
# rm -rf /

# ถ้าคุณเผลอเพิ่ม space:
rm -rf * 
# (space) = rm -rf ลบทุกอย่างในไดเรกทอรีปัจจุบัน
```

---

## 3.6 `cp`: การคัดลอกไฟล์และไดเรกทอรี

### การใช้พื้นฐาน

```bash
# คัดลอกไฟล์
cp source.txt destination.txt

# คัดลอกไดเรกทอรี (ต้องใช้ -r)
cp -r source_directory/ destination_directory/

# แสดง progress ระหว่างคัดลอก (-v verbose)
cp -v large_file.iso /backup/

# โหมด interactive (ถามก่อนเขียนทับ)
cp -i *.py src/
```

### พลังของ Wildcard

```bash
# คัดลอกไฟล์ .txt ทั้งหมด
cp *.txt backup/

# คัดลอกไฟล์รูปภาพทั้งหมด
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`: การย้ายและเปลี่ยนชื่อ

### การใช้พื้นฐาน

```bash
# ย้ายไฟล์
mv file.txt backup/

# ย้ายและเปลี่ยนชื่อ
mv oldname.txt newname.txt

# เปลี่ยนชื่อหลายไฟล์
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 คู่มืออ้างอิงฉบับย่อ

| คำสั่ง | การใช้พื้นฐาน | Flags ที่ใช้บ่อย | หมายเหตุจาก AI |
|--------|---------------|------------------|----------------|
| `ls` | `ls [path]` | `-l` long, `-a` hidden, `-h` human | `ls -la` ใช้ได้ตลอด |
| `cd` | `cd [path]` | `-` previous, `..` parent | `cd xxx &&` เป็นนิสัยดี |
| `mkdir` | `mkdir [dir]` | `-p` nested | แทบจะใช้ `-p` เสมอ |
| `rm` | `rm [file]` | `-r` recursive, `-f` force | ระวัง `rm -rf /*` |
| `cp` | `cp [src] [dst]` | `-r` directory, `-i` ask, `-p` preserve | ใช้ `-i` เพื่อความปลอดภัย |
| `mv` | `mv [src] [dst]` | `-i` ask, `-n` no-overwrite | มันคือการเปลี่ยนชื่อ |

---

## 3.9 แบบฝึกหัด

1. ใช้ `mkdir -p` สร้างไดเรกทอรีซ้อนกัน 3 ชั้น, จากนั้นยืนยันด้วย `tree` หรือ `find`
2. คัดลอกไฟล์ใหญ่ด้วย `cp -v` และดู output
3. เปลี่ยนชื่อไฟล์ 10 `.txt` เป็น `.md` ด้วย `mv`
4. ลบไฟล์ทดสอบด้วย `rm -i` เพื่อสัมผัส prompt