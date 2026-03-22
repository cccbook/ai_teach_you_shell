# 19. Chế Độ Hợp Tác AI + Shell

---

## 19.1 Hình Thức Hợp Tác Người-Máy Mới

Lập trình truyền thống:
- Con người gõ bằng bàn phím
- Con người dùng mouse để thao tác IDE
- Con người thực thi và test

Lập trình trong kỷ nguyên AI:
- Con người mô tả yêu cầu
- AI tạo Shell commands và scripts
- Con người review và thực thi
- Con người và AI debug cùng nhau

---

## 19.2 Mô Tả Yêu Cầu Cho AI

### Mô Tả Tốt

```bash
# Clear task
"Tìm tất cả .log files lớn hơn 100MB trong /var/log"

# Include expected output format
"Liệt kê tất cả .py files, hiển thị: số_dòng tên_file mỗi dòng"

# State constraints
"Nén tất cả .txt files, nhưng bỏ qua các file chứa 'test'"
```

### Mô Tả Xấu

```bash
# Too vague
"help me process logs"

# Unrealistic
"help me write an operating system"
```

---

## 19.3 Các Mẫu Shell Command Do AI Tạo

### Mẫu 1: Lệnh Đơn

```bash
# Human asks: find top 10 Python files with most lines
find . -name "*.py" -exec wc -l {} + | sort -rn | head -10
```

### Mẫu 2: Shell Script

```bash
# Human asks: batch process images
cat > process_images.sh << 'EOF'
#!/bin/bash
for img in *.jpg; do
    convert "$img" -resize 800x600 "thumb_$img"
done
EOF
```

---

## 19.4 Phát Triển Lặp

### Vòng 1: Tạo Phiên Bản Đầu Tiên

```bash
# Human: write a backup script
# AI generates initial version, then human tests, raises issues:

# Human: good, but need --dry-run mode
```

### Vòng 2: Thêm Tính Năng

```bash
# Human: also add error handling and logging
```

### Vòng 3: Debug

```bash
# Human: got 'Permission denied' error after running
# AI: fixes the problem...
```

---

## 19.5 Để AI Giúp Debug

```bash
# Human: got error after running this command
$ ./deploy.sh
# Output: /bin/bash^M: bad interpreter: No such file or directory

# AI: this is a Windows line ending problem. Run:
sed -i 's/\r$//' deploy.sh
```

---

## 19.6 Công Cụ Hợp Tác Đề Xuất

### Terminal Multiplexer

```bash
# tmux: split windows
tmux new -s mysession
# Ctrl+b %  # vertical split
# Ctrl+b "  # horizontal split
```

---

## 19.7 Bài Tập

1. Mô tả một tác vụ phức tạp và để AI tạo Shell commands
2. Để AI review một script có sẵn về vấn đề bảo mật
3. Sử dụng iteration để AI giúp viết một công cụ thực tế
4. Để AI giúp giải thích Shell code bạn không hiểu
