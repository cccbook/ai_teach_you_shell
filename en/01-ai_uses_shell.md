# 1. How AI Uses Shell

## A Real Project from Scratch

---

### 1.1 Project Background: A Python + C Hybrid Project

Imagine you are an AI tasked with writing a high-performance HTTP client.

Your strategy is clear: use **Python** for the upper layer logic (maintainable, extensible), and use **C** for the performance-critical networking layer (fast, low memory). Then let Python call C via `ctypes`.

This project requires:
- A C file (`curl.c`): implements high-performance HTTP GET
- A Python file (`curl.py`): wraps it into a user-friendly API
- A build script: automates the compilation process
- Test files: verify functionality

In AI's world, everything starts with a single `mkdir` command.

---

### 1.2 Using Shell to Create Directory Structure

When AI starts a new project, the first thing is not writing code, but establishing a **clean directory structure**.

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

Why does AI use `mkdir -p`? Because `-p` is safe:
- If the directory already exists, no error
- Can create nested directories in one go

Human engineers often make the mistake of running `mkdir project` and `mkdir project/src` separately, then getting confused when `src` doesn't exist. AI's habit is to **do it right the first time**.

Now AI writes these commands into a `setup.sh` script for future recreation:

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

Did you notice? AI used `cat > file << 'EOF'` syntax here—this is **heredoc**, the core technique AI uses to write code without an editor. We'll explore this deeply in Chapter 4.

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

### 1.3 Writing C Code with heredoc

Now AI writes the core C code. For humans, opening Vim or VS Code is natural. But AI's approach is:

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

**What does this code do?**

1. Uses libcurl to implement HTTP GET requests
2. Dynamically allocates memory to store response content
3. Implements a callback function to handle data streams
4. Provides `fetch_url()` function for external calls
5. `main()` function serves as a command-line tool

---

### 1.4 Writing Python Wrapper with heredoc

Now AI writes the Python file to call C:

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

Then write a convenient interface:

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

### 1.5 Compiling C Code with gcc

Compilation is one of the most "visible" steps in AI's workflow. AI does it like this:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**Why does AI write it this way?**

- `-shared -fPIC`: creates position-independent code, generates shared library
- `-O2`: level 2 optimization, improves execution efficiency
- `-lcurl`: links libcurl library
- `-Wall -Wextra`: enables all warnings, avoids hidden issues

AI wraps this into a build script:

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

### 1.6 Automating the Entire Process with Shell Script

This is the essence of AI: **automating repetitive work**.

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

Run it:

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

### 1.7 AI's Debugging and Fixing Workflow

#### Layer 1: Compilation Errors

Suppose AI's first C code has a syntax error:

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

Output:

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

AI's response: **Fix immediately**. Common issues:
- Forgot `#include <stdlib.h>` (`size_t`, `malloc`, `free`)
- Forgot `#include <string.h>` (`memcpy`)
- libcurl header path issues

Fix is simple:

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
// ... full content ...
EOF
```

#### Layer 2: Runtime Errors

If the program compiles but fails to run:

```bash
./curl_test https://example.com
# Output: Request failed: Couldn't resolve host name
```

AI checks:
1. Is network working: `ping -c 1 8.8.8.8`
2. Is DNS available: `nslookup example.com`
3. Is firewall blocking

#### Layer 3: Logic Errors

Logic errors are the hardest to debug. AI's method is **step-by-step verification**:

```bash
bash -x ./scripts/build.sh
```

Outputs each executed command and variable values

#### Layer 4: Memory Issues

If the C program has memory leaks, AI suggests using `valgrind`:

```bash
valgrind --leak-check=full ./curl_test https://example.com
```

---

### 1.8 Complete Project Structure

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

### 1.9 Shell Key Takeaways from This Project

1. **`mkdir -p`**: safely create directories, supports nested structure
2. **`cat > file << 'EOF'`**: write files without an editor
3. **`chmod +x`**: give execute permission
4. **`set -e`**: stop script on any command failure
5. **`&&` and `||`**: combine conditional commands
6. **`gcc ...`**: standard C compilation workflow
7. **`bash -x`**: debug script step by step

---

### 1.10 Chapter Summary

When AI writes code, it **never leaves the Terminal**.

From creating folder structures, writing code, compiling, running, to debugging—all done in a black screen with white text. No VS Code suggestions, no mouse clicks, no WYSIWYG editor.

This is not a limitation, this is **efficiency**.

After reading this chapter, you should understand:
- How AI uses single commands to accomplish tasks
- How heredoc makes Shell a "text generator"
- Why AI's workflow is so fast and repeatable

In the following chapters, we'll dive deep into every aspect, from commands to scripts, from debugging to optimization.
