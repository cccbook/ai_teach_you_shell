# 6. Phân Quyền, Thực Thi, Môi Trường và Cài Đặt

---

## 6.1 `chmod`: Nghệ Thuật Phân Quyền

### Cơ Bản Về Quyền Linux/Unix

```
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 .
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 README.md
-rwxr-xr-x  1 ai  staff   128 Mar 22 10:30 script.sh
```

9 ký tự chia thành 3 nhóm:
- `rwx` (chủ sở hữu): đọc, ghi, thực thi
- `r-x` (nhóm): đọc, thực thi
- `r--` (người khác): chỉ đọc

### chmod Hai Cách Biểu Diễn

**Số (bát phân)**:

```
r = 4, w = 2, x = 1

rwx = 7, r-x = 5, r-- = 4
```

Các kết hợp phổ biến:
- `777` = rwxrwxrwx (nguy hiểm!)
- `755` = rwxr-xr-x
- `644` = rw-r--r--
- `700` = rwx------
- `600` = rw-------

**Ký hiệu**:

```bash
chmod u+x script.sh    # Chủ sở hữu thêm quyền thực thi
chmod g-w file.txt     # Nhóm xóa quyền ghi
chmod +x script.sh     # Mọi người thêm quyền thực thi
```

### Cách Dùng `chmod` Phổ Biến Của AI

```bash
# Làm script thực thi được (hầu như mọi script)
chmod +x script.sh

# Làm thư mục có thể duyệt
chmod +x ~/projects

# Thư mục nhóm có quyền ghi
chmod -R g+w project/
```

---

## 6.2 Thực Thi Shell Script

### Các Phương Thức Thực Thi

```bash
# Phương thức 1: Thực thi theo đường dẫn (cần quyền thực thi)
./script.sh

# Phương thức 2: Dùng bash (không cần quyền thực thi)
bash script.sh

# Phương thức 3: Dùng source (thực thi trong shell hiện tại)
source script.sh
```

### Khi Nào Dùng Cái Nào?

| Phương thức | Khi Nào Dùng | Đặc điểm |
|--------------|--------------|-----------|
| `./script.sh` | Thực thi tiêu chuẩn | cần `chmod +x`, subshell |
| `bash script.sh` | Chỉ định shell | không cần quyền thực thi |
| `source script.sh` | Đặt môi trường | thực thi trong shell hiện tại |

### Sự Khác Biệt Quan Trọng Của `source` vs `./script`

```bash
# Nội dung script.sh: export MY_VAR="hello"

# Thực thi với ./
./script.sh
echo $MY_VAR  # Output: (trống) ← trong subshell, biến đã mất

# Thực thi với source
source script.sh
echo $MY_VAR  # Output: hello ← trong shell hiện tại, biến còn
```

---

## 6.3 `export`: Biến Môi Trường

```bash
# Đặt biến môi trường
export NAME="Alice"
export PATH="$PATH:/new/directory"

# Hiển thị tất cả biến môi trường
export

# Các biến phổ biến
echo $HOME      # Thư mục home
echo $USER      # Tên người dùng
echo $PATH      # Đường dẫn tìm kiếm
echo $PWD       # Thư mục hiện tại
```

### Lưu Biến Môi Trường Vĩnh Viễn

```bash
# Thêm vào ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc

# Áp dụng thay đổi
source ~/.bashrc
```

---

## 6.4 `source`: Tải File

Tương đương với: **dán** nội dung file vào vị trí hiện tại và thực thi.

### Cách Dùng Phổ Biến

```bash
# Tải virtual environment
source venv/bin/activate

# Tải file .env
source .env

# Tải thư viện
source ~/scripts/common.sh
```

### Thực Tế: File Config Module Hóa

```bash
# config.sh
export DB_HOST="localhost"
export DB_PORT="5432"

# Sử dụng trong script khác
source config.sh
psql -h $DB_HOST -p $DB_PORT
```

---

## 6.5 `env`: Quản Lý Môi Trường

```bash
# Hiển thị tất cả biến môi trường
env

# Thực thi với môi trường sạch
env -i HOME=/tmp PATH=/bin sh

# Đặt biến và thực thi
env VAR1=value1 VAR2=value2 ./my_program
```

### Tìm Lệnh

```bash
which python      # Tìm vị trí lệnh
type cd           # Tìm shell builtins
whereis gcc       # Tìm tất cả file liên quan
```

---

## 6.6 `sudo`: Leo Thang Đặc Quyền

```bash
# Thực thi với root
sudo rm /var/log/old.log

# Thực thi với user cụ thể
sudo -u postgres psql

# Hiển thị những gì bạn có thể làm
sudo -l
```

### Cảnh Báo Nguy Hiểm

```bash
# Không bao giờ chạy cái này!
sudo rm -rf /

# Không bao giờ làm cái này!
sudo curl http://unknown-site.com | sh
```

---

## 6.7 Tham Khảo Nhanh

| Lệnh | Mục Đích | Cờ Thường Dùng |
|------|----------|----------------|
| `chmod` | Thay đổi quyền file | `+x` thêm exec, `755` bát phân, `-R` đệ quy |
| `chown` | Thay đổi chủ sở hữu | `user:group`, `-R` đệ quy |
| `./script` | Thực thi script (cần x) | - |
| `bash script` | Thực thi script (không cần x) | - |
| `source` | Thực thi trong shell hiện tại | - |
| `export` | Đặt biến môi trường | `-n` xóa |
| `env` | Hiển thị/quản lý môi trường | `-i` xóa |
| `sudo` | Thực thi với root | `-u user` chỉ định user |

---

## 6.8 Bài Tập

1. Tạo một script, đặt quyền với `chmod 755`, sau đó thực thi nó
2. Thực thi cùng một script biến môi trường với `source` và `./`, quan sát sự khác biệt
3. Sử dụng `env -i` để tạo môi trường sạch, chạy `python --version`
4. Tạo file `.env`, dùng `source` để tải các biến của nó
