# 3. Thao Tác File

---

## 3.1 Mô Hình Tinh Thần Của AI Về Filesystem

Trước khi đi vào từng lệnh, hãy hiểu cách AI nhìn filesystem.

Các kỹ sư thường nhìn filesystem **một cách trực quan**—giống như Windows Explorer hay macOS Finder, hiểu qua các biểu tượng và hình dạng thư mục.

Cách nhìn của AI hoàn toàn khác:

```
path          = vị trí tuyệt đối /home/user/project/src/main.py
relative      = đi xuống từ vị trí hiện tại
nodes         = mỗi file hoặc thư mục đều là một "node"
attributes    = quyền, kích thước, timestamp, chủ sở hữu
type          = file thường(-), thư mục(d), liên kết(l), thiết bị(b/c)
```

Khi AI thực thi `ls -la`, nó thấy:

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI có thể đọc ngay từ đây:
- Đâu là thư mục (`d`)
- Đâu là file ẩn (bắt đầu bằng `.`)
- Ai có quyền gì
- Kích thước file (xác định file lớn)
- Thời gian sửa đổi cuối cùng

---

## 3.2 `ls`: Lệnh Đầu Tiên AI Dùng Nhiều Nhất

Gần như trước mọi thao tác, AI đều thực thi `ls` để xác nhận trạng thái hiện tại.

### Các Kết Hợp `ls` Thường Dùng Của AI

```bash
# Liệt kê cơ bản
ls

# Hiển thị file ẩn (rất quan trọng!)
ls -a

# Dạng dài (thông tin chi tiết)
ls -l

# Dạng dài + file ẩn (phổ biến nhất)
ls -la

# Sắp xếp theo thời gian sửa đổi (mới nhất trước)
ls -lt

# Sắp xếp theo thời gian sửa đổi (cũ nhất trước)
ls -ltr

# Kích thước đọc được (K, M, G)
ls -lh

# Chỉ hiển thị thư mục
ls -d */

# Liệt kê tất cả file đệ quy
ls -R

# Hiển thị số inode (hữu ích cho hard links)
ls -li
```

### Quy Trình Thực Tế Của AI

```bash
cd ~/project && ls -la

# Kết quả:
# drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
# drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
# -rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
# -rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
# drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
# drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
# -rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json

# Phân tích của AI: có file .env, thư mục src và tests, package.json
# Đây là dự án Node.js
```

---

## 3.3 `cd`: Thư Mục AI Không Bao Giờ Quên

### Thói Quen `cd` Của AI

```bash
# Về thư mục home
cd ~

# Về thư mục trước đó (rất hữu ích!)
cd -

# Về thư mục cha
cd ..

# Vào thư mục con
cd src

# Điều hướng đường dẫn sâu (Tab completion)
cd ~/project/backend/api/v2/routes
```

### Pattern `cd` + `&&` Của AI

Đây là một trong những pattern phổ biến nhất của AI:

```bash
# Đầu tiên cd, chỉ thực thi lệnh tiếp theo sau khi xác nhận thành công
cd ~/project && ls -la
```

### Lỗi Thường Gặp

```bash
# Lỗi: không xác nhận thư mục tồn tại
cd nonexistent
# Output: bash: cd: nonexistent: No such file or directory

# Cách của AI: kiểm tra trước
[ -d "nonexistent" ] && cd nonexistent || echo "Thư mục không tồn tại"
```

---

## 3.4 `mkdir`: Nghệ Thuật Tạo Thư Mục

### Cách Dùng Cơ Bản

```bash
# Tạo một thư mục
mkdir myproject

# Tạo nhiều thư mục
mkdir src tests docs

# Tạo thư mục lồng nhau (-p là quan trọng!)
mkdir -p project/src/components project/tests
```

### Tại Sao AI Gần Như Luôn Dùng `-p`

Cờ `-p` (parents) có nghĩa:
1. Nếu thư mục đã tồn tại, **không có lỗi**
2. Nếu thư mục cha không tồn tại, **tạo tự động**

### Pattern Tạo Dự Án Điển Hình Của AI

```bash
# Tạo cấu trúc dự án tiêu chuẩn
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`: Nghệ Thuật Xóa

**Cảnh báo**: Đây là một trong những lệnh nguy hiểm nhất trong Shell.

### Cách Dùng Cơ Bản

```bash
# Xóa file
rm file.txt

# Xóa thư mục (cần -r)
rm -r directory/

# Xóa thư mục và mọi thứ bên trong (nguy hiểm!)
rm -rf directory/
```

### Sự Nguy Hiểm Của `rm -rf`

```bash
# Không bao giờ chạy cái này với root!
# rm -rf /

# Nếu bạn vô tình thêm một dấu cách:
rm -rf * 
# (dấu cách) = rm -rf xóa mọi thứ trong thư mục hiện tại
```

---

## 3.6 `cp`: Sao Chép File và Thư Mục

### Cách Dùng Cơ Bản

```bash
# Sao chép file
cp source.txt destination.txt

# Sao chép thư mục (cần -r)
cp -r source_directory/ destination_directory/

# Hiển thị tiến trình khi sao chép (-v verbose)
cp -v large_file.iso /backup/

# Chế độ tương tác (hỏi trước khi ghi đè)
cp -i *.py src/
```

### Sức Mạnh Của Wildcard

```bash
# Sao chép tất cả file .txt
cp *.txt backup/

# Sao chép tất cả file ảnh
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`: Di Chuyển và Đổi Tên

### Cách Dùng Cơ Bản

```bash
# Di chuyển file
mv file.txt backup/

# Di chuyển và đổi tên
mv oldname.txt newname.txt

# Đổi tên hàng loạt
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 Tham Khảo Nhanh

| Lệnh | Cách Dùng Cơ Bản | Cờ Thường Dùng | Ghi Chú Của AI |
|------|------------------|----------------|----------------|
| `ls` | `ls [path]` | `-l` dài, `-a` ẩn, `-h` human | `ls -la` luôn tốt |
| `cd` | `cd [path]` | `-` trước, `..` cha | `cd xxx &&` là thói quen tốt |
| `mkdir` | `mkdir [dir]` | `-p` lồng nhau | gần như luôn dùng `-p` |
| `rm` | `rm [file]` | `-r` đệ quy, `-f` force | cẩn thận `rm -rf /*` |
| `cp` | `cp [src] [dst]` | `-r` thư mục, `-i` hỏi, `-p` giữ | dùng `-i` để an toàn |
| `mv` | `mv [src] [dst]` | `-i` hỏi, `-n` không ghi đè | nó cũng là đổi tên |

---

## 3.9 Bài Tập

1. Sử dụng `mkdir -p` để tạo thư mục lồng nhau 3 cấp, sau đó xác nhận với `tree` hoặc `find`
2. Sao chép file lớn với `cp -v` và xem output
3. Đổi tên hàng loạt 10 file `.txt` thành `.md` với `mv`
4. Xóa file test với `rm -i` để trải nghiệm prompt
