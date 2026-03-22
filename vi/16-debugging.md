# 16. Kỹ Thuật Debug

---

## 16.1 Tư Duy Debug của AI

Khi con người gặp lỗi: hoảng loạn, tìm kiếm trên mạng, copy-paste
Khi AI gặp lỗi: phân tích thông báo, suy luận nguyên nhân, thực thi sửa lỗi

Quy trình debug của AI:
```
Quan sát output lỗi → Hiểu loại lỗi → Xác định vấn đề → Sửa → Xác minh
```

---

## 16.2 `bash -x`: Theo Dõi Thực Thi

Cách debug đơn giản nhất: thêm flag `-x`

```bash
bash -x script.sh
```

Xuất mỗi dòng được thực thi với tiền tố `+`:

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### Chỉ Debug Một Phần

```bash
#!/bin/bash

echo "This won't show"
set -x
# Debugging starts here
name="Alice"
echo "Hello, $name"
set +x
# Debugging ends here
echo "This won't show"
```

---

## 16.3 Các Lỗi Thường Gặp và Cách Sửa

### Lỗi 1: Permission Denied

```bash
# Error
./script.sh
# Output: Permission denied

# Fix
chmod +x script.sh
./script.sh
```

### Lỗi 2: Command Not Found

```bash
# Error
python script.py
# Output: command not found: python

# Fix: use full path
/usr/bin/python3 script.py
```

### Lỗi 3: Undefined Variable

```bash
#!/bin/bash
set -u

echo $undefined_var
# Output: bash: undefined_var: unbound variable

# Fix: give default value
echo ${undefined_var:-default}
```

---

## 16.4 Debug với `echo`

Khi `-x` không đủ, thêm `echo` thủ công:

```bash
#!/bin/bash

echo "DEBUG: Entering function"
echo "DEBUG: Parameter = $@"

process() {
    echo "DEBUG: In process"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
}
```

---

## 16.5 Tham Khảo Nhanh

| Command | Description |
|---------|-------------|
| `bash -n script.sh` | Kiểm tra cú pháp |
| `bash -x script.sh` | Theo dõi thực thi |
| `set -x` | Bật chế độ debug |
| `set +x` | Tắt chế độ debug |
| `trap 'echo cmd' DEBUG` | Theo dõi mỗi lệnh |

---

## 16.6 Bài Tập

1. Chạy script với `bash -x` và quan sát định dạng output
2. Sử dụng `set -x` trong script để debug chỉ một function cụ thể
3. Tìm một lệnh bị lỗi, phân tích thông báo lỗi và sửa nó
4. Tạo xử lý lỗi graceful với `trap`
