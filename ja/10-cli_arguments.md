# 10. 引数解析と CLI ツール

---

## 10.1 コマンドライン引数の基本

```bash
#!/bin/bash

echo "スクリプト: $0"
echo "最初の引数: $1"
echo "2番目の引数: $2"
echo "3番目の引数: ${3:-デフォルト}"  # デフォルト値
echo "引数の数: $#"
echo "すべての引数: $@"
```

### 実行例

```bash
./script.sh foo bar
# 出力:
# スクリプト: ./script.sh
# 最初の引数: foo
# 2番目の引数: bar
# 3番目の引数: デフォルト
# 引数の数: 2
# すべての引数: foo bar
```

---

## 10.2 シンプルな引数解析

### 位置パラメータ

```bash
#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "使用方法: $0 <ファイル>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "エラー: ファイルが存在しません"
    exit 1
fi

echo "$FILE を処理中..."
```

### オプション引数の処理

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "不明なオプション: $1"
            exit 1
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

$VERBOSE && echo "詳細モードがオンです"
[[ -n "$OUTPUT" ]] && echo "出力先: $OUTPUT"
```

---

## 10.3 `getopts`: 標準的なオプション解析

```bash
#!/bin/bash

while getopts "hv:o:" opt; do
    case $opt in
        h)
            echo "ヘルプ情報"
            exit 0
            ;;
        v)
            echo "詳細モード: $OPTARG"
            ;;
        o)
            echo "出力ファイル: $OPTARG"
            ;;
        \?)
            echo "無効なオプション: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "残りの引数: $@"
```

### オプション形式リファレンス

| 形式 | 意味 |
|--------|---------|
| `getopts "hv:"` | `-h` 引数なし、`-v` 引数必要 |
| `OPTARG` | 現在のオプションの引数値 |
| `OPTIND` | 次の引数のインデックス |

---

## 10.4 対話式入力

### `read`: ユーザー入力を読み取り

```bash
#!/bin/bash

# 基本的な読み取り
read -p "名前を入力してください: " name
echo "こんにちは、$name"

# パスワード（非表示）
read -sp "パスワードを入力してください: " password
echo

# 複数の値を入力
read -p "名前と年齢を入力: " name age
echo "$name は $age 歳です"

# タイムアウト
read -t 5 -p "5秒以内に入力: " value
```

### 確認プロンプト

```bash
confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

if confirm "このファイルを削除しますか?"; then
    echo "削除中..."
fi
```

---

## 10.5 メニューインターフェース

```bash
#!/bin/bash

PS3="操作を選択してください: "

select choice in "プロジェクト作成" "プロジェクト削除" "終了"; do
    case $choice in
        "プロジェクト作成")
            echo "作成中..."
            ;;
        "プロジェクト削除")
            echo "削除中..."
            ;;
        "終了")
            echo "さようなら！"
            exit 0
            ;;
        *)
            echo "無効な選択"
            ;;
    esac
done
```

---

## 10.6 クイックリファレンス

| 構文 | 説明 |
|--------|-------------|
| `$0` | スクリプト名 |
| `$1`, `$2`... | 位置パラメータ |
| `$#` | 引数の数 |
| `${var:-default}` | デフォルト値 |
| `getopts "hv:" opt` | オプションを解析 |
| `$OPTARG` | 現在のオプションの引数 |
| `read -p "プロンプト:" var` | 入力を読み取り |
| `read -s var` | 非表示入力（パスワード） |
| `read -t 5 var` | 5秒のタイムアウト |
| `select` | メニューインターフェース |

---

## 10.7 演習問題

1. `-n` でカウント、`-v` で詳細モードを受け付ける CLI ツールを書く
2. `getopts` を使用して `-h`（ヘルプ）、`-o`（出力ファイル）オプションを解析する
3. y 入力でのみ進む確認関数を書く
4. `select` を使用してシンプルな電卓メニューを作成する
