# 17. การเพิ่มประสิทธิภาพ

---

## 17.1 ทำไมประสิทธิภาพของ Shell จึงสำคัญ

Shell scripts มักถูกใช้สำหรับ:
- ประมวลผลไฟล์จำนวนมาก
- งานอัตโนมัติ
- CI/CD pipelines

สคริปต์ที่ช้าอาจทำให้ทั้งกระบวนการล่าช้าเป็นชั่วโมง การเพิ่มประสิทธิภาพ Shell scripts สามารถปรับปรุงประสิทธิภาพได้อย่างมาก

---

## 17.2 หลีกเลี่ยงคำสั่งภายนอก

```bash
# ช้: คำสั่งภายนอก
for f in *.txt; do
    name=$(basename "$f")
    echo "$name"
done

# เร็ว: shell builtins
for f in *.txt; do
    echo "${f##*/}"
done
```

### Builtin vs คำสั่งภายนอก

| ช้ | เร็ว | คำอธิบาย |
|------|------|----------|
| `$(cat file)` | `$(<file)` | อ่านโดยตรง |
| `$(basename $f)` | `${f##*/}` | การขยายพารามิเตอร์ |
| `$(expr $a + $b)` | `$((a + b))` | คณิตศาสตร์ |
| `$(echo $var)` | `"$var"` | ใช้โดยตรง |

---

## 17.3 ใช้ `while read` แทน `for`

```bash
# ช้: for + command substitution
for line in $(cat file.txt); do
    process "$line"
done

# เร็ว: while read
while IFS= read -r line; do
    process "$line"
done < file.txt
```

---

## 17.4 การประมวลผลแบบขนาน

### ใช้ `&` และ `wait`

```bash
#!/bin/bash

task1 &
task2 &
task3 &

wait

echo "All tasks complete"
```

### ใช้ `xargs -P`

```bash
# ตามลำดับ
cat files.txt | xargs -I {} process {}

# ขนาน (4 พร้อมกัน)
cat files.txt | xargs -P 4 -I {} process {}
```

---

## 17.5 หลีกเลี่ยง Subshells

```bash
# ช้: subshell ต่อการวนรอบ
for f in *.txt; do
    content=$(cat "$f")
    echo "$content" | wc -l
done

# เร็ว: subshell เดียว
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 คำสั่งอ้างอิงฉบับย่อ

| การเพิ่มประสิทธิภาพ | ช้ | เร็ว |
|--------------|------|------|
| อ่านไฟล์ | `$(cat file)` | `$(<file)` หรือ `while read` |
| Path | `$(basename $f)` | `${f##*/}` |
| คณิตศาสตร์ | `$(expr $a + $b)` | `$((a + b))` |
| ขนาน | ตามลำดับ | `&` + `wait` หรือ `xargs -P` |

---

## 17.7 แบบฝึกหัด

1. ใช้ `time` วัดเวลาที่ลูปประมวลผล 1000 ไฟล์
2. แปลงสคริปต์ที่ทำงานตามลำดับเป็นการประมวลผลแบบขนาน
3. เปรียบเทียบประสิทธิภาพของ `$(cat file)` กับ `while read`
4. ใช้ `xargs -P` เพิ่มความเร็วในการประมวลผลภาพแบบ batch
