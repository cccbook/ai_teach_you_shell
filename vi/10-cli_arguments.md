# 10. Phân Tích Đối Số và Công Cụ CLI

---

## 10.1 Cơ Bản về Đối Số Dòng Lệnh

```bash
#!/bin/bash

echo "Script: $0"
echo "Đối số thứ nhất: $1"
echo "Đối số thứ hai: $2"
echo "Đối số thứ ba: ${3:-mặc định}"  # giá trị mặc định
echo "Số đối số: $#"
echo "Tất cả đối số: $@"
```

### Thực Thi

```bash
./script.sh foo bar
# Output:
# Script: ./script.sh
# Đối số thứ nhất: foo
# Đối số thứ hai: bar
# Đối số thứ ba: mặc định
# Số đối số: 2
# Tất cả đối số: foo bar
```

---

## 10.2 Phân Tích Đối Số Đơn Giản

### Tham Số Vị Trí

```bash
#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Cách dùng: $0 <file>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "Lỗi: file không tồn tại"
    exit 1
fi

echo "Đang xử lý $FILE..."
```

### Xử Lý Đối Số Tùy Chọn

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "Tùy chọn không xác định: $1"
            exit 1
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

$VERBOSE && echo "chế độ chi tiết bật"
[[ -n "$OUTPUT" ]] && echo "Xuất ra: $OUTPUT"
```

---

## 10.3 `getopts`: Phân Tích Tùy Chọn Chuẩn

```bash
#!/bin/bash

while getopts "hv:o:" opt; do
    case $opt in
        h)
            echo "Thông tin trợ giúp"
            exit 0
            ;;
        v)
            echo "chế độ chi tiết: $OPTARG"
            ;;
        o)
            echo "file xuất: $OPTARG"
            ;;
        \?)
            echo "Tùy chọn không hợp lệ: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "Đối số còn lại: $@"
```

### Tham Khảo Định Dạng Tùy Chọn

| Định dạng | Ý nghĩa |
|-----------|---------|
| `getopts "hv:"` | `-h` không đối số, `-v` cần đối số |
| `OPTARG` | Giá trị đối số của tùy chọn hiện tại |
| `OPTIND` | Chỉ mục đối số tiếp theo |

---

## 10.4 Đầu Vào Tương Tác

### `read`: Đọc Đầu Vào Người Dùng

```bash
#!/bin/bash

# Đọc cơ bản
read -p "Nhập tên của bạn: " name
echo "Xin chào, $name"

# Mật khẩu (ẩn)
read -sp "Nhập mật khẩu: " password
echo

# Đọc nhiều giá trị
read -p "Nhập tên và tuổi: " name age
echo "$name $age tuổi"

# Thời gian chờ
read -t 5 -p "Nhập trong 5 giây: " value
```

### Xác Nhận

```bash
confirm() {
    read -p "$1 (c/k) " -n 1 -r
    echo
    [[ $REPLY =~ ^[CcKk]$ ]]
}

if confirm "Xóa file này?"; then
    echo "Đang xóa..."
fi
```

---

## 10.5 Giao Diện Menu

```bash
#!/bin/bash

PS3="Chọn thao tác: "

select choice in "Tạo dự án" "Xóa dự án" "Thoát"; do
    case $choice in
        "Tạo dự án")
            echo "Đang tạo..."
            ;;
        "Xóa dự án")
            echo "Đang xóa..."
            ;;
        "Thoát")
            echo "Tạm biệt!"
            exit 0
            ;;
        *)
            echo "Lựa chọn không hợp lệ"
            ;;
    esac
done
```

---

## 10.6 Tham Khảo Nhanh

| Cú pháp | Mô tả |
|---------|-------|
| `$0` | Tên script |
| `$1`, `$2`... | Tham số vị trí |
| `$#` | Số đối số |
| `${var:-default}` | Giá trị mặc định |
| `getopts "hv:" opt` | Phân tích tùy chọn |
| `$OPTARG` | Đối số của tùy chọn hiện tại |
| `read -p "prompt:" var` | Đọc đầu vào |
| `read -s var` | Đầu vào ẩn (mật khẩu) |
| `read -t 5 var` | Hết giờ sau 5 giây |
| `select` | Giao diện menu |

---

## 10.7 Bài Tập

1. Viết công cụ CLI nhận `-n` cho số lượng, `-v` cho chế độ chi tiết
2. Dùng `getopts` phân tích `-h` (trợ giúp), `-o` (file xuất)
3. Viết hàm xác nhận chỉ tiếp tục khi trả lời c
4. Tạo menu máy tính đơn giản với `select`
