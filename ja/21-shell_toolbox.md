# 21. あなたの AI Shell ツールボックスを作る

---

## 21.1 なぜツールボックスが必要か

同じことを繰り返している自分に気づいたら、自動化してツールボックスにまとめる時です。

AIは特に得意的です：
- 素早くツールを作成
- 複雑なワークフローをシンプルなコマンドに包装
- よく使うスクリプトを継続的に改善

---

## 21.2 ツールボックスディレクトリ構造

```
~/bin/
├── lib/              # 共有ライブラリ
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── project/          # プロジェクトテンプレート
│   ├── python/
│   ├── nodejs/
│   └── static-site/
├── scripts/          # ツールスクリプト
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # 実行可能ツール
    └── monitor       # 実行可能ツール
```

---

## 21.3 ライブラリを作成する

### logging.sh

```bash
cat > ~/bin/lib/logging.sh << 'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }
EOF

source ~/bin/lib/logging.sh
```

### utils.sh

```bash
cat > ~/bin/lib/utils.sh << 'EOF'
#!/bin/bash

need_command() {
    command -v "$1" &>/dev/null || {
        echo "必要なコマンド: $1"
        exit 1
    }
}

need_file() {
    [[ -f "$1" ]] || {
        echo "必要なファイル: $1"
        exit 1
    }
}

need_dir() {
    [[ -d "$1" ]] || {
        echo "必要なディレクトリ: $1"
        exit 1
    }
}
EOF
```

---

## 21.4 実用ツール：git-clean

```bash
cat > ~/bin/git-clean << 'EOF'
#!/bin/bash
set -euo pipefail

DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=true; shift ;;
        *) shift ;;
    esac
done

if $DRY_RUN; then
    echo "[DRY-RUN] 削除対象："
fi

git branch --merged main | grep -v "main\|master\|develop" | while read branch; do
    if $DRY_RUN; then
        echo "  ブランチを削除: $branch"
    else
        git branch -d "$branch"
        echo "削除済み: $branch"
    fi
done

git clean -n -d
EOF

chmod +x ~/bin/git-clean
```

---

## 21.5 実用ツール：docker-clean

```bash
cat > ~/bin/docker-clean << 'EOF'
#!/bin/bash
set -euo pipefail

echo "すべてのコンテナを停止中..."
docker stop $(docker ps -aq) 2>/dev/null || true

echo "停止中のコンテナを削除中..."
docker container prune -f

echo "未使用のイメージを削除中..."
docker image prune -af

echo "未使用のネットワークを削除中..."
docker network prune -f

echo "ビルドキャッシュを削除中..."
docker builder prune -af

echo "Dockerクリーンアップ完了"
docker system df
EOF

chmod +x ~/bin/docker-clean
```

---

## 21.6 PATH にツールを追加

```bash
# ~/bin がPATHに含まれているか確認
echo $PATH | grep -q "$HOME/bin" && echo "設定済み" || echo "未設定"

# PATHに追加（~/.bashrc または ~/.zshrc に追加）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 21.7 AI にツールボックスの拡張を手伝わせる

```bash
# 人：Nginxアクセスログを分析するツールを作成して

# AI：
cat > ~/bin/nginx-analyze << 'EOF'
#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "使い方: $0 <access_log_file>"
    exit 1
fi

FILE=$1

echo "=== Nginx分析: $FILE ==="
echo ""

echo "ファイルサイズ: $(du -h "$FILE" | cut -f1)"
echo "総行数: $(wc -l < "$FILE")"
echo ""

echo "=== トップ10 IP ==="
awk '{print $1}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== トップ10 URL ==="
awk '{print $7}' "$FILE" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== ステータスコード分布 ==="
awk '{print $9}' "$FILE" | sort | uniq -c | sort -rn
EOF

chmod +x ~/bin/nginx-analyze
```

---

## 21.8 継続的改善

```bash
# 年に一度ツールボックスをレビュー
# - 使わないツールは削除
# - 改善できるツールは改良
# - 自動化できる繰り返しタスクはないか

# ツールボックスをバージョン管理
cd ~/bin
git init
git add .
git commit -m "Initial version"
```

---

## 21.9 練習問題

1. ~/bin ディレクトリ構造を作成する
2. よく使う関数を再利用可能ライブラリにまとめる
3. 毎日繰り返すタスクのためのツールを書く
4. AIにNginxログ分析ツールを作成してもらう
5. ツールボックスをGitバージョン管理下に入れる
