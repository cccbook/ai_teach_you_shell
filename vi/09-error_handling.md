# 9. Xử Lý Lỗi

---

## 9.1 Tại Sao Xử Lý Lỗi Quan Trọng

Không có xử lý lỗi:
- Sau khi một lệnh thất bại, tiếp tục với thao tác sai
- Có thể xóa sai file
- Có thể ghi đè dữ liệu quan trọng
- Có thể để hệ thống ở trạng thái không nhất quán

Có xử lý lỗi:
- Dừng ngay khi có lỗi
- Cung cấp thông báo lỗi có ý nghĩa
- Dọn dẹp trước khi thoát

---

## 9.2 Mã Thoát

Mỗi lệnh trả về mã thoát sau khi thực thi:

- `0`: thành công
- `khác 0`: thất bại

```bash
# Kiểm tra mã thoát của lệnh cuối
ls /tmp
echo $?  # Output: 0 (nếu thành công)

ls /nonexistent
echo $?  # Output: 2 (nếu thất bại)
```

---

## 9.3 `set -e`: Dừng Khi Có Lỗi

```bash
#!/bin/bash
set -e

mkdir -p backup
cp important.txt backup/  # Nếu thất bại, script dừng ở đây
rm important.txt          # Sẽ không chạy đến đây
```

### Khi Nào Sử Dụng

Hầu hết các script nên dùng `set -e`:
- Script khởi tạo
- Script triển khai
- Script kiểm thử tự động

---

## 9.4 `set -u`: Lỗi Biến Chưa Định Nghĩa

```bash
#!/bin/bash
set -u

echo $undefined_var
# Output: bash: undefined_var: unbound variable
```

### Sử Dụng Kết Hợp

```bash
#!/bin/bash
set -euo pipefail

# -e: dừng khi có lỗi
# -u: lỗi biến chưa định nghĩa
# -o pipefail: pipe thất bại nếu bất kỳ lệnh nào thất bại
```

**Đây là header script tiêu chuẩn của AI!**

---

## 9.5 `trap`: Xử Lý Lỗi Than Lịch Sự

### Sử Dụng Cơ Bản

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Đang dọn dẹp..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# Chương trình chính
echo "Bắt đầu quá trình..."
```

### Bắt Lỗi

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    echo "❌ Script thất bại tại dòng $1, mã thoát: $exit_code"
    exit $exit_code
}

trap 'error_handler $LINENO' ERR
```

---

## 9.6 Hàm Lỗi Tùy Chỉnh

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "❌ $@" >&2
    exit 1
}

warn() {
    echo "⚠️ $@"
}

need_command() {
    command -v "$1" &>/dev/null || die "Cần lệnh: $1"
}

need_file() {
    [[ -f "$1" ]] || die "Cần file: $1"
}
```

---

## 9.7 Tham Khảo Nhanh

| Lệnh | Mô tả |
|-------|-------|
| `$?` | Mã thoát của lệnh cuối |
| `set -e` | Dừng khi có lỗi |
| `set -u` | Lỗi biến chưa định nghĩa |
| `set -o pipefail` | Pipe thất bại nếu lệnh nào thất bại |
| `set -euo pipefail` | Kết hợp (khuyến nghị) |
| `trap 'func' EXIT` | Thực thi khi thoát |
| `trap 'func' ERR` | Thực thi khi có lỗi |
| `trap 'func' INT` | Thực thi khi nhấn Ctrl+C |
| `exit 1` | Thoát với mã lỗi 1 |

---

## 9.8 Bài Tập

1. Viết script với `set -euo pipefail` xuất "Có lỗi xảy ra" khi thất bại
2. Tạo hàm `die()` in thông báo và thoát
3. Dùng `trap` hiển thị "Tạm biệt" khi script thoát
4. Viết script triển khai với tự động rollback khi thất bại
