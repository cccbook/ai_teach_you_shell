# 8. Biến và Hàm

---

## 8.1 Cơ Bản về Biến

### Gán Biến Cơ Bản

```bash
# Chuỗi
name="Alice"
greeting="Xin chào, Thế giới!"

# Số
age=25
count=0

# Rỗng
empty=
empty2=""
```

### Đọc Biến

```bash
echo $name
echo ${name}    # Dạng khuyến nghị, rõ ràng hơn

# Trong dấu ngoặc kép
echo "Tên tôi là ${name}"
```

### Lỗi Thường Gặp

```bash
# Sai: có khoảng trắng xung quanh =
name = "Alice"   # Được hiểu là lệnh

# Sai: không có dấu ngoặc kép
greeting=Xin chào Thế giới  # Chỉ xuất "Xin chào"

# Đúng:
name="Alice"
greeting="Xin chào Thế giới"
```

---

## 8.2 Nghệ Thuật về Dấu Ngoặc

### Dấu Ngoặc Kép Đôi `"`
Mở rộng biến và thay thế lệnh

```bash
name="Alice"
echo "Xin chào, $name"           # Xin chào, Alice
echo "Hôm nay là $(date +%Y)"     # Hôm nay là 2026
```

### Dấu Ngoặc Kép Đơn `'`
Xuất nguyên văn, không mở rộng gì

```bash
name="Alice"
echo 'Xin chào, $name'           # Xin chào, $name
echo 'Hôm nay là $(date +%Y)'     # Hôm nay là $(date +%Y)
```

### Không Có Dấu Ngoặc
Tránh sử dụng trừ khi bạn chắc chắn biến không chứa khoảng trắng

---

## 8.3 Biến Đặc Biệt

```bash
$0          # Tên script
$1, $2...   # Tham số vị trí
$#          # Số lượng đối số
$@          # Tất cả đối số (từng cái)
$*          # Tất cả đối số (như một chuỗi)
$?          # Mã thoát của lệnh cuối
$$          # PID của tiến trình hiện tại
$!          # PID của tiến trình nền cuối
$-          # Các tùy chọn shell hiện tại
```

---

## 8.4 Mảng

### Sử Dụng Cơ Bản

```bash
# Định nghĩa mảng
colors=("đỏ" "xanh lá" "xanh dương")

# Đọc phần tử
echo ${colors[0]}    # đỏ
echo ${colors[1]}    # xanh lá

# Đọc tất cả
echo ${colors[@]}    # đỏ xanh lá xanh dương

# Độ dài mảng
echo ${#colors[@]}   # 3
```

### Mảng Kết Hợp (Bash 4+)

```bash
declare -A user
user["name"]="Alice"
user["email"]="alice@example.com"

echo ${user["name"]}    # Alice
```

---

## 8.5 Cơ Bản về Hàm

### Định Nghĩa Hàm

```bash
# Cách 1: từ khóa function
function greet {
    echo "Xin chào!"
}

# Cách 2: định nghĩa trực tiếp (khuyến nghị)
greet() {
    echo "Xin chào!"
}
```

### Tham Số Hàm

```bash
greet() {
    echo "Xin chào, $1!"
}

greet "Alice"    # Xin chào, Alice!
```

### Giá Trị Trả Về

```bash
# return: cho mã thoát (0-255)
check() {
    if [[ $1 -gt 10 ]]; then
        return 0  # thành công
    else
        return 1  # thất bại
    fi
}

if check 15; then
    echo "Lớn hơn 10"
fi
```

---

## 8.6 Biến Cục Bộ

```bash
counter() {
    local count=0
    ((count++))
    echo $count
}
```

---

## 8.7 Thư Viện Hàm

### Tạo Thư Viện

```bash
cat > lib.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date +%H:%M:%S)] $@"
}

error() {
    echo "[$(date +%H:%M:%S)] LỖI: $@" >&2
}

confirm() {
    read -p "$1 (c/k) " -n 1 -r
    echo
    [[ $REPLY =~ ^[CcKk]$ ]]
}
EOF
```

### Sử Dụng Thư Viện

```bash
#!/bin/bash

source lib.sh

log "Bắt đầu quá trình"
error "Có lỗi xảy ra"
confirm "Tiếp tục?" && echo "Tiếp tục"
```

---

## 8.8 Tham Khảo Nhanh

| Chủ đề | Cú pháp | Mô tả |
|-------|---------|-------|
| Gán | `var=value` | Không có khoảng trắng quanh = |
| Đọc | `$var` hoặc `${var}` | Dùng `${var}` |
| Ngoặc kép đôi | `"..."` | Mở rộng biến |
| Ngoặc kép đơn | `'...'` | Không mở rộng |
| Đối số | `$1`, `$2`, `$@` | Lấy tham số |
| Hàm | `name() { }` | định nghĩa khuyến nghị |
| Biến cục bộ | `local var=value` | chỉ trong hàm |
| Mảng | `arr=(a b c)` | có chỉ mục và kết hợp |
| source | `source file.sh` | Tải thư viện |

---

## 8.9 Bài Tập

1. Viết script nhận tham số tên và tuổi, xuất ra "Xin chào Y, bạn X tuổi!"
2. Tạo thư viện với hàm `log` và `error`, sử dụng nó trong script khác
3. Viết hàm đệ quy tính số Fibonacci
4. Dùng `mapfile` đọc file từng dòng vào mảng, sau đó xuất ngược lại
