# 1. AI 怎么使用 Shell

## 从零开始的项目实战

---

### 1.1 项目背景：一个 Python + C 的混合项目

想象你是一个 AI，你被要求写一个性能优异的 HTTP 客户端程序。

你的策略很明确：用 **Python** 写上层逻辑（好维护、易扩展），用 **C** 写性能关键的网络传输层（快速、低内存）。最后让 Python 通过 `ctypes` 调用 C 程序。

这个项目需要：
- 一个 C 文件（`curl.c`）：实现高性能的 HTTP GET
- 一个 Python 文件（`curl.py`）：包装成好用的 API
- 一个 build script：自动化编译流程
- 测试文件：验证功能正常

在 AI 的世界里，这一切都是从一行 `mkdir` 开始的。

---

### 1.2 用 Shell 建立目录结构

当 AI 开始一个新项目，第一件事不是写代码，而是建立**整齐的目录结构**。

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

AI 为什么用 `mkdir -p`？因为 `-p` 参数很安全：
- 如果目录已存在，不会报错
- 可以一次建立多层嵌套目录

人类工程师常犯的错是分开执行 `mkdir project` 和 `mkdir project/src`，然后在 `src` 不存在的时候愣住了。AI 的习惯是**一次到位**。

现在让 AI 把这些指令写成 `setup.sh` 脚本，方便日后重建：

```bash
cat > setup.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_NAME="curl-project"

mkdir -p "$PROJECT_NAME/src"
mkdir -p "$PROJECT_NAME/include"
mkdir -p "$PROJECT_NAME/tests"
mkdir -p "$PROJECT_NAME/scripts"

echo "✓ 项目目录结构已建立：$PROJECT_NAME/"
ls -la "$PROJECT_NAME"
EOF

chmod +x setup.sh
./setup.sh
```

你注意到了吗？AI 在这里用了 `cat > file << 'EOF'` 语法——这就是 **heredoc**，也是 AI 不用编辑器写代码的核心技法。

执行结果：

```
✓ 项目目录结构已建立：curl-project/
total 8
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 curl-project/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/include/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/scripts/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:22 curl-project/src/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/tests/
```

---

### 1.3 用 heredoc 写 C 程序代码

现在 AI 要写核心的 C 程序代码。对人类来说，打开 Vim 或 VS Code 是理所当然的。但 AI 的做法是：

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
        fprintf(stderr, "内存分配失败\n");
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
        fprintf(stderr, "CURL 初始化失败\n");
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
        fprintf(stderr, "请求失败: %s\n", curl_easy_strerror(res));
        curl_easy_cleanup(curl);
        free(chunk.data);
        return 1;
    }
    
    long response_code;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
    printf("HTTP 状态码: %ld\n", response_code);
    
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
        printf("响应内容 (%zu bytes):\n%s\n", len, result);
        free(result);
    }
    
    return status;
}
EOF
```

**这段代码做了什么？**

1. 使用 libcurl 实现 HTTP GET 请求
2. 动态分配内存来存储响应内容
3. 实现回调函数来处理数据流
4. 提供 `fetch_url()` 函数供外部调用
5. `main()` 函数作为命令行工具使用

---

### 1.4 用 heredoc 写 Python 包装层

现在 AI 要写 Python 文件，让它调用 C 程序：

```bash
cat > src/__init__.py << 'EOF'
"""
curl-py: Python + C 混合的 HTTP 客户端
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
            raise CurlError(f"找不到函数库: {lib_path}")
        
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
            raise CurlError(f"请求失败，错误码: {result}")
        
        return response.value.decode('utf-8')
EOF
```

然后再写一个方便使用的界面：

```bash
cat > curl.py << 'EOF'
#!/usr/bin/env python3
"""
curl.py - 命令行 HTTP 客户端
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
        print(f"正在请求: {url}")
        content = fetcher.get(url)
        print(content)
    except CurlError as e:
        print(f"错误: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n已取消", file=sys.stderr)
        sys.exit(130)

if __name__ == "__main__":
    main()
EOF
```

---

### 1.5 用 gcc 编译 C 程序

编译是 AI 工作流中最「可见」的步骤之一。AI 会这样做：

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**AI 为什么这样写？**

- `-shared -fPIC`：建立 position-independent code，产生共享函数库
- `-O2`：二级优化，提升执行效率
- `-lcurl`：链接 libcurl 函数库
- `-Wall -Wextra`：开启所有警告，避免隐藏问题

让 AI 把这条指令封装成编译脚本：

```bash
cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e

LIB_NAME="libcurl_ext.so"
SRC_FILE="src/curl.c"

echo "🔨 开始编译 $SRC_FILE ..."

if ! command -v gcc &> /dev/null; then
    echo "错误: 未找到 gcc"
    exit 1
fi

gcc -shared -fPIC -O2 \
    -o "$LIB_NAME" \
    "$SRC_FILE" \
    -lcurl \
    -Wall \
    -Wextra

if [ $? -eq 0 ]; then
    echo "✓ 编译成功: $LIB_NAME"
    ls -lh "$LIB_NAME"
else
    echo "✗ 编译失败"
    exit 1
fi
EOF

chmod +x scripts/build.sh
./scripts/build.sh
```

---

### 1.6 用 Shell Script 自动化整个流程

这是 AI 的精髓：**把重复的工作自动化**。

```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "============================================"
echo "  curl-project 开发环境"
echo "============================================"

echo ""
echo "🧹 清理旧文件..."
rm -f libcurl_ext.so
rm -rf __pycache__ src/__pycache__

echo ""
echo "🔨 编译 C 代码..."
./scripts/build.sh

if [ -f "libcurl_ext.so" ]; then
    echo ""
    echo "🧪 测试 C 程序..."
    gcc -o curl_test src/curl.c -lcurl 2>/dev/null && {
        ./curl_test https://httpbin.org/get || true
        rm -f curl_test
    } || echo "（跳过 C 测试）"
fi

echo ""
echo "🐍 测试 Python 包装..."
if [ -f "src/__init__.py" ]; then
    python3 -c "from src import CurlFetcher; print('✓ Python 模块加载成功')" 2>/dev/null || {
        echo "⚠ Python 模块测试需要先完成 C 编译"
    }
fi

echo ""
echo "============================================"
echo "  准备完成！"
echo "  执行 'python3 curl.py <URL>' 开始使用"
echo "============================================"
EOF

chmod +x scripts/dev.sh
```

执行一次看看：

```bash
./scripts/dev.sh
```

```
============================================
  curl-project 开发环境
============================================

🧹 清理旧文件...

🔨 编译 C 代码...
✓ 编译成功: libcurl_ext.so
-rwxr-xr-x  1 ai  staff  45032 Mar 22 10:35 libcurl_ext.so

🐍 测试 Python 包装...
✓ Python 模块加载成功

============================================
  准备完成！
  执行 'python3 curl.py <URL>' 开始使用
============================================
```

---

### 1.7 AI 的调试与修补工作流

#### 第一层：编译错误

假若 AI 第一次写的 C 程序有语法错误：

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

输出：

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

AI 的反应是：**立即修复**。常见的问题：
- 忘记 `#include <stdlib.h>`
- 忘记 `#include <string.h>`

#### 第二层：执行期错误

如果程序可以编译，但执行时失败：

```bash
./curl_test https://example.com
# 输出：请求失败: Couldn't resolve host name
```

AI 会检查：
1. 网络是否正常：`ping -c 1 8.8.8.8`
2. DNS 是否可用：`nslookup example.com`

#### 第三层：逻辑错误

最难的调试是逻辑错误。AI 的方法是**逐步验证**：

```bash
bash -x ./scripts/build.sh
```

---

### 1.8 完整的项目到此时的结构

```
curl-project/
├── src/
│   ├── curl.c           # C 实现
│   └── __init__.py     # Python 包装
├── include/            # C 头文件（预留）
├── tests/              # 测试文件（预留）
├── scripts/
│   ├── setup.sh        # 初始化目录
│   ├── build.sh        # 编译脚本
│   └── dev.sh          # 开发环境
├── libcurl_ext.so      # 编译产出
└── curl.py             # 命令行工具
```

---

### 1.9 从这个实战中学到的 Shell 重点

1. **`mkdir -p`**：安全建立目录，支援嵌套结构
2. **`cat > file << 'EOF'`**：不用编辑器写文件
3. **`chmod +x`**：给予执行权限
4. **`set -e`**：任何命令失败就停止脚本
5. **`&&` 和 `||`**：组合条件命令
6. **`gcc ...`**：编译 C 程序的标准流程
7. **`bash -x`**：逐步调试脚本

---

### 1.10 本章结语

AI 写程序时，**从不离开 Terminal**。

从建立文件夹结构、写代码、编译、执行、到调试，全部在一个黑底白字的环境中完成。没有 VS Code 的提示框，没有滑鼠点击，没有所见即所得的编辑器。

这不是限制，这是**效率**。
