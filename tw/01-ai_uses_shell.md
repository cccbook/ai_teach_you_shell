# 1. AI 怎麼使用 Shell

## 從零開始的專案實戰

---

### 1.1 專案背景：一個 Python + C 的混合專案

想象你是一個 AI，你被要求寫一個效能優異的 HTTP 客戶端程式。

你的策略很明確：用 **Python** 寫上層邏輯（好維護、易擴展），用 **C** 寫效能關鍵的網路傳輸層（快速、低記憶體）。最後讓 Python 透過 `ctypes` 呼叫 C 程式。

這個專案需要：
- 一個 C 檔案（`curl.c`）：實作高效能的 HTTP GET
- 一個 Python 檔案（`curl.py`）：包裝成好用的 API
- 一個 build script：自動化編譯流程
- 測試檔案：驗證功能正常

在 AI 的世界裡，這一切都是從一行 `mkdir` 開始的。

---

### 1.2 用 Shell 建立目錄結構

當 AI 開始一個新專案，第一件事不是寫程式碼，而是建立**整齊的目錄結構**。

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

AI 為什麼用 `mkdir -p`？因為 `-p` 參數很安全：
- 如果目錄已存在，不會報錯
- 可以一次建立多層嵌套目錄

人類工程師常犯的錯是分開執行 `mkdir project` 和 `mkdir project/src`，然後在 `src` 不存在的時候愣住了。AI 的習慣是**一次到位**。

現在讓 AI 把這些指令寫成一個 `setup.sh` 腳本，方便日後重建：

```bash
cat > setup.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_NAME="curl-project"

mkdir -p "$PROJECT_NAME/src"
mkdir -p "$PROJECT_NAME/include"
mkdir -p "$PROJECT_NAME/tests"
mkdir -p "$PROJECT_NAME/scripts"

echo "✓ 專案目錄結構已建立：$PROJECT_NAME/"
ls -la "$PROJECT_NAME"
EOF

chmod +x setup.sh
./setup.sh
```

你注意到了嗎？AI 在這裡用了 `cat > file << 'EOF'` 語法——這就是 **heredoc**，也是 AI 不用編輯器寫程式碼的核心技法。這個我們會在第四章深入探討。

執行結果：

```
✓ 專案目錄結構已建立：curl-project/
total 8
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 curl-project/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/include/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/scripts/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:22 curl-project/src/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/tests/
```

---

### 1.3 用 heredoc 寫 C 程式碼

現在 AI 要寫核心的 C 程式碼。對人類來說，打開 Vim 或 VS Code 是理所當然的。但 AI 的做法是：

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
        fprintf(stderr, "記憶體分配失敗\n");
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
        fprintf(stderr, "CURL 初始化失敗\n");
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
        fprintf(stderr, "請求失敗: %s\n", curl_easy_strerror(res));
        curl_easy_cleanup(curl);
        free(chunk.data);
        return 1;
    }
    
    long response_code;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
    printf("HTTP 狀態碼: %ld\n", response_code);
    
    *response = chunk.data;
    *len = chunk.size;
    
    curl_easy_cleanup(curl);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "用法: %s <URL>\n", argv[0]);
        return 1;
    }
    
    char *result = NULL;
    size_t len = 0;
    
    int status = fetch_url(argv[1], &result, &len);
    
    if (status == 0 && result) {
        printf("回應內容 (%zu bytes):\n%s\n", len, result);
        free(result);
    }
    
    return status;
}
EOF
```

**這段程式碼做了什麼？**

1. 使用 libcurl 實作 HTTP GET 請求
2. 動態分配記憶體來儲存回應內容
3. 實作回調函數來處理資料流
4. 提供 `fetch_url()` 函數供外部呼叫
5. `main()` 函數作為命令列工具使用

---

### 1.4 用 heredoc 寫 Python 包裝層

現在 AI 要寫 Python 檔案，讓它呼叫 C 程式：

```bash
cat > src/__init__.py << 'EOF'
"""
curl-py: Python + C 混合的 HTTP 客戶端
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
            raise CurlError(f"找不到函式庫: {lib_path}")
        
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
            raise CurlError(f"請求失敗，錯誤碼: {result}")
        
        return response.value.decode('utf-8')
EOF
```

然後再寫一個方便使用的介面：

```bash
cat > curl.py << 'EOF'
#!/usr/bin/env python3
"""
curl.py - 命令列 HTTP 客戶端
用法: python curl.py <URL>
"""

from src import CurlFetcher, CurlError
import sys

def main():
    if len(sys.argv) != 2:
        print(f"用法: {sys.argv[0]} <URL>", file=sys.stderr)
        sys.exit(1)
    
    url = sys.argv[1]
    
    try:
        fetcher = CurlFetcher()
        print(f"正在請求: {url}")
        content = fetcher.get(url)
        print(content)
    except CurlError as e:
        print(f"錯誤: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n已取消", file=sys.stderr)
        sys.exit(130)

if __name__ == "__main__":
    main()
EOF
```

---

### 1.5 用 gcc 編譯 C 程式

編譯是 AI 工作流中最「可見」的步驟之一。AI 會這樣做：

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**AI 為什麼這樣寫？**

- `-shared -fPIC`：建立 position-independent code，產生共享函式庫
- `-O2`：二級優化，提升執行效率
- `-lcurl`：連結 libcurl 函式庫
- `-Wall -Wextra`：開啟所有警告，避免隱藏問題

讓 AI 把這條指令封裝成編譯腳本：

```bash
cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e

LIB_NAME="libcurl_ext.so"
SRC_FILE="src/curl.c"

echo "🔨 開始編譯 $SRC_FILE ..."

if ! command -v gcc &> /dev/null; then
    echo "錯誤: 未找到 gcc，請先安裝 Xcode Command Line Tools"
    echo "執行: xcode-select --install"
    exit 1
fi

gcc -shared -fPIC -O2 \
    -o "$LIB_NAME" \
    "$SRC_FILE" \
    -lcurl \
    -Wall \
    -Wextra

if [ $? -eq 0 ]; then
    echo "✓ 編譯成功: $LIB_NAME"
    ls -lh "$LIB_NAME"
else
    echo "✗ 編譯失敗"
    exit 1
fi
EOF

chmod +x scripts/build.sh
./scripts/build.sh
```

---

### 1.6 用 Shell Script 自動化整個流程

這是 AI 的精髓：**把重複的工作自動化**。

```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "============================================"
echo "  curl-project 開發環境"
echo "============================================"

echo ""
echo "🧹 清理舊檔案..."
rm -f libcurl_ext.so
rm -rf __pycache__ src/__pycache__

echo ""
echo "🔨 編譯 C 程式碼..."
./scripts/build.sh

if [ -f "libcurl_ext.so" ]; then
    echo ""
    echo "🧪 測試 C 程式..."
    gcc -o curl_test src/curl.c -lcurl 2>/dev/null && {
        ./curl_test https://httpbin.org/get || true
        rm -f curl_test
    } || echo "（跳過 C 測試，缺少 libcurl-dev）"
fi

echo ""
echo "🐍 測試 Python 包裝..."
if [ -f "src/__init__.py" ]; then
    python3 -c "from src import CurlFetcher; print('✓ Python 模組載入成功')" 2>/dev/null || {
        echo "⚠ Python 模組測試需要先完成 C 編譯"
    }
fi

echo ""
echo "============================================"
echo "  準備完成！"
echo "  執行 'python3 curl.py <URL>' 開始使用"
echo "============================================"
EOF

chmod +x scripts/dev.sh
```

執行一次看看：

```bash
./scripts/dev.sh
```

```
============================================
  curl-project 開發環境
============================================

🧹 清理舊檔案...

🔨 編譯 C 程式碼...
✓ 編譯成功: libcurl_ext.so
-rwxr-xr-x  1 ai  staff  45032 Mar 22 10:35 libcurl_ext.so

🐍 測試 Python 包裝...
✓ Python 模組載入成功

============================================
  準備完成！
  執行 'python3 curl.py <URL>' 開始使用
============================================
```

---

### 1.7 AI 的除錯與修補工作流

#### 第一層：編譯錯誤

假設 AI 第一次寫的 C 程式有語法錯誤：

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

輸出：

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

AI 的反應是：**立即修復**。常見的問題：
- 忘記 `#include <stdlib.h>`（`size_t`, `malloc`, `free`）
- 忘記 `#include <string.h>`（`memcpy`）
- libcurl 標頭檔路徑問題

修復很簡單：

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
// ... 完整內容 ...
EOF
```

#### 第二層：執行期錯誤

如果程式可以編譯，但執行時失敗：

```bash
./curl_test https://example.com
# 輸出：請求失敗: Couldn't resolve host name
```

AI 會檢查：
1. 網路是否正常：`ping -c 1 8.8.8.8`
2. DNS 是否可用：`nslookup example.com`
3. 防火牆是否阻擋

#### 第三層：邏輯錯誤

最難的除錯是邏輯錯誤。AI 的方法是**逐步驗證**：

```bash
bash -x ./scripts/build.sh
```

輸出每一行執行的命令和變數值

#### 第四層：記憶體問題

如果 C 程式有記憶體洩漏，AI 會建議使用 `valgrind`：

```bash
valgrind --leak-check=full ./curl_test https://example.com
```

---

### 1.8 完整的專案到此時的結構

```
curl-project/
├── src/
│   ├── curl.c           # C 實作
│   └── __init__.py     # Python 包裝
├── include/            # C 標頭檔（預留）
├── tests/              # 測試檔案（預留）
├── scripts/
│   ├── setup.sh        # 初始化目錄
│   ├── build.sh        # 編譯腳本
│   └── dev.sh          # 開發環境
├── libcurl_ext.so      # 編譯產出
└── curl.py             # 命令列工具
```

---

### 1.9 從這個實戰中學到的 Shell 重點

1. **`mkdir -p`**：安全建立目錄，支援巢狀結構
2. **`cat > file << 'EOF'`**：不用編輯器寫檔案
3. **`chmod +x`**：給予執行權限
4. **`set -e`**：任何命令失敗就停止腳本
5. **`&&` 和 `||`**：組合條件命令
6. **`gcc ...`**：編譯 C 程式的標準流程
7. **`bash -x`**：逐步除錯腳本

---

### 1.10 本章結語

AI 寫程式時，**從不離開 Terminal**。

從建立資料夾結構、寫程式碼、編譯、執行、到除錯，全部在一個黑底白字的環境中完成。沒有 VS Code 的提示框，沒有滑鼠點擊，沒有所見即所得的編輯器。

這不是限制，這是**效率**。

當你看完這一章，你應該理解：
- AI 如何用一行指令完成一件事
- heredoc 如何讓 Shell 成為「文字產生器」
- 為什麼 AI 的工作流如此快速且可重複

在接下來的章節，我們會深入每一個環節，從命令到腳本，從除錯到優化。
