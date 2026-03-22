# 11. Ghi Log và Xuất Ra

---

## 11.1 Tại Sao Ghi Log Quan Trọng

Không có log:
- Bạn không biết script đang ở đâu
- Không biết tại sao nó thất bại
- Không biết nó đã làm gì khi thành công

Có log:
- Có thể theo dõi tiến độ
- Có đủ thông tin để debug lỗi
- Có thể kiểm tra lịch sử thực thi

---

## 11.2 Các Cấp Log Cơ Bản

```bash
#!/bin/bash

DEBUG=0
INFO=1
WARN=2
ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$INFO}

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ $level -ge $LOG_LEVEL ]]; then
        echo "[$timestamp] $message"
    fi
}

log $DEBUG "Đây là debug"
log $INFO "Đây là thông tin"
log $WARN "Đây là cảnh báo"
log $ERROR "Đây là lỗi"
```

---

## 11.3 Xuất Màu

```bash
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # Không Màu

log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

log_info "Cài đặt hoàn tất"
log_warn "Đang dùng mặc định"
log_error "Kết nối thất bại"
```

---

## 11.4 Xuất Ra File

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "Ứng dụng đã khởi động"
```

---

## 11.5 `tee`: Xuất Ra Cả Màn Hình và File

```bash
# Hiển thị và lưu đồng thời
echo "Xin chào" | tee output.txt

# Chế độ thêm vào
echo "Thế giới" | tee -a output.txt

# Cũng bắt stderr
./script.sh 2>&1 | tee output.log
```

---

## 11.6 Chỉ Báo Tiến Độ

### Dấu Chấm Đơn Giản

```bash
echo -n "Đang xử lý"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " Xong"
```

### Thanh Tiến Độ

```bash
draw_progress() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local chars=$((width * current / total))
    
    printf "\r[%s%s] %3d%%" \
        "$(printf '%*s' $chars | tr ' ' '=')" \
        "$(printf '%*s' $((width - chars)) | tr ' ' '-')" \
        "$percent"
    
    [[ $current -eq $total ]] && echo
}
```

---

## 11.7 Giải Thích `2>&1`

```bash
# 1 = stdout, 2 = stderr

# Chuyển hướng stderr sang stdout
command 2>&1

# Chuyển stdout ra file, stderr ra màn hình
command > output.txt

# Chuyển cả hai ra file
command > output.txt 2>&1

# Chuyển cả hai vào /dev/null (ẩn)
command > /dev/null 2>&1
```

---

## 11.8 Tham Khảo Nhanh

| Cú pháp | Mô tả |
|---------|-------|
| `echo "text"` | Xuất cơ bản |
| `echo -e "\033[31m"` | Xuất có màu |
| `2>&1` | Chuyển stderr sang stdout |
| `> file` | Ghi đè file |
| `>> file` | Thêm vào file |
| `tee file` | Xuất và lưu |
| `tee -a file` | Chế độ thêm vào |
| `/dev/null` | Bỏ qua đầu ra |

---

## 11.9 Bài Tập

1. Viết script hiển thị thông báo INFO, WARN, ERROR bằng các màu khác nhau
2. Dùng `tee` hiển thị và lưu đầu ra vào file log đồng thời
3. Tạo script xử lý file có thanh tiến độ
4. Xây dựng thư viện log hỗ trợ xuất file và các cấp log
