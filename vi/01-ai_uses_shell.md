# 1. Cách AI Sử Dụng Shell

## Một Dự Án Thực Tế Từ Đầu

---

### 1.1 Bối Cảnh Dự Án: Dự Án Kết Hợp Python + C

Hãy tưởng tượng bạn là một AI được giao nhiệm vụ viết một HTTP client hiệu năng cao.

Chiến lược của bạn rõ ràng: sử dụng **Python** cho lớp logic trên (dễ bảo trì, mở rộng được), và sử dụng **C** cho lớp networking đòi hỏi hiệu năng (nhanh, bộ nhớ thấp). Sau đó để Python gọi C qua `ctypes`.

Dự án này yêu cầu:
- Một file C (`curl.c`): triển khai HTTP GET hiệu năng cao
- Một file Python (`curl.py`): bọc nó thành API thân thiện với người dùng
- Một script build: tự động hóa quá trình biên dịch
- Các file test: xác minh chức năng

Trong thế giới của AI, mọi thứ bắt đầu với một lệnh `mkdir` duy nhất.

---

### 1.2 Sử Dụng Shell để Tạo Cấu Trúc Thư Mục

Khi AI bắt đầu một dự án mới, điều đầu tiên không phải là viết code, mà là thiết lập **cấu trúc thư mục sạch**.

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

Tại sao AI sử dụng `mkdir -p`? Vì `-p` an toàn:
- Nếu thư mục đã tồn tại, không có lỗi
- Có thể tạo thư mục lồng nhau trong một lần

Các kỹ sư con người thường mắc lỗi chạy `mkdir project` và `mkdir project/src` riêng biệt, rồi bối rối khi `src` không tồn tại. Thói quen của AI là **làm đúng ngay từ đầu**.

Bây giờ AI viết các lệnh này vào script `setup.sh` để tái tạo trong tương lai:

```bash
cat > setup.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_NAME="curl-project"

mkdir -p "$PROJECT_NAME/src"
mkdir -p "$PROJECT_NAME/include"
mkdir -p "$PROJECT_NAME/tests"
mkdir -p "$PROJECT_NAME/scripts"

echo "✓ Cấu trúc dự án đã được tạo: $PROJECT_NAME/"
ls -la "$PROJECT_NAME"
EOF

chmod +x setup.sh
./setup.sh
```

Bạn có để ý không? AI đã sử dụng cú pháp `cat > file << 'EOF'` ở đây—đây là **heredoc**, kỹ thuật cốt lõi mà AI sử dụng để viết code mà không cần trình soạn thảo. Chúng ta sẽ khám phá sâu về điều này trong Chương 4.

Kết quả:

```
✓ Cấu trúc dự án đã được tạo: curl-project/
total 8
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 curl-project/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/include/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/scripts/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:22 curl-project/src/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/tests/
```

---

### 1.3 Viết Code C với heredoc

Bây giờ AI viết code C cốt lõi. Đối với con người, mở Vim hay VS Code là tự nhiên. Nhưng cách tiếp cận của AI là:

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>

struct MemoryBuffer {
    char *data;
    size_t size;
};

static size_t write_callback(void *contents, size_t size, 
                             size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    struct MemoryBuffer *mem = (struct MemoryBuffer *)userp;
    
    char *ptr = realloc(mem->data, mem->size + realsize + 1);
    if (!ptr) {
        fprintf(stderr, "Memory allocation failed\n");
        return 0;
    }
    
    mem->data = ptr;
    memcpy(&(mem->data[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->data[mem->size] = 0;
    
    return realsize;
}

int fetch_url(const char *url, char **response, size_t *len) {
    CURL *curl;
    CURLcode res;
    struct MemoryBuffer chunk;
    
    chunk.data = malloc(1);
    chunk.size = 0;
    
    curl = curl_easy_init();
    if (!curl) {
        fprintf(stderr, "CURL initialization failed\n");
        free(chunk.data);
        return 1;
    }
    
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&chunk);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);
    
    res = curl_easy_perform(curl);
    
    if (res != CURLE_OK) {
        fprintf(stderr, "Request failed: %s\n", curl_easy_strerror(res));
        curl_easy_cleanup(curl);
        free(chunk.data);
        return 1;
    }
    
    long response_code;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
    printf("HTTP status code: %ld\n", response_code);
    
    *response = chunk.data;
    *len = chunk.size;
    
    curl_easy_cleanup(curl);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <URL>\n", argv[0]);
        return 1;
    }
    
    char *result = NULL;
    size_t len = 0;
    
    int status = fetch_url(argv[1], &result, &len);
    
    if (status == 0 && result) {
        printf("Response content (%zu bytes):\n%s\n", len, result);
        free(result);
    }
    
    return status;
}
EOF
```

**Code này làm gì?**

1. Sử dụng libcurl để triển khai HTTP GET requests
2. Cấp phát bộ nhớ động để lưu trữ nội dung response
3. Triển khai hàm callback để xử lý luồng dữ liệu
4. Cung cấp hàm `fetch_url()` để gọi từ bên ngoài
5. Hàm `main()` đóng vai trò như một công cụ dòng lệnh

---

### 1.4 Viết Python Wrapper với heredoc

Bây giờ AI viết file Python để gọi C:

```bash
cat > src/__init__.py << 'EOF'
"""
curl-py: Python + C Hybrid HTTP Client
"""

import ctypes
import os
from pathlib import Path

class CurlError(Exception):
    pass

class CurlFetcher:
    def __init__(self, lib_path=None):
        if lib_path is None:
            base_dir = Path(__file__).parent
            lib_path = base_dir / "libcurl_ext.so"
        
        if not os.path.exists(lib_path):
            raise CurlError(f"Library not found: {lib_path}")
        
        self.lib = ctypes.CDLL(str(lib_path))
        self.lib.fetch_url.argtypes = [ctypes.c_char_p, 
                                       ctypes.POINTER(ctypes.c_char_p),
                                       ctypes.POINTER(ctypes.c_size_t)]
        self.lib.fetch_url.restype = ctypes.c_int
    
    def get(self, url):
        response = ctypes.c_char_p()
        length = ctypes.c_size_t()
        
        if isinstance(url, str):
            url = url.encode('utf-8')
        
        result = self.lib.fetch_url(url, ctypes.byref(response), 
                                    ctypes.byref(length))
        
        if result != 0:
            raise CurlError(f"Request failed, error code: {result}")
        
        return response.value.decode('utf-8')
EOF
```

Sau đó viết một interface tiện lợi:

```bash
cat > curl.py << 'EOF'
#!/usr/bin/env python3
"""
curl.py - Command-line HTTP Client
Usage: python curl.py <URL>
"""

from src import CurlFetcher, CurlError
import sys

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <URL>", file=sys.stderr)
        sys.exit(1)
    
    url = sys.argv[1]
    
    try:
        fetcher = CurlFetcher()
        print(f"Requesting: {url}")
        content = fetcher.get(url)
        print(content)
    except CurlError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nCancelled", file=sys.stderr)
        sys.exit(130)

if __name__ == "__main__":
    main()
EOF
```

---

### 1.5 Biên Dịch Code C với gcc

Biên dịch là một trong những bước "hiển thị" nhất trong workflow của AI. AI làm như thế này:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**Tại sao AI viết như vậy?**

- `-shared -fPIC`: tạo position-independent code, tạo shared library
- `-O2`: tối ưu hóa cấp 2, cải thiện hiệu quả thực thi
- `-lcurl`: liên kết thư viện libcurl
- `-Wall -Wextra`: bật tất cả warnings, tránh vấn đề ẩn

AI bọc điều này vào một script build:

```bash
cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e

LIB_NAME="libcurl_ext.so"
SRC_FILE="src/curl.c"

echo "🔨 Đang biên dịch $SRC_FILE ..."

if ! command -v gcc &> /dev/null; then
    echo "Lỗi: gcc không tìm thấy, vui lòng cài đặt Xcode Command Line Tools"
    echo "Chạy: xcode-select --install"
    exit 1
fi

gcc -shared -fPIC -O2 \
    -o "$LIB_NAME" \
    "$SRC_FILE" \
    -lcurl \
    -Wall \
    -Wextra

if [ $? -eq 0 ]; then
    echo "✓ Build thành công: $LIB_NAME"
    ls -lh "$LIB_NAME"
else
    echo "✗ Build thất bại"
    exit 1
fi
EOF

chmod +x scripts/build.sh
./scripts/build.sh
```

---

### 1.6 Tự Động Hóa Toàn Bộ Quy Trình với Shell Script

Đây là bản chất của AI: **tự động hóa công việc lặp đi lặp lại**.

```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "============================================"
echo "  Môi trường phát triển curl-project"
echo "============================================"

echo ""
echo "🧹 Dọn dẹp file cũ..."
rm -f libcurl_ext.so
rm -rf __pycache__ src/__pycache__

echo ""
echo "🔨 Đang biên dịch code C..."
./scripts/build.sh

if [ -f "libcurl_ext.so" ]; then
    echo ""
    echo "🧪 Đang test chương trình C..."
    gcc -o curl_test src/curl.c -lcurl 2>/dev/null && {
        ./curl_test https://httpbin.org/get || true
        rm -f curl_test
    } || echo "(Bỏ qua test C, thiếu libcurl-dev)"
fi

echo ""
echo "🐍 Đang test Python wrapper..."
if [ -f "src/__init__.py" ]; then
    python3 -c "from src import CurlFetcher; print('✓ Module Python tải thành công')" 2>/dev/null || {
        echo "⚠ Test module Python cần biên dịch C trước"
    }
fi

echo ""
echo "============================================"
echo "  Sẵn sàng!"
echo "  Chạy 'python3 curl.py <URL>' để bắt đầu"
echo "============================================"
EOF

chmod +x scripts/dev.sh
```

Chạy nó:

```bash
./scripts/dev.sh
```

```
============================================
  Môi trường phát triển curl-project
============================================

🧹 Dọn dẹp file cũ...

🔨 Đang biên dịch code C...
✓ Build thành công: libcurl_ext.so
-rwxr-xr-x  1 ai  staff  45032 Mar 22 10:35 libcurl_ext.so

🐍 Đang test Python wrapper...
✓ Module Python tải thành công

============================================
  Sẵn sàng!
  Chạy 'python3 curl.py <URL>' để bắt đầu
============================================
```

---

### 1.7 Quy Trình Debug và Sửa Lỗi của AI

#### Lớp 1: Lỗi Biên Dịch

Giả sử code C đầu tiên của AI có lỗi cú pháp:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

Kết quả:

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

Phản ứng của AI: **Sửa ngay lập tức**. Các vấn đề thường gặp:
- Quên `#include <stdlib.h>` (`size_t`, `malloc`, `free`)
- Quên `#include <string.h>` (`memcpy`)
- Vấn đề đường dẫn header libcurl

Sửa đơn giản:

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
// ... nội dung đầy đủ ...
EOF
```

#### Lớp 2: Lỗi Runtime

Nếu chương trình biên dịch được nhưng thất bại khi chạy:

```bash
./curl_test https://example.com
# Kết quả: Request failed: Couldn't resolve host name
```

AI kiểm tra:
1. Mạng có hoạt động không: `ping -c 1 8.8.8.8`
2. DNS có khả dụng không: `nslookup example.com`
3. Firewall có chặn không

#### Lớp 3: Lỗi Logic

Lỗi logic là khó debug nhất. Phương pháp của AI là **xác minh từng bước**:

```bash
bash -x ./scripts/build.sh
```

Hiển thị mỗi lệnh được thực thi và giá trị biến

#### Lớp 4: Vấn Đề Bộ Nhớ

Nếu chương trình C có rò rỉ bộ nhớ, AI gợi ý sử dụng `valgrind`:

```bash
valgrind --leak-check=full ./curl_test https://example.com
```

---

### 1.8 Cấu Trúc Dự Án Hoàn Chỉnh

```
curl-project/
├── src/
│   ├── curl.c           # Triển khai C
│   └── __init__.py     # Python wrapper
├── include/            # C headers (dự trữ)
├── tests/              # File test (dự trữ)
├── scripts/
│   ├── setup.sh        # Khởi tạo thư mục
│   ├── build.sh        # Script build
│   └── dev.sh          # Môi trường phát triển
├── libcurl_ext.so      # Kết quả build
└── curl.py             # Công cụ dòng lệnh
```

---

### 1.9 Tổng Kết Shell từ Dự Án Này

1. **`mkdir -p`**: tạo thư mục an toàn, hỗ trợ cấu trúc lồng nhau
2. **`cat > file << 'EOF'`**: viết file không cần trình soạn thảo
3. **`chmod +x`**: cấp quyền thực thi
4. **`set -e`**: dừng script khi bất kỳ lệnh nào thất bại
5. **`&&` và `||`**: kết hợp các lệnh có điều kiện
6. **`gcc ...`**: quy trình biên dịch C tiêu chuẩn
7. **`bash -x`**: debug script từng bước

---

### 1.10 Tóm Tắt Chương

Khi AI viết code, nó **không bao giờ rời Terminal**.

Từ tạo cấu trúc thư mục, viết code, biên dịch, chạy, đến debug—tất cả đều trên màn hình đen với chữ trắng. Không có gợi ý từ VS Code, không có click chuột, không có trình soạn thảo WYSIWYG.

Đây không phải là hạn chế, đây là **hiệu quả**.

Sau khi đọc chương này, bạn nên hiểu:
- AI sử dụng các lệnh đơn lẻ để hoàn thành công việc như thế nào
- heredoc biến Shell thành "máy tạo văn bản" như thế nào
- Tại sao workflow của AI lại nhanh và có thể lặp lại

Trong các chương tiếp theo, chúng ta sẽ đi sâu vào mọi khía cạnh, từ lệnh đến script, từ debug đến tối ưu hóa.
