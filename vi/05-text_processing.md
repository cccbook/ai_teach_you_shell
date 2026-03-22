# 5. Xử Lý Văn Bản

---

## 5.1 Triết Lý Xử Lý Văn Bản Của AI

Trong thế giới của AI, **mọi thứ đều là văn bản**.

- Code là văn bản
- File cấu hình là văn bản
- Log là văn bản
- JSON, HTML, Markdown đều là văn bản

Vì vậy các lệnh xử lý văn bản là cốt lõi trong bộ công cụ của AI.

Khi kỹ sư gặp vấn đề: "Tôi cần một công cụ để xử lý cái này..."
Khi AI gặp vấn đề: "Cái này có thể giải quyết bằng `grep | sed | awk` trong một dòng."

---

## 5.2 `cat`: Nghệ Thuật Đọc File

### Cách Dùng Cơ Bản

```bash
# Hiển thị nội dung file
cat file.txt

# Kết hợp các file
cat part1.txt part2.txt > whole.txt

# Hiển thị số dòng
cat -n script.sh
```

### Mục Đích Thực Sự: Kết Hợp và Tạo

```bash
cat << 'EOF' > newfile.txt
Nội dung file
Có thể viết nhiều dòng
EOF
```

---

## 5.3 `head` và `tail`: Chỉ Xem Những Gì Bạn Cần

### `head`: Xem Phần Đầu

```bash
# 10 dòng đầu (mặc định)
head file.txt

# 5 dòng đầu
head -n 5 file.txt

# 100 byte đầu
head -c 100 file.txt
```

### `tail`: Xem Phần Cuối

```bash
# 10 dòng cuối (mặc định)
tail file.txt

# 5 dòng cuối
tail -n 5 file.txt

# Theo dõi file theo thời gian thực (phổ biến nhất!)
tail -f /var/log/syslog

# Theo dõi và grep
tail -f app.log | grep --line-buffered ERROR
```

### Xem Phạm Vi Dòng Cụ Thể

```bash
# Xem dòng 100-150
tail -n +100 file.txt | head -n 50
```

---

## 5.4 `wc`: Công Cụ Đếm

```bash
# Đếm dòng
wc -l file.txt

# Đếm dòng cho nhiều file
wc -l *.py

# Đếm file trong thư mục
ls | wc -l
```

---

## 5.5 `grep`: Vua Của Tìm Kiếm Văn Bản

### Cách Dùng Cơ Bản

```bash
# Tìm các dòng có "error"
grep "error" log.txt

# Bỏ qua phân biệt hoa thường
grep -i "error" log.txt

# Hiển thị số dòng
grep -n "error" log.txt

# Chỉ hiển thị tên file
grep -l "TODO" *.md

# Đảo ngược (các dòng không khớp)
grep -v "debug" log.txt

# Khớp từ nguyên
grep -w "error" log.txt
```

### Biểu Thức Chính Quy

```bash
# Khớp đầu dòng
grep "^Error" log.txt

# Khớp cuối dòng
grep "done.$" log.txt

# Bất kỳ ký tự nào
grep "e.or" log.txt

# Phạm vi
grep -E "[0-9]{3}-" log.txt
```

### Kỹ Thuật Nâng Cao

```bash
# Tìm kiếm đệ quy
grep -r "TODO" src/

# Chỉ định extension
grep -r "TODO" --include="*.py" src/

# Hiển thị các dòng xung quanh
grep -B 2 -A 2 "ERROR" log.txt

# Nhiều điều kiện (OR)
grep -E "error|warning|fatal" log.txt
```

---

## 5.6 `sed`: Công Cụ Thay Thế Văn Bản

### Thay Thế Cơ Bản

```bash
# Thay thế khớp đầu tiên
sed 's/old/new/' file.txt

# Thay thế tất cả khớp
sed 's/old/new/g' file.txt

# Thay thế tại chỗ
sed -i 's/old/new/g' file.txt

# Backup rồi thay thế
sed -i.bak 's/old/new/g' file.txt
```

### Xóa Dòng

```bash
# Xóa dòng trống
sed '/^$/d' file.txt

# Xóa dòng comment
sed '/^#/d' file.txt

# Xóa khoảng trắng cuối dòng
sed 's/[[:space:]]*$//' file.txt
```

### Ví Dụ Thực Tế

```bash
# Đổi tên hàng loạt (.txt → .md)
for f in *.txt; do
    mv "$f" "$(sed 's/.txt$/.md/' <<< "$f")"
done

# Xóa kết thúc dòng kiểu Windows
sed -i 's/\r$//' file.txt
```

---

## 5.7 `awk`: Dao Thuật Thụy Sĩ Của Xử Lý Văn Bản

### Khái Niệm Cơ Bản

`awk` xử lý văn bản từng dòng, tự động chia thành các trường ($1, $2, $3...), thực thi hành động chỉ định cho mỗi dòng.

### Cách Dùng Cơ Bản

```bash
# Chia mặc định bằng khoảng trắng
awk '{print $1}' file.txt

# Chỉ định delimiter
awk -F: '{print $1}' /etc/passwd

# Xuất nhiều trường
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### Xử Lý Có Điều Kiện

```bash
# Chỉ xử lý các dòng khớp
awk -F: '$3 > 1000 {print $1}' /etc/passwd

# BEGIN và END
awk 'BEGIN {print "Bắt đầu"} {print} END {print "Xong"}' file.txt
```

### Ví Dụ Thực Tế

```bash
# Tính tổng một cột CSV
awk -F, '{sum += $3} END {print sum}' data.csv

# Tìm giá trị lớn nhất
awk 'NR==1 {max=$3} $3>max {max=$3} END {print max}' data.csv

# Xuất có định dạng
awk '{printf "%-20s %10.2f\n", $1, $2}' data.txt
```

---

## 5.8 Thực Hành: Kết Hợp Tất Cả Công Cụ

### Kịch Bản: Phân Tích Log Server

```bash
# 1. Tìm các thông báo lỗi
grep -i "error" access.log

# 2. Đếm số lỗi
grep -ci "error" access.log

# 3. Tìm các lỗi phổ biến nhất
grep "error" access.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# 4. Đếm request theo giờ
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

### Kịch Bản: Sửa Đổi Code Hàng Loạt

```bash
# Thay đổi "print" thành "logger.info" trong tất cả file .py
find . -name "*.py" -exec sed -i 's/print(/logger.info(/g' {} +

# Thay đổi var thành const
find . -name "*.js" -exec sed -i 's/\bvar\b/const/g' {} +
```

---

## 5.9 Tham Khảo Nhanh

| Lệnh | Mục Đích | Cờ Thường Dùng |
|------|----------|----------------|
| `cat` | Hiển thị/kết hợp file | `-n` số dòng |
| `head` | Xem đầu file | `-n` dòng, `-c` byte |
| `tail` | Xem cuối file | `-n` dòng, `-f` theo dõi |
| `wc` | Đếm | `-l` dòng, `-w` từ, `-c` byte |
| `grep` | Tìm kiếm văn bản | `-i` bỏ qua, `-n` số dòng, `-r` đệ quy, `-c` đếm |
| `sed` | Thay thế văn bản | `s/old/new/g`, `-i` tại chỗ |
| `awk` | Xử lý trường | `-F` delimiter, `{print}` action |

---

## 5.10 Bài Tập

1. Sử dụng `head` và `tail` để xem dòng 100-120
2. Sử dụng `grep` để tìm tất cả user có `/bin/bash` trong /etc/passwd
3. Sử dụng `sed` để thay thế tất cả `\r\n` thành `\n`
4. Sử dụng `awk` để tính max, min và trung bình của một file số
