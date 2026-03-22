# 4. テキスト生成と書き込み

---

## 4.1 なぜ AI はエディタを必要としないのか

ほとんどの人間のエンジニアのコードを書くワークフロー：
1. エディタを開く（VS Code、Vim、Emacs...）
2. コードを入力する
3. ファイルを保存する
4. エディタを閉じる

AI にとって：
```
「Python プログラムを書く」= テキストを生成する
「このプログラムをファイルに保存」= テキストをディスクに書き込む
```

AI のコード生成プロセスは **テキスト生成プロセス** です。だから AI は Shell のテキストツールを使います：

- `echo`：単一行テキストを出力
- `printf`：フォーマットされた出力
- `heredoc`：複数行テキストを出力（最も重要！）

---

## 4.2 `echo`：最もシンプルな出力

### 基本的な使用方法

```bash
# 文字列を出力
echo "Hello, World!"

# 変数を出力
name="Alice"
echo "Hello, $name!"

# 複数の値を出力
echo "今日は $(date +%Y-%m-%d)"
```

### `echo` の罠

```bash
# echo はデフォルトで改行を追加
echo -n "読み込み中: "  # 改行なし
```

### `echo` でファイルを書き込む

```bash
# 上書き
echo "Hello, World!" > file.txt

# 追加
echo "2行目" >> file.txt
```

**注意**：複数行ファイルに `echo` を使うのは痛苦なので、AI はコードには 거의 使いません。`heredoc` がスターです。

---

## 4.3 `printf`：より強力なフォーマット出力

### `echo` との比較

```bash
# printf は C スタイルのフォーマットをサポート
printf "値: %.2f\n" 3.14159
# 出力: 値: 3.14

printf "%s\t%s\n" "名前" "年齢"
```

### テーブルを作成

```bash
printf "%-15s %10s\n" "名前" "価格"
printf "%-15s %10.2f\n" "iPhone" 999.99
printf "%-15s %10.2f\n" "MacBook" 1999.99
```

---

## 4.4 heredoc：AI がコードを書くための核心兵器

### heredoc とは？

heredoc は **複数行テキストをそのまま出力** するための特別な Shell 構文です。

```bash
cat << 'EOF'
この内容はすべて
そのまま出力されます
改行、スペースも含む
EOF
```

### ファイルを書く（AI の最も一般的な使用法）

```bash
cat > program.py << 'EOF'
#!/usr/bin/env python3

def hello(name):
    print(f"Hello, {name}!")

if __name__ == "__main__":
    hello("World")
EOF
```

### なぜ `'EOF'`（一重引用符）を使うのか？

```bash
# 一重引用符 EOF：何も展開しない
cat << 'EOF'
HOME は: $HOME
今日は: $(date)
EOF
# 出力: HOME は: $HOME（展開されない）

# 二重引用符 EOF または引用符なし：展開される
cat << EOF
HOME は: $HOME
EOF
# 出力: HOME は: /home/ai（展開される）
```

**AI の選択**：ほとんど常に `'EOF'`（一重引用符）を使います。コードは通常 Shell 変数の展開を必要としないからです。

---

## 4.5 AI が heredoc で様々なファイルを書く

### Python プログラムを書く

```bash
cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""メインエントリーポイント"""

import sys
import os

def main():
    print("Python + C ハイブリッドプロジェクト")
    print(f"作業ディレクトリ: {os.getcwd()}")

if __name__ == "__main__":
    main()
EOF
```

### Shell スクリプトを書く

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

DEPLOY_HOST="server.example.com"

echo "🚀 $DEPLOY_HOST にデプロイ中"
rsync -avz --delete ./dist/ "$DEPLOY_HOST:/var/www/app/"
ssh "$DEPLOY_HOST" "systemctl restart myapp"
echo "✅ デプロイ完了！"
EOF

chmod +x scripts/deploy.sh
```

### 設定ファイルを書く

```bash
cat > config.json << 'EOF'
{
    "site_name": "私のブログ",
    "author": "匿名",
    "theme": "minimal"
}
EOF
```

### Dockerfile を書く

```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "http.server", "8000"]
EOF
```

---

## 4.6 heredoc の罠と解決策

### 罠1：一重引用符を含む

```bash
# 問題：一重引用符 EOF は一重引用符を許さない
cat << 'EOF'
He's going.
EOF
# 出力: 構文エラー

# 解決策：二重引用符 EOF を使う
cat << "EOF"
He's going.
EOF
```

### 罠2：`$` を含むが展開したくない

```bash
# 問題：二重引用符 EOF は $ を展開する
cat << "EOF"
Price is $100
EOF
# 出力: Price is (空)

# 解決策：個別にエスケープ
cat << "EOF"
Price is $$100
EOF
# 出力: Price is $100
```

---

## 4.7 実践：ゼロから完全なプロジェクトを構築

```bash
# 1. ディレクトリ構造を作成
mkdir -p myblog/{src,themes,content}

# 2. 設定ファイルを作成
cat > myblog/config.json << 'EOF'
{
    "site_name": "私のブログ",
    "author": "匿名",
    "theme": "minimal"
}
EOF

# 3. Python メインブログラムを作成
cat > myblog/src/blog.py << 'EOF'
#!/usr/bin/env python3
"""シンプルなブログジェネレーター"""
import json
from pathlib import Path

def load_config():
    config_path = Path(__file__).parent.parent / "config.json"
    with open(config_path) as f:
        return json.load(f)

if __name__ == "__main__":
    config = load_config()
    print(f"生成中: {config['site_name']}")
EOF

# 4. ビルドスクリプトを作成
cat > myblog/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🔨 ブログをビルド中..."
cd "$(dirname "$0")"
python3 src/blog.py
echo "✅ ビルド完了！"
EOF

chmod +x myblog/build.sh

# 5. 構造を確認
find myblog -type f | sort
```

---

## 4.8 クイックリファレンス

| ツール | 目的 | 例 |
|------|---------|---------|
| `echo` | 単一行を出力 | `echo "Hello"` |
| `echo -n` | 改行なし | `echo -n "読み込み中..."` |
| `printf` | フォーマット出力 | `printf "%s: %d\n" "年齢" 25` |
| `>` | ファイルに上書き | `echo "hi" > file.txt` |
| `>>` | ファイルに追加 | `echo "hi" >> file.txt` |
| `<< 'EOF'` | heredoc（展開なし） | コードにはこれが良い |
| `<< "EOF"` | heredoc（展開あり） | めったに使わない |

---

## 4.9 演習

1. `echo -n` と `for` ループで Loading アニメーションを作成する
2. `printf` でフォーマットされたテーブル（名前、年齢、職業）を作成する
3. heredoc で20行の Python プログラムを書く
4. heredoc で docker-compose.yml を書く
