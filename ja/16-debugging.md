# 16. デバッグ技法

---

## 16.1 AI のデバッグマインドセット

人間のエラー対応：パニック、Web検索、コピペ
AIのエラー対応：错误メッセージの分析、原因の推論、修正の実行

AIのデバッグフロー：
```
エラーメッセージの観察 → エラーの種類の理解 → 問題の特定 → 修正 → 検証
```

---

## 16.2 `bash -x`：実行トレース

最も簡単なデバッグ：`-x` フラグを追加

```bash
bash -x script.sh
```

実行された行を `+` プレフィックス付きで出力：

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### 特定のセクションのみデバッグ

```bash
#!/bin/bash

echo "これは表示されない"
set -x
# ここからデバッグ開始
name="Alice"
echo "Hello, $name"
set +x
# ここでデバッグ終了
echo "これは表示されない"
```

---

## 16.3 よく見るエラーと修正

### エラー1：許可がありません

```bash
# エラー
./script.sh
# 出力: Permission denied

# 修正
chmod +x script.sh
./script.sh
```

### エラー2：コマンドが見つかりません

```bash
# エラー
python script.py
# 出力: command not found: python

# 修正：フルパスを使用
/usr/bin/python3 script.py
```

### エラー3：未定義の変数

```bash
#!/bin/bash
set -u

echo $undefined_var
# 出力: bash: undefined_var: unbound variable

# 修正：デフォルト値を与える
echo ${undefined_var:-default}
```

---

## 16.4 `echo` デバッグ

`-x` で不十分な場合、手動で `echo` を追加：

```bash
#!/bin/bash

echo "DEBUG: 関数に入る"
echo "DEBUG: パラメータ = $@"

process() {
    echo "DEBUG: process内"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
}
```

---

## 16.5 クイックリファレンス

| コマンド | 説明 |
|---------|------|
| `bash -n script.sh` | 構文のみチェック |
| `bash -x script.sh` | 実行トレース |
| `set -x` | デバッグモード開始 |
| `set +x` | デバッグモード終了 |
| `trap 'echo cmd' DEBUG` | 各コマンドをトレース |

---

## 16.6 練習問題

1. スクリプトを `bash -x` で実行し、出力フォーマットを観察する
2. `set -x` を使用してスクリプトの特定の関数のみをデバッグする
3. 失敗するコマンドを見つけ、エラーメッセージを分析して修正する
4. `trap` を使用して柔軟なエラー処理を実装する
