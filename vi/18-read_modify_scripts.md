# 18. Đọc và Sửa Script Của Người Khác

---

## 18.1 Tại Sao Đọc Script Của Người Khác

- Tiếp quản bảo trì dự án
- Sử dụng công cụ open source
- Debug vấn đề
- Học kỹ thuật mới

AI gặp các script không quen thuộc hàng ngày, vì vậy học cách nhanh chóng hiểu Shell scripts do người khác viết là rất quan trọng.

---

## 18.2 Quan Sát Ban Đầu

### Bước 1: Kiểm tra shebang

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # Use bash
#!/bin/sh        # Use POSIX sh (more compatible)
```

### Bước 2: Kiểm tra quyền và kích thước

```bash
ls -la script.sh
wc -l script.sh
```

### Bước 3: Kiểm tra cú pháp nhanh

```bash
bash -n script.sh  # Check syntax only, don't execute
```

---

## 18.3 Hiểu Cấu Trúc

### Cấu Trúc Thông Thường

```bash
#!/bin/bash
# Comment: script description

# Setup
set -euo pipefail
VAR="value"

# Function definitions
function help() { ... }

# Main flow
main() { ... }

# Execute
main "$@"
```

### Tìm Luồng Chính

```bash
# Check last lines
tail -20 script.sh

# Find function definitions
grep -n "^function\|^[[:space:]]*[a-z_]*(" script.sh
```

---

## 18.4 Các Lệnh Phân Tích Thường Dùng

```bash
# Find all function definitions
grep -n "^[[:space:]]*function" script.sh

# Find all conditionals
grep -n "if|\[\[" script.sh

# Find all loops
grep -n "for|while|do|done" script.sh

# Find command substitutions
grep -n '\$(' script.sh

# Find all exits
grep -n "exit" script.sh
```

---

## 18.5 Kiểm Tra Bảo Mật

```bash
# Find dangerous commands
grep -n "rm -rf" script.sh
grep -n "sudo" script.sh
grep -n "eval" script.sh

# Check variable injection risks
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh
```

---

## 18.6 Bài Tập

1. Phân tích một Shell script có sẵn với `grep` và `awk`
2. Tìm tất cả các biến trong script và hiểu mục đích của chúng
3. Sử dụng `bash -n` kiểm tra cú pháp của script
4. Thêm comment vào script không có comment giải thích từng phần
