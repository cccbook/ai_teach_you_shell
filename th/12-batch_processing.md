# 12. การประมวลผลไฟล์เป็นชุด

---

## 12.1 การเปลี่ยนชื่อเป็นชุด

### เปลี่ยนนามสกุลแบบง่าย

```bash
# เปลี่ยน .txt ทั้งหมดเป็น .md
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### เพิ่มคำนำหน้า

```bash
# เพิ่ม thumb_ นำหน้ารูปภาพทั้งหมด
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### ลบช่องว่าง

```bash
# แทนที่ช่องว่างในชื่อไฟล์ด้วยขีดเส้นใต้
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### เพิ่มตัวเลข

```bash
# ตั้งชื่อไฟล์เป็น 001, 002, 003...
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 การประมวลผลรูปภาพเป็นชุด

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "กำลังประมวลผล: $img"
    
    if command -v convert &>/dev/null; then
        # สร้างรูปย่อ
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # สร้างรูปขนาดใหญ่
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ เสร็จแล้ว: thumb_$img, large_$img"
    fi
done
```

---

## 12.3 ค้นหาและแทนที่เป็นชุด

```bash
#!/bin/bash

# แทนที่ "foo" ด้วย "bar" ในไฟล์ .txt ทั้งหมด
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done
```

---

## 12.4 การบีบอัดเป็นชุด

```bash
#!/bin/bash

# บีบอัดแต่ละไฟล์
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# คลายบีบอัดทั้งหมด
gunzip *.gz
```

---

## 12.5 การดาวน์โหลดเป็นชุด

```bash
#!/bin/bash
set -euo pipefail

while read -r url; do
    filename=$(basename "$url")
    echo "กำลังดาวน์โหลด: $url"
    curl -L -o "$filename" "$url"
done < urls.txt
```

---

## 12.6 สรุปย่อ

| งาน | คำสั่ง |
|------|---------|
| เปลี่ยนนามสกุล | `mv "$f" "${f%.old}.new"` |
| เพิ่มคำนำหน้า | `mv "$f" "prefix_$f"` |
| ลบช่องว่าง | `mv "$f" "${f// /_}"` |
| เพิ่มตัวเลข | `mv "$f" "$(printf '%03d' $i)"` |
| แทนที่เป็นชุด | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| บีบอัดเป็นชุด | `for f in *.txt; do gzip "$f"; done` |
| ดาวน์โหลดเป็นชุด | `while read url; do curl -LO "$url"; done < urls.txt` |

---

## 12.7 แบบฝึกหัด

1. เปลี่ยนชื่อไฟล์ 10 ไฟล์จาก `.txt` เป็น `.md` เป็นชุด
2. เพิ่ม `thumb_` นำหน้ารูปภาพทั้งหมดและสร้างรูปย่อ
3. แทนที่ `old-site.com` ด้วย `new-site.com` ในไฟล์ `.html` ทั้งหมด
4. สร้างสคริปต์ล้างข้อมูลที่ลบไฟล์ `__pycache__`, `.pyc`, และ `.log` ทั้งหมด
