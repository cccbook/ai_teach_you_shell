# 9. エラー処理

---

## 9.1 エラー処理が重要な理由

エラー処理がない場合:
- 1つのコマンドが失敗しても、誤った操作を続けようとする
- 間違ったファイルを削除する可能性がある
- 重要なデータを上書きする可能性がある
- システムが不整合な状態になる可能性がある

エラー処理がある場合:
- エラーが発生したら即座に停止
- 意味のあるエラーメッセージを提供
- 終了前にクリーンアップ

---

## 9.2 終了コード

すべてのコマンドは実行後に終了コードを返す:

- `0`: 成功
- `0以外`: 失敗

```bash
# 最後のコマンドの終了コードを確認
ls /tmp
echo $?  # 出力: 0（成功した場合）

ls /nonexistent
echo $?  # 出力: 2（失敗した場合）
```

---

## 9.3 `set -e`: エラーで停止

```bash
#!/bin/bash
set -e

mkdir -p backup
cp important.txt backup/  # これが失敗するとスクリプトはここで停止
rm important.txt          # ここには到達しない
```

### 使用場面

ほぼすべてのスクリプトで `set -e` を使用すべき:
- 初期化スクリプト
- デプロイスクリプト
- 自動テストスクリプト

---

## 9.4 `set -u`: 未定義変数をエラーにする

```bash
#!/bin/bash
set -u

echo $undefined_var
# 出力: bash: undefined_var: バインドされていない変数
```

### 組み合わせて使用

```bash
#!/bin/bash
set -euo pipefail

# -e: エラーで停止
# -u: 未定義変数をエラーにする
# -o pipefail: コマンドが失敗하면パイプライン全体が失敗
```

**これが AI の標準スクリプトヘッダーです！**

---

## 9.5 `trap`: グレースフルエラー処理

### 基本的な使い方

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "クリーンアップ中..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# メインプログラム
echo "プロセスを開始..."
```

### エラーをキャプチャ

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    echo "❌ スクリプトが失敗しました。行 $1、終了コード: $exit_code"
    exit $exit_code
}

trap 'error_handler $LINENO' ERR
```

---

## 9.6 カスタムエラー関数

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "❌ $@" >&2
    exit 1
}

warn() {
    echo "⚠️ $@"
}

need_command() {
    command -v "$1" &>/dev/null || die "必要なコマンド: $1"
}

need_file() {
    [[ -f "$1" ]] || die "必要なファイル: $1"
}
```

---

## 9.7 クイックリファレンス

| コマンド | 説明 |
|---------|-------------|
| `$?` | 最後のコマンドの終了コード |
| `set -e` | エラーで停止 |
| `set -u` | 未定義変数をエラーにする |
| `set -o pipefail` | いずれかのコマンドが失敗하면パイプラインが失敗 |
| `set -euo pipefail` | 組み合わせ（推奨） |
| `trap 'func' EXIT` | 終了時に実行 |
| `trap 'func' ERR` | エラー時に実行 |
| `trap 'func' INT` | Ctrl+C で実行 |
| `exit 1` | 終了コード 1 で終了 |

---

## 9.8 演習問題

1. `set -euo pipefail` を使用して、失敗時に「エラーが発生しました」と出力するスクリプトを書く
2. メッセージを出力して終了する `die()` 関数を作成する
3. `trap` を使用して、スクリプト終了時に「お疲れ様でした」と表示する
4. 失敗時に自動ロールバックするデプロイスクリプトを書く
