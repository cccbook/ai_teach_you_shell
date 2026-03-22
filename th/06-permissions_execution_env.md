# 6. สิทธิ์, การรัน, สภาพแวดล้อม และการตั้งค่า

---

## 6.1 `chmod`: ศิลปะของสิทธิ์

### พื้นฐานสิทธิ์ของ Linux/Unix

```
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 .
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 README.md
-rwxr-xr-x  1 ai  staff   128 Mar 22 10:30 script.sh
```

9 ตัวอักษรแบ่งเป็น 3 กลุ่ม:
- `rwx` (owner): อ่าน, เขียน, รัน
- `r-x` (group): อ่าน, รัน
- `r--` (others): อ่านอย่างเดียว

### สองรูปแบบของ chmod

**ตัวเลข (octal)**:

```
r = 4, w = 2, x = 1

rwx = 7, r-x = 5, r-- = 4
```

การรวมที่ใช้บ่อย:
- `777` = rwxrwxrwx (อันตราย!)
- `755` = rwxr-xr-x
- `644` = rw-r--r--
- `700` = rwx------
- `600` = rw-------

**สัญลักษณ์**:

```bash
chmod u+x script.sh    # owner เพิ่ม execute
chmod g-w file.txt     # group ลบ write
chmod +x script.sh     # ทุกคนเพิ่ม execute
```

### การใช้ chmod ที่พบบ่อยของ AI

```bash
# ทำสคริปต์ executable (เกือบทุกสคริปต์)
chmod +x script.sh

# ทำให้ไดเรกทอรี traverse ได้
chmod +x ~/projects

# ไดเรกทอรีที่ group เขียนได้
chmod -R g+w project/
```

---

## 6.2 การรัน Shell Scripts

### วิธีรัน

```bash
# วิธีที่ 1: รันด้วย path (ต้องมีสิทธิ์ execute)
./script.sh

# วิธีที่ 2: ใช้ bash (ไม่ต้องมีสิทธิ์ execute)
bash script.sh

# วิธีที่ 3: ใช้ source (รันใน shell ปัจจุบัน)
source script.sh
```

### ใช้เมื่อไหร่?

| วิธี | เมื่อไหร่ใช้ | ลักษณะ |
|------|-------------|--------|
| `./script.sh` | รันมาตรฐาน | ต้อง `chmod +x`, subshell |
| `bash script.sh` | ระบุ shell | ไม่ต้องมีสิทธิ์ execute |
| `source script.sh` | ตั้งค่าสภาพแวดล้อม | รันใน shell ปัจจุบัน |

### ความแตกต่างสำคัญระหว่าง `source` กับ `./script`

```bash
# เนื้อหาของ script.sh: export MY_VAR="hello"

# รันด้วย ./
./script.sh
echo $MY_VAR  # Output: (ว่างเปล่า) ← ใน subshell, ตัวแปรหายไป

# รันด้วย source
source script.sh
echo $MY_VAR  # Output: hello ← ใน shell ปัจจุบัน, ตัวแปรอยู่
```

---

## 6.3 `export`: ตัวแปรสภาพแวดล้อม

```bash
# ตั้งค่าตัวแปรสภาพแวดล้อม
export NAME="Alice"
export PATH="$PATH:/new/directory"

# แสดงตัวแปรสภาพแวดล้อมทั้งหมด
export

# ตัวแปรที่ใช้บ่อย
echo $HOME      # ไดเรกทอรี home
echo $USER      # ชื่อผู้ใช้
echo $PATH      # path ค้นหา
echo $PWD       # ไดเรกทอรีปัจจุบัน
```

### ทำให้ตัวแปรสภาพแวดล้อมคงอยู่

```bash
# เพิ่มใน ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc

# ใช้การเปลี่ยนแปลง
source ~/.bashrc
```

---

## 6.4 `source`: โหลดไฟล์

เทียบเท่ากับ: **วาง** เนื้อหาของไฟล์ที่ตำแหน่งปัจจุบันโดยตรงและรัน

### การใช้ที่พบบ่อย

```bash
# โหลด virtual environment
source venv/bin/activate

# โหลดไฟล์ .env
source .env

# โหลด library
source ~/scripts/common.sh
```

### ใช้จริง: ไฟล์ config แบบแยกโมดูล

```bash
# config.sh
export DB_HOST="localhost"
export DB_PORT="5432"

# ใช้ในสคริปต์อื่น
source config.sh
psql -h $DB_HOST -p $DB_PORT
```

---

## 6.5 `env`: การจัดการสภาพแวดล้อม

```bash
# แสดงตัวแปรสภาพแวดล้อมทั้งหมด
env

# รันด้วยสภาพแวดล้อมสะอาด
env -i HOME=/tmp PATH=/bin sh

# ตั้งค่าตัวแปรแล้วรัน
env VAR1=value1 VAR2=value2 ./my_program
```

### หาคำสั่ง

```bash
which python      # หาตำแหน่งคำสั่ง
type cd           # หา shell builtins
whereis gcc       # หาไฟล์ที่เกี่ยวข้องทั้งหมด
```

---

## 6.6 `sudo`: เพิ่มสิทธิ์

```bash
# รันในฐานะ root
sudo rm /var/log/old.log

# รันในฐานะผู้ใช้เฉพาะ
sudo -u postgres psql

# แสดงสิ่งที่คุณทำได้
sudo -l
```

### คำเตือนอันตราย

```bash
# อย่ารันอันนี้!
sudo rm -rf /

# อย่าทำอันนี้!
sudo curl http://unknown-site.com | sh
```

---

## 6.7 คู่มืออ้างอิงฉบับย่อ

| คำสั่ง | จุดประสงค์ | Flags ที่ใช้บ่อย |
|--------|-----------|------------------|
| `chmod` | เปลี่ยนสิทธิ์ไฟล์ | `+x` เพิ่ม exec, `755` octal, `-R` recursive |
| `chown` | เปลี่ยนเจ้าของ | `user:group`, `-R` recursive |
| `./script` | รันสคริปต์ (ต้องมี x) | - |
| `bash script` | รันสคริปต์ (ไม่ต้องมี x) | - |
| `source` | รันใน shell ปัจจุบัน | - |
| `export` | ตั้งค่าตัวแปรสภาพแวดล้อม | `-n` ลบ |
| `env` | แสดง/จัดการสภาพแวดล้อม | `-i` clear |
| `sudo` | รันในฐานะ root | `-u user` ระบุผู้ใช้ |

---

## 6.8 แบบฝึกหัด

1. สร้างสคริปต์, ตั้งค่าสิทธิ์ด้วย `chmod 755`, จากนั้นรัน
2. รันสคริปต์ตัวแปรสภาพแวดล้อมเดียวกันด้วย `source` และ `./`, สังเกตความแตกต่าง
3. ใช้ `env -i` สร้างสภาพแวดล้อมสะอาด, รัน `python --version`
4. สร้างไฟล์ `.env`, ใช้ `source` โหลดตัวแปร