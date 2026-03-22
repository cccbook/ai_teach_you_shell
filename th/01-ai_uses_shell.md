# 1. AI ใช้ Shell อย่างไร

## โปรเจกต์จริงจากจุดเริ่มต้น

---

### 1.1 พื้นหลังโปรเจกต์: Python + C Hybrid Project

ลองจินตนาการว่าคุณเป็น AI ที่ได้รับมอบหมายให้เขียน HTTP Client ประสิทธิภาพสูง

กลยุทธ์ของคุณชัดเจน: ใช้ **Python** สำหรับส่วน logic ชั้นบน (ซ่อมบำรุงได้ง่าย, ขยายได้) และใช้ **C** สำหรับชั้นเครือข่ายที่ต้องการประสิทธิภาพสูง (เร็ว, ใช้หน่วยความจำต่ำ) แล้วให้ Python เรียก C ผ่าน `ctypes`

โปรเจกต์นี้ต้องการ:
- ไฟล์ C (`curl.c`): สร้าง HTTP GET ประสิทธิภาพสูง
- ไฟล์ Python (`curl.py`): ห่อด้วย API ที่ใช้งานง่าย
- สคริปต์ build: ทำให้กระบวนการคอมไพล์เป็นอัตโนมัติ
- ไฟล์ทดสอบ: ตรวจสอบความถูกต้อง

ในโลกของ AI, ทุกอย่างเริ่มต้นด้วยคำสั่ง `mkdir` เพียงคำสั่งเดียว

---

### 1.2 ใช้ Shell สร้างโครงสร้างไดเรกทอรี

เมื่อ AI เริ่มโปรเจกต์ใหม่, สิ่งแรกไม่ใช่การเขียนโค้ด แต่คือการสร้าง **โครงสร้างไดเรกทอรีที่เรียบร้อย**

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

ทำไม AI ถึงใช้ `mkdir -p`? เพราะ `-p` ปลอดภัย:
- ถ้าไดเรกทอรีมีอยู่แล้ว, ไม่เกิด error
- สามารถสร้างไดเรกทอรีซ้อนกันได้ในครั้งเดียว

วิศวกรมนุษย์มักทำผิดพลาดโดยรัน `mkdir project` และ `mkdir project/src` แยกกัน แล้วสับสนเมื่อ `src` ไม่มีอยู่ ความเคยชินของ AI คือ **ทำให้ถูกต้องตั้งแต่แรก**

ตอนนี้ AI เขียนคำสั่งเหล่านี้ลงในสคริปต์ `setup.sh` เพื่อสร้างใหม่ในอนาคต:

```bash
cat > setup.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_NAME="curl-project"

mkdir -p "$PROJECT_NAME/src"
mkdir -p "$PROJECT_NAME/include"
mkdir -p "$PROJECT_NAME/tests"
mkdir -p "$PROJECT_NAME/scripts"

echo "✓ Project structure created: $PROJECT_NAME/"
ls -la "$PROJECT_NAME"
EOF

chmod +x setup.sh
./setup.sh
```

สังเกตได้ไหม? AI ใช้ไวยากรณ์ `cat > file << 'EOF'` ที่นี่ - นี่คือ **heredoc** เทคนิคหลักที่ AI ใช้เขียนโค้ดโดยไม่ต้องใช้ editor เราจะสำรวจอย่างลึกซึ้งในบทที่ 4

Output:

```
✓ Project structure created: curl-project/
total 8
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 curl-project/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/include/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/scripts/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:22 curl-project/src/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/tests/
```

---

### 1.3 เขียนโค้ด C ด้วย heredoc

ตอนนี้ AI เขียนโค้ด C หลัก สำหรับมนุษย์, การเปิด Vim หรือ VS Code เป็นเรื่องปกติ แต่วิธีของ AI คือ:

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

**โค้ดนี้ทำอะไร?**

1. ใช้ libcurl เพื่อสร้าง HTTP GET requests
2. จัดสรรหน่วยความจำแบบไดนามิกเพื่อเก็บ response content
3. สร้าง callback function เพื่อจัดการ data streams
4. มี function `fetch_url()` สำหรับเรียกจากภายนอก
5. `main()` function ทำหน้าที่เป็น command-line tool

---

### 1.4 เขียน Python Wrapper ด้วย heredoc

ตอนนี้ AI เขียนไฟล์ Python เพื่อเรียก C:

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

จากนั้นเขียน interface ที่ใช้งานง่าย:

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

### 1.5 คอมไพล์โค้ด C ด้วย gcc

การคอมไพล์เป็นหนึ่งในขั้นตอนที่ "เห็นได้ชัดที่สุด" ใน workflow ของ AI AI ทำแบบนี้:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**ทำไม AI ถึงเขียนแบบนี้?**

- `-shared -fPIC`: สร้าง position-independent code, สร้าง shared library
- `-O2`: optimization ระดับ 2, ปรับปรุงประสิทธิภาพการทำงาน
- `-lcurl`: เชื่อมต่อ libcurl library
- `-Wall -Wextra`: เปิดใช้งาน warnings ทั้งหมด, หลีกเลี่ยงปัญหาที่ซ่อนอยู่

AI ห่อสิ่งนี้เป็นสคริปต์ build:

```bash
cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e

LIB_NAME="libcurl_ext.so"
SRC_FILE="src/curl.c"

echo "🔨 Compiling $SRC_FILE ..."

if ! command -v gcc &> /dev/null; then
    echo "Error: gcc not found, please install Xcode Command Line Tools"
    echo "Run: xcode-select --install"
    exit 1
fi

gcc -shared -fPIC -O2 \
    -o "$LIB_NAME" \
    "$SRC_FILE" \
    -lcurl \
    -Wall \
    -Wextra

if [ $? -eq 0 ]; then
    echo "✓ Build successful: $LIB_NAME"
    ls -lh "$LIB_NAME"
else
    echo "✗ Build failed"
    exit 1
fi
EOF

chmod +x scripts/build.sh
./scripts/build.sh
```

---

### 1.6 ทำให้กระบวนการทั้งหมดเป็นอัตโนมัติด้วย Shell Script

นี่คือแก่นของ AI: **ทำให้งานที่ทำซ้ำๆ เป็นอัตโนมัติ**

```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "============================================"
echo "  curl-project Development Environment"
echo "============================================"

echo ""
echo "🧹 Cleaning old files..."
rm -f libcurl_ext.so
rm -rf __pycache__ src/__pycache__

echo ""
echo "🔨 Compiling C code..."
./scripts/build.sh

if [ -f "libcurl_ext.so" ]; then
    echo ""
    echo "🧪 Testing C program..."
    gcc -o curl_test src/curl.c -lcurl 2>/dev/null && {
        ./curl_test https://httpbin.org/get || true
        rm -f curl_test
    } || echo "(Skipping C test, missing libcurl-dev)"
fi

echo ""
echo "🐍 Testing Python wrapper..."
if [ -f "src/__init__.py" ]; then
    python3 -c "from src import CurlFetcher; print('✓ Python module loaded successfully')" 2>/dev/null || {
        echo "⚠ Python module test requires C compilation first"
    }
fi

echo ""
echo "============================================"
echo "  Ready!"
echo "  Run 'python3 curl.py <URL>' to start"
echo "============================================"
EOF

chmod +x scripts/dev.sh
```

รัน:

```bash
./scripts/dev.sh
```

```
============================================
  curl-project Development Environment
============================================

🧹 Cleaning old files...

🔨 Compiling C code...
✓ Build successful: libcurl_ext.so
-rwxr-xr-x  1 ai  staff  45032 Mar 22 10:35 libcurl_ext.so

🐍 Testing Python wrapper...
✓ Python module loaded successfully

============================================
  Ready!
  Run 'python3 curl.py <URL>' to start
============================================
```

---

### 1.7 Workflow การ Debug และแก้ไขของ AI

#### ชั้นที่ 1: Compilation Errors

สมมติว่าโค้ด C แรกของ AI มี syntax error:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

Output:

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

การตอบสนองของ AI: **แก้ไขทันที** ปัญหาที่พบบ่อย:
- ลืม `#include <stdlib.h>` (`size_t`, `malloc`, `free`)
- ลืม `#include <string.h>` (`memcpy`)
- ปัญหา path ของ libcurl header

การแก้ไขง่าย:

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
// ... full content ...
EOF
```

#### ชั้นที่ 2: Runtime Errors

ถ้าโปรแกรมคอมไพล์ได้แต่รันไม่ได้:

```bash
./curl_test https://example.com
# Output: Request failed: Couldn't resolve host name
```

AI ตรวจสอบ:
1. เครือข่ายทำงานไหม: `ping -c 1 8.8.8.8`
2. DNS ใช้ได้ไหม: `nslookup example.com`
3. firewall บล็อกไหม

#### ชั้นที่ 3: Logic Errors

Logic errors แก้ยากที่สุด วิธีของ AI คือ **ตรวจสอบทีละขั้น**:

```bash
bash -x ./scripts/build.sh
```

Outputs แต่ละคำสั่งที่รันและค่าตัวแปร

#### ชั้นที่ 4: Memory Issues

ถ้าโปรแกรม C มี memory leaks, AI แนะนำใช้ `valgrind`:

```bash
valgrind --leak-check=full ./curl_test https://example.com
```

---

### 1.8 โครงสร้างโปรเจกต์ที่สมบูรณ์

```
curl-project/
├── src/
│   ├── curl.c           # C implementation
│   └── __init__.py     # Python wrapper
├── include/            # C headers (reserved)
├── tests/              # Test files (reserved)
├── scripts/
│   ├── setup.sh        # Initialize directories
│   ├── build.sh        # Build script
│   └── dev.sh          # Development environment
├── libcurl_ext.so      # Build output
└── curl.py             # Command-line tool
```

---

### 1.9 สรุปประเด็นสำคัญของ Shell จากโปรเจกต์นี้

1. **`mkdir -p`**: สร้างไดเรกทอรีอย่างปลอดภัย, รองรับโครงสร้างซ้อน
2. **`cat > file << 'EOF'`**: เขียนไฟล์โดยไม่ต้องใช้ editor
3. **`chmod +x`**: ให้สิทธิ์ execute
4. **`set -e`**: หยุดสคริปต์เมื่อคำสั่งใดล้มเหลว
5. **`&&` และ `||`**: รวมคำสั่งแบบมีเงื่อนไข
6. **`gcc ...`**: workflow คอมไพล์ C มาตรฐาน
7. **`bash -x`**: debug สคริปต์ทีละขั้น

---

### 1.10 สรุปบท

เมื่อ AI เขียนโค้ด, มัน **ไม่เคยออกจาก Terminal**

ตั้งแต่สร้างโครงสร้างโฟลเดอร์, เขียนโค้ด, คอมไพล์, รัน, จนถึง debug - ทำทั้งหมดบนหน้าจอสีดำตัวหนังสือขาว ไม่มี VS Code suggestions, ไม่มีการคลิกเมาส์, ไม่มี editor แบบ WYSIWYG

นี่ไม่ใช่ข้อจำกัด, นี่คือ **ประสิทธิภาพ**

หลังอ่านบทนี้, คุณควรเข้าใจ:
- AI ใช้คำสั่งเดี่ยวทำงานอย่างไร
- heredoc ทำให้ Shell เป็น "text generator" อย่างไร
- ทำไม workflow ของ AI จึงเร็วและทำซ้ำได้

ในบทถัดไป, เราจะเจาะลึกทุกแง่มุม, ตั้งแต่คำสั่งไปจนถึงสคริปต์, ตั้งแต่ debug ไปจนถึง optimization