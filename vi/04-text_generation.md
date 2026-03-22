# 4. Tạo và Ghi Văn Bản

---

## 4.1 Tại Sao AI Không Cần Trình Soạn Thảo

Quy trình viết code của hầu hết kỹ sư:
1. Mở trình soạn thảo (VS Code, Vim, Emacs...)
2. Gõ code
3. Lưu file
4. Đóng trình soạn thảo

Đối với AI:
```
"Viết chương trình Python" = tạo ra một số văn bản
"Lưu chương trình này vào file" = ghi văn bản vào đĩa
```

Quá trình tạo code của AI là **quá trình tạo văn bản**. Vì vậy AI sử dụng các công cụ văn bản của Shell:

- `echo`: xuất một dòng văn bản
- `printf`: xuất có định dạng
- `heredoc`: xuất văn bản nhiều dòng (quan trọng nhất!)

---

## 4.2 `echo`: Xuất Đơn Giản Nhất

### Cách Dùng Cơ Bản

```bash
# Xuất chuỗi
echo "Hello, World!"

# Xuất biến
name="Alice"
echo "Hello, $name!"

# Xuất nhiều giá trị
echo "Hôm nay là $(date +%Y-%m-%d)"
```

### Các Bẫy Của `echo`

```bash
# echo thêm dòng mới theo mặc định
echo -n "Đang tải: "  # Không có dòng mới
```

### Ghi File Với `echo`

```bash
# Ghi đè
echo "Hello, World!" > file.txt

# Nối thêm
echo "Second line" >> file.txt
```

**Lưu ý**: Dùng `echo` cho file nhiều dòng rất khổ sở, nên AI gần như không dùng nó cho code. `heredoc` mới là ngôi sao.

---

## 4.3 `printf`: Xuất Có Định Dạng Mạnh Hơn

### So Sánh Với `echo`

```bash
# printf hỗ trợ định dạng kiểu C
printf "Giá trị: %.2f\n" 3.14159
# Output: Giá trị: 3.14

printf "%s\t%s\n" "Tên" "Tuổi"
```

### Tạo Bảng

```bash
printf "%-15s %10s\n" "Tên" "Giá"
printf "%-15s %10.2f\n" "iPhone" 999.99
printf "%-15s %10.2f\n" "MacBook" 1999.99
```

---

## 4.4 heredoc: Vũ Khí Cốt Lõi Của AI Để Viết Code

### heredoc là gì?

heredoc là cú pháp đặc biệt của Shell để **xuất văn bản nhiều dòng nguyên văn**.

```bash
cat << 'EOF'
Tất cả nội dung này
sẽ được xuất nguyên văn
bao gồm dòng mới, khoảng trắng
EOF
```

### Ghi File (Cách Dùng Phổ Biến Nhất Của AI)

```bash
cat > program.py << 'EOF'
#!/usr/bin/env python3

def hello(name):
    print(f"Hello, {name}!")

if __name__ == "__main__":
    hello("World")
EOF
```

### Tại Sao Dùng `'EOF'` (Dấu Ngoặc Đơn)?

```bash
# EOF dấu ngoặc đơn: không mở rộng gì cả
cat << 'EOF'
HOME là: $HOME
Hôm nay là: $(date)
EOF
# Output: HOME là: $HOME (không mở rộng)

# EOF dấu ngoặc kép hoặc không có dấu: sẽ mở rộng
cat << EOF
HOME là: $HOME
EOF
# Output: HOME là: /home/ai (đã mở rộng)
```

**Lựa chọn của AI**: gần như luôn dùng `'EOF'` (dấu ngoặc đơn). Vì code thường không cần mở rộng biến Shell.

---

## 4.5 AI Viết Các Loại File Khác Nhau Với heredoc

### Viết Chương Trình Python

```bash
cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""Điểm khởi đầu chính"""

import sys
import os

def main():
    print("Dự án Python + C Kết Hợp")
    print(f"Thư mục làm việc: {os.getcwd()}")

if __name__ == "__main__":
    main()
EOF
```

### Viết Shell Script

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

DEPLOY_HOST="server.example.com"

echo "🚀 Đang triển khai đến $DEPLOY_HOST"
rsync -avz --delete ./dist/ "$DEPLOY_HOST:/var/www/app/"
ssh "$DEPLOY_HOST" "systemctl restart myapp"
echo "✅ Triển khai hoàn tất!"
EOF

chmod +x scripts/deploy.sh
```

### Viết File Config

```bash
cat > config.json << 'EOF'
{
    "site_name": "Blog Của Tôi",
    "author": "Ẩn danh",
    "theme": "minimal"
}
EOF
```

### Viết Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "http.server", "8000"]
EOF
```

---

## 4.6 Các Bẫy Của heredoc Và Giải Pháp

### Bẫy 1: Có Dấu Ngoặc Đơn

```bash
# Vấn đề: EOF dấu ngoặc đơn không cho phép dấu ngoặc đơn
cat << 'EOF'
He's going.
EOF
# Output: lỗi cú pháp

# Giải pháp: dùng EOF dấu ngoặc kép
cat << "EOF"
He's going.
EOF
```

### Bẫy 2: Có `$` (Nhưng Không Muốn Mở Rộng)

```bash
# Vấn đề: EOF dấu ngoặc kép mở rộng $
cat << "EOF"
Giá là $100
EOF
# Output: Giá là (trống)

# Giải pháp: thoát riêng lẻ
cat << "EOF"
Giá là $$100
EOF
# Output: Giá là $100
```

---

## 4.7 Thực Hành: Xây Dựng Dự Án Hoàn Chỉnh Từ Đầu

```bash
# 1. Tạo cấu trúc thư mục
mkdir -p myblog/{src,themes,content}

# 2. Tạo file config
cat > myblog/config.json << 'EOF'
{
    "site_name": "Blog Của Tôi",
    "author": "Ẩn danh",
    "theme": "minimal"
}
EOF

# 3. Tạo chương trình Python chính
cat > myblog/src/blog.py << 'EOF'
#!/usr/bin/env python3
"""Trình tạo blog đơn giản"""
import json
from pathlib import Path

def load_config():
    config_path = Path(__file__).parent.parent / "config.json"
    with open(config_path) as f:
        return json.load(f)

if __name__ == "__main__":
    config = load_config()
    print(f"Đang tạo: {config['site_name']}")
EOF

# 4. Tạo script build
cat > myblog/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🔨 Đang build blog..."
cd "$(dirname "$0")"
python3 src/blog.py
echo "✅ Build hoàn tất!"
EOF

chmod +x myblog/build.sh

# 5. Xác minh cấu trúc
find myblog -type f | sort
```

---

## 4.8 Tham Khảo Nhanh

| Công Cụ | Mục Đích | Ví Dụ |
|---------|----------|--------|
| `echo` | Xuất một dòng | `echo "Hello"` |
| `echo -n` | Không có dòng mới | `echo -n "Đang tải..."` |
| `printf` | Xuất có định dạng | `printf "%s: %d\n" "tuổi" 25` |
| `>` | Ghi đè file | `echo "hi" > file.txt` |
| `>>` | Nối thêm vào file | `echo "hi" >> file.txt` |
| `<< 'EOF'` | heredoc (không mở rộng) | ưu tiên cho code |
| `<< "EOF"` | heredoc (mở rộng) | hiếm khi dùng |

---

## 4.9 Bài Tập

1. Tạo animation Loading với `echo -n` và vòng lặp `for`
2. Tạo bảng có định dạng (tên, tuổi, nghề) với `printf`
3. Viết chương trình Python 20 dòng với heredoc
4. Viết docker-compose.yml với heredoc
