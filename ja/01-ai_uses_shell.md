# 1. AI はどのように Shell を使うか

---

## プロジェクト背景：Python + C ハイブリッドプロジェクト

AI にハイパフォーマンスな HTTP クライアントを書くタスクを想像してください。

戦略は明確です：上部レイヤーのロジックには **Python** を使い（保守性、拡張性）、パフォーマンスが重要なネットワークレイヤーには **C** を使います（高速、低メモリ）。然后 Python は `ctypes` を通じて C を呼び出します。

このプロジェクトに必要なもの：
- C ファイル（`curl.c`）：ハイパフォーマンス HTTP GET を実装
- Python ファイル（`curl.py`）：使いやすい API にラップ
- ビルドスクリプト：コンパイルプロセスを自動化
- テストファイル：機能を検証

AI の世界では、すべては単一の `mkdir` コマンドから始まります。

---

### 1.2 Shell でディレクトリ構造を作成

AI が新しいプロジェクトを始めるとき、最初のことはコードを書くことではなく、**クリーンなディレクトリ構造**を確立することです。

```bash
mkdir -p curl-project/src
mkdir -p curl-project/include
mkdir -p curl-project/tests
mkdir -p curl-project/scripts
```

なぜ AI は `mkdir -p` を使うのですか？ `-p` は安全だからです：
- ディレクトリが既に存在する場合、エラーにならない
- ネストされたディレクトリを一度に作成できる

人間のエンジニアはよく `mkdir project` と `mkdir project/src` を別々に実行し、`src` が存在しない状況で混乱するという間違いを犯します。AI の習慣は **最初から正しくやる** ことです。

次に AI はこれらのコマンドを `setup.sh` スクリプトに書き込み、将来の再作成に備えます：

```bash
cat > setup.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_NAME="curl-project"

mkdir -p "$PROJECT_NAME/src"
mkdir -p "$PROJECT_NAME/include"
mkdir -p "$PROJECT_NAME/tests"
mkdir -p "$PROJECT_NAME/scripts"

echo "✓ プロジェクト構造を作成しました: $PROJECT_NAME/"
ls -la "$PROJECT_NAME"
EOF

chmod +x setup.sh
./setup.sh
```

気づきましたか？AI はここで `cat > file << 'EOF'` 構文を使っています—これは **heredoc** で、AI がエディタなしでコードを書くための核心的な技術です。第4章で詳しく説明します。

出力：

```
✓ プロジェクト構造を作成しました: curl-project/
total 8
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 curl-project/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/include/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/scripts/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:22 curl-project/src/
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 curl-project/tests/
```

---

### 1.3 heredoc で C コードを書く

次に AI はコアな C コードを書きます。人間にとっては、Vim や VS Code を開くのは自然なことです。しかし AI のアプローチは：

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

**このコードは何をしますか？**

1. libcurl を使用して HTTP GET リクエストを実装
2. レスポンス内容を保存するためにメモリを動的に割り当て
3. データストリームを処理するコールバック関数を実装
4. 外部呼び出し用の `fetch_url()` 関数を提供
5. `main()` 関数はコマンドラインツールとして機能

---

### 1.4 heredoc で Python ラッパーを書く

次に AI は C を呼び出す Python ファイルを書きます：

```bash
cat > src/__init__.py << 'EOF'
"""
curl-py: Python + C ハイブリッド HTTP クライアント
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
            raise CurlError(f"ライブラリが見つかりません: {lib_path}")
        
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
            raise CurlError(f"リクエスト失敗、エラーコード: {result}")
        
        return response.value.decode('utf-8')
EOF
```

次に使いやすいインターフェースを書きます：

```bash
cat > curl.py << 'EOF'
#!/usr/bin/env python3
"""
curl.py - コマンドライン HTTP クライアント
使用方法: python curl.py <URL>
"""

from src import CurlFetcher, CurlError
import sys

def main():
    if len(sys.argv) != 2:
        print(f"使用方法: {sys.argv[0]} <URL>", file=sys.stderr)
        sys.exit(1)
    
    url = sys.argv[1]
    
    try:
        fetcher = CurlFetcher()
        print(f"リクエスト中: {url}")
        content = fetcher.get(url)
        print(content)
    except CurlError as e:
        print(f"エラー: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nキャンセルされました", file=sys.stderr)
        sys.exit(130)

if __name__ == "__main__":
    main()
EOF
```

---

### 1.5 gcc で C コードをコンパイル

コンパイルは AI のワークフローの中で最も「見える」ステップの一つです。AI は次のようにやります：

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl -Wall -Wextra
```

**なぜ AI はこの書き方をするのですか？**

- `-shared -fPIC`：位置独立コードを作成し、共有ライブラリを生成
- `-O2`：レベル2最適化、実行効率を向上
- `-lcurl`：libcurl ライブラリをリンク
- `-Wall -Wextra`：すべての警告を有効化、隠れた問題を回避

AI はこれをビルドスクリプトにラップします：

```bash
cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e

LIB_NAME="libcurl_ext.so"
SRC_FILE="src/curl.c"

echo "🔨 $SRC_FILE をコンパイル中..."

if ! command -v gcc &> /dev/null; then
    echo "エラー: gcc が見つかりません、Xcode Command Line Tools をインストールしてください"
    echo "実行: xcode-select --install"
    exit 1
fi

gcc -shared -fPIC -O2 \
    -o "$LIB_NAME" \
    "$SRC_FILE" \
    -lcurl \
    -Wall \
    -Wextra

if [ $? -eq 0 ]; then
    echo "✓ ビルド成功: $LIB_NAME"
    ls -lh "$LIB_NAME"
else
    echo "✗ ビルド失敗"
    exit 1
fi
EOF

chmod +x scripts/build.sh
./scripts/build.sh
```

---

### 1.6 Shell スクリプトで全体的なプロセスを自動化

これが AI の本質です：**反復的な作業を自動化する**。

```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "============================================"
echo "  curl-project 開発環境"
echo "============================================"

echo ""
echo "🧹 古いファイルをクリーン中..."
rm -f libcurl_ext.so
rm -rf __pycache__ src/__pycache__

echo ""
echo "🔨 C コードをコンパイル中..."
./scripts/build.sh

if [ -f "libcurl_ext.so" ]; then
    echo ""
    echo "🧪 C プログラムをテスト中..."
    gcc -o curl_test src/curl.c -lcurl 2>/dev/null && {
        ./curl_test https://httpbin.org/get || true
        rm -f curl_test
    } || echo "(libcurl-dev がないため C テストをスキップ)"
fi

echo ""
echo "🐍 Python ラッパーをテスト中..."
if [ -f "src/__init__.py" ]; then
    python3 -c "from src import CurlFetcher; print('✓ Python モジュールを正常にロードしました')" 2>/dev/null || {
        echo "⚠ Python モジュールのテストにはまず C のコンパイルが必要です"
    }
fi

echo ""
echo "============================================"
echo "  準備完了！"
echo "  'python3 curl.py <URL>' を実行して開始"
echo "============================================"
EOF

chmod +x scripts/dev.sh
```

実行：

```bash
./scripts/dev.sh
```

```
============================================
  curl-project 開発環境
============================================

🧹 古いファイルをクリーン中...

🔨 C コードをコンパイル中...
✓ ビルド成功: libcurl_ext.so
-rwxr-xr-x  1 ai  staff  45032 Mar 22 10:35 libcurl_ext.so

🐍 Python ラッパーをテスト中...
✓ Python モジュールを正常にロードしました

============================================
  準備完了！
  'python3 curl.py <URL>' を実行して開始
============================================
```

---

### 1.7 AI のデバッグと修正のワークフロー

#### レイヤー1：コンパイルエラー

AI の最初の C コードに構文エラーがあるとします：

```bash
gcc -shared -fPIC -o libcurl_ext.so src/curl.c -lcurl
```

出力：

```
src/curl.c:15:10: error: unknown type name 'size_t'
```

AI の対応：**即座に修正**。一般的な問題：
- `#include <stdlib.h>` を忘れた（`size_t`、`malloc`、`free`）
- `#include <string.h>` を忘れた（`memcpy`）
- libcurl ヘッダーパスの問題

修正は簡単です：

```bash
cat > src/curl.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
// ... 完全な内容 ...
EOF
```

#### レイヤー2：ランタイムエラー

プログラムはコンパイルするが実行に失敗する場合：

```bash
./curl_test https://example.com
# 出力: Request failed: Couldn't resolve host name
```

AI が確認すること：
1. ネットワークは動作しているか：`ping -c 1 8.8.8.8`
2. DNS は利用可能か：`nslookup example.com`
3. ファイアウォールがブロックしていないか

#### レイヤー3：ロジックエラー

ロジックエラーはデバッグが最も困難です。AI の方法は **ステップバイステップの検証**です：

```bash
bash -x ./scripts/build.sh
```

各実行されたコマンドと変数の値を出力します

#### レイヤー4：メモリ問題

C プログラムにメモリリークがある場合、AI は `valgrind` の使用を提案します：

```bash
valgrind --leak-check=full ./curl_test https://example.com
```

---

### 1.8 完全なプロジェクト構造

```
curl-project/
├── src/
│   ├── curl.c           # C 実装
│   └── __init__.py     # Python ラッパー
├── include/            # C ヘッダー（予約）
├── tests/              # テストファイル（予約）
├── scripts/
│   ├── setup.sh        # ディレクトリ初期化
│   ├── build.sh        # ビルドスクリプト
│   └── dev.sh          # 開発環境
├── libcurl_ext.so      # ビルド出力
└── curl.py             # コマンドラインツール
```

---

### 1.9 このプロジェクトからの Shell 重要ポイント

1. **`mkdir -p`**：安全にディレクトリを作成、ネスト構造をサポート
2. **`cat > file << 'EOF'`**：エディタなしでファイルを書く
3. **`chmod +x`**：実行権限を与える
4. **`set -e`**：任意のコマンド失敗でスクリプトを停止
5. **`&&` と `||`**：条件付きコマンドを組み合わせる
6. **`gcc ...`**：標準的な C コンパイルワークフロー
7. **`bash -x`**：スクリプトをステップバイステップでデバッグ

---

### 1.10 章のまとめ

AI がコードを書くとき、**決して Terminal を離れません**。

フォルダ構造の作成、コードの記述、コンパイル、実行、デバッグまで—すべて白黒の画面上で行われます。VS Code の提案もなく、マウスのクリックもなく、WYSIWYG エディタもなく。

これは制限ではなく、**効率**です。

この章を読んだ後、以下のことが理解できているはずです：
- AI が単一のコマンドでタスクを完了させる方法
- heredoc が Shell を「テキストジェネレーター」にする方法
- なぜ AI のワークフローがこれほど高速で再現可能か

次の章では、コマンドからスクリプトへ、デバッグから最適化まで、あらゆる側面を深く掘り下げます。
