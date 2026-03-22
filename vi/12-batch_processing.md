# 12. Xử Lý Hàng Loạt File

---

## 12.1 Đổi Tên Hàng Loạt

### Thay Đổi Phần Mở Rộng Đơn Giản

```bash
# Thay đổi tất cả .txt thành .md
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### Thêm Tiền Tố

```bash
# Thêm tiền tố thumb_ vào tất cả ảnh
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### Xóa Khoảng Trắng

```bash
# Thay khoảng trắng trong tên file bằng dấu gạch dưới
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### Thêm Số

```bash
# Đánh số file 001, 002, 003...
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 Xử Lý Ảnh Hàng Loạt

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "Đang xử lý: $img"
    
    if command -v convert &>/dev/null; then
        # Tạo thumbnail
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # Tạo phiên bản lớn
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ Xong: thumb_$img, large_$img"
    fi
done
```

---

## 12.3 Tìm và Thay Thế Hàng Loạt

```bash
#!/bin/bash

# Thay "foo" bằng "bar" trong tất cả file .txt
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done
```

---

## 12.4 Nén Hàng Loạt

```bash
#!/bin/bash

# Nén từng file
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# Giải nén tất cả
gunzip *.gz
```

---

## 12.5 Tải Hàng Loạt

```bash
#!/bin/bash
set -euo pipefail

while read -r url; do
    filename=$(basename "$url")
    echo "Đang tải: $url"
    curl -L -o "$filename" "$url"
done < urls.txt
```

---

## 12.6 Tham Khảo Nhanh

| Tác vụ | Lệnh |
|--------|------|
| Đổi phần mở rộng | `mv "$f" "${f%.old}.new"` |
| Thêm tiền tố | `mv "$f" "prefix_$f"` |
| Xóa khoảng trắng | `mv "$f" "${f// /_}"` |
| Thêm số | `mv "$f" "$(printf '%03d' $i)"` |
| Thay thế hàng loạt | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| Nén hàng loạt | `for f in *.txt; do gzip "$f"; done` |
| Tải hàng loạt | `while read url; do curl -LO "$url"; done < urls.txt` |

---

## 12.7 Bài Tập

1. Đổi tên hàng loạt 10 file từ `.txt` thành `.md`
2. Thêm tiền tố `thumb_` vào tất cả ảnh và tạo thumbnail
3. Thay `old-site.com` bằng `new-site.com` trong tất cả file `.html`
4. Tạo script dọn dẹp xóa tất cả file `__pycache__`, `.pyc`, và `.log`
