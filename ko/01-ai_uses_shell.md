# 1. AI는 어떻게 Shell을 사용하는가

## 처음부터 시작하는 실제 프로젝트

---

### 1.1 프로젝트 배경: Python + C 하이브리드 프로젝트

고성능 HTTP 클라이언트를 작성하는 작업을 맡은 AI를 상상해 보세요.

전략은 명확합니다: 상위 레이어 로직에는 **Python**을 사용하고(유지보수 가능, 확장 가능), 성능이 중요한 네트워킹 레이어에는 **C**를 사용합니다(빠름, 메모리 적음). 그런 다음 Python이 `ctypes`를 통해 C를 호출합니다.

이 프로젝트에 필요한 것:
- C 파일 (`curl.c`): 고성능 HTTP GET 구현
- Python 파일 (`curl.py`): 사용자 친화적인 API로 래핑
- 빌드 스크립트: 컴파일 프로세스 자동화
- 테스트 파일: 기능 검증

AI의 세계에서는 모든 것이 하나의 `mkdir` 명령으로 시작합니다.

---

### 1.2 Shell을 사용하여 디렉토리 구조 생성

AI가 새 프로젝트를 시작할 때, 첫 번째로 하는 일은 코드를 작성하는 것이 아니라 **정리된 디렉토리 구조**를 설정하는 것입니다.

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

AI가 `mkdir -p`를 사용하는 이유는? `-p`는 안전하기 때문입니다:
- 디렉토리가 이미 있으면 에러 없음
- 한 번에 중첩 디렉토리 생성 가능

인간 엔지니어들은 종종 `mkdir project`와 `mkdir project/src`를 별도로 실행하고 `src`가 없을 때 혼란스러워하는 실수를 합니다. AI의 습관은 **처음부터 올바르게 하는 것**입니다.

이제 AI가 나중에 다시 생성할 수 있도록 이 명령들을 `setup.sh` 스크립트에 작성합니다:

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

注意到了吗? AI는 여기서 `cat > file << 'EOF'` 문법을 사용했습니다—이것이 바로 **heredoc**입니다, AI가 편집기 없이 코드를 작성하는 핵심 기술입니다. 4장에서는 이것을 깊이 탐구할 것입니다.

출력:

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

### 1.3 heredoc으로 C 코드 작성

이제 AI가 핵심 C 코드를 작성합니다. 인간에게는 Vim이나 VS Code를 여는 것이 자연스럽습니다. 하지만 AI의 접근 방식은:

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

**이 코드는 무엇을 하나요?**

1. libcurl을 사용하여 HTTP GET 요청 구현
2. 응답 내용을 저장하기 위해 동적 메모리 할당
3. 데이터 스트림을 처리하는 콜백 함수 구현
4. 외부 호출을 위한 `fetch_url()` 함수 제공
5. `main()` 함수는命令行 도구로 사용

---

### 1.4 heredoc으로 Python 래퍼 작성

이제 AI가 C를 호출하는 Python 파일을 작성합니다:

```bash
cat > src/__init__.py << 'EOF'
"""
curl-py: Python + C 하이브리드 HTTP 클라이언트
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

그런 다음 편리한 인터페이스를 작성합니다:

```bash
cat > curl.py << 'EOF'
#!/usr/bin/env python3
"""
curl.py -命令行 HTTP 클라이언트
사용법: python curl.py <URL>
"""

from src import CurlFetcher, CurlError
import sys

def main():
    if len(sys.argv) != 2:
        print(f"사용법: {sys.argv[0]} <URL>", file=sys.stderr)
        sys.exit(1)
    
    url = sys.argv[1]
    
    try:
        fetcher = CurlFetcher()
        print(f"요청 중: {url}")
        content = fetcher.get(url)
        print(content)
    except CurlError as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n취소됨", file=sys.stderr)
        sys.exit(130)

if __name__ == "__main__":
    main()
EOF
```

---

### 1.5 gcc로 C 코드 컴파일

컴파일은 AI의 워크플로우에서 가장 "눈에 보이는" 단계 중 하나입니다. AI는 다음과 같이 합니다:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**AI가 이렇게 작성하는 이유는?**

- `-shared -fPIC`: 위치 독립 코드 생성, 공유 라이브러리 생성
- `-O2`: 레벨 2 최적화, 실행 효율 향상
- `-lcurl`: libcurl 라이브러리 링크
- `-Wall -Wextra`: 모든 경고 활성화, 숨겨진 문제 방지

AI는 이것을 빌드 스크립트로 감쌉니다:

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

### 1.6 Shell 스크립트로 전체 프로세스 자동화

이것이 AI의 본질입니다: **반복 작업 자동화**.

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

실행:

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

### 1.7 AI의 디버깅 및 수정 워크플로우

#### 레이어 1: 컴파일 오류

AI의 첫 번째 C 코드에 구문 오류가 있다고 가정합니다:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

출력:

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

AI의 응답: **즉시 수정**. 일반적인 문제들:
- `#include <stdlib.h>` 누락 (`size_t`, `malloc`, `free`)
- `#include <string.h>` 누락 (`memcpy`)
- libcurl 헤더 경로 문제

수정은 간단합니다:

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
// ... 전체 내용 ...
EOF
```

#### 레이어 2: 런타임 오류

프로그램이 컴파일되지만 실행에 실패하면:

```bash
./curl_test https://example.com
# 출력: Request failed: Couldn't resolve host name
```

AI가 확인하는 것:
1. 네트워크 작동 여부: `ping -c 1 8.8.8.8`
2. DNS 사용 가능 여부: `nslookup example.com`
3. 방화벽이 차단하는지 여부

#### 레이어 3: 로직 오류

로직 오류는 디버깅이 가장 어렵습니다. AI의 방법은 **단계별 검증**:

```bash
bash -x ./scripts/build.sh
```

실행된 각 명령과 변수 값을 출력합니다

#### 레이어 4: 메모리 문제

C 프로그램에 메모리 누수가 있으면, AI는 `valgrind` 사용을 제안합니다:

```bash
valgrind --leak-check=full ./curl_test https://example.com
```

---

### 1.8 완전한 프로젝트 구조

```
curl-project/
├── src/
│   ├── curl.c           # C 구현
│   └── __init__.py     # Python 래퍼
├── include/            # C 헤더 (예약됨)
├── tests/              # 테스트 파일 (예약됨)
├── scripts/
│   ├── setup.sh        # 디렉토리 초기화
│   ├── build.sh        # 빌드 스크립트
│   └── dev.sh          # 개발 환경
├── libcurl_ext.so      # 빌드 출력
└── curl.py             #命令行 도구
```

---

### 1.9 이 프로젝트에서 배우는 Shell 핵심 포인트

1. **`mkdir -p`**: 안전하게 디렉토리 생성, 중첩 구조 지원
2. **`cat > file << 'EOF'`**: 편집기 없이 파일 작성
3. **`chmod +x`**: 실행 권한 부여
4. **`set -e`**: 명령 실패 시 스크립트 중지
5. **`&&`와 `||`**: 조건 명령 조합
6. **`gcc ...`**: 표준 C 컴파일 워크플로우
7. **`bash -x`**: 단계별 스크립트 디버깅

---

### 1.10 챕터 요약

AI가 코드를 작성할 때, **절대로 Terminal을 떠나지 않습니다**.

폴더 구조 생성, 코드 작성, 컴파일, 실행, 디버깅까지—모두 검은 화면에 흰색 텍스트로 합니다. VS Code 제안 없음, 마우스 클릭 없음, WYSIWYG 편집기 없음.

이것은 제한이 아니라 **효율성**입니다.

이 챕터를 읽은 후, 다음을 이해해야 합니다:
- AI가 단일 명령으로 작업을 완료하는 방법
- heredoc이 Shell을 "텍스트 생성기"로 만드는 방법
- 왜 AI의 워크플로우가如此 빠르고 반복 가능한지

다음 챕터에서 우리는 모든 측면을 깊이 파고들 것입니다—명령에서 스크립트까지, 디버깅에서 최적화까지.
