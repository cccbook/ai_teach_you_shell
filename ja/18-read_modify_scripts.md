# 18. 他の人のスクリプトの読み方

---

## 18.1 なぜ他の人のスクリプトを読むのか

- プロジェクトの保守を引き継ぐ
- オープンソースツールを使用する
- 問題をデバッグする
- 新しい技術を学ぶ

AIは毎日慣れていないスクリプトに出会うため、他人が書いたShellスクリプトをすぐに理解する能力を身につけることは必須です。

---

## 18.2 最初の観察

### ステップ1：shebangを確認

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # bashを使用
#!/bin/sh        # POSIX shを使用（より互換性あり）
```

### ステップ2：権限とサイズを確認

```bash
ls -la script.sh
wc -l script.sh
```

### ステップ3：構文を快速チェック

```bash
bash -n script.sh  # 構文のみチェック、実行はしない
```

---

## 18.3 構造を理解する

### 典型的な構造

```bash
#!/bin/bash
# コメント：スクリプトの説明

# セットアップ
set -euo pipefail
VAR="value"

# 関数定義
function help() { ... }

# メイン処理
main() { ... }

# 実行
main "$@"
```

### メイン処理を見つける

```bash
# 末尾の行を確認
tail -20 script.sh

# 関数定義を見つける
grep -n "^function\|^[[:space:]]*[a-z_]*\(" script.sh
```

---

## 18.4 よく使う分析コマンド

```bash
# すべての関数定義を見つける
grep -n "^[[:space:]]*function" script.sh

# すべての条件文を見つける
grep -n "if\|\[\[" script.sh

# すべてのループを見つける
grep -n "for\|while\|do\|done" script.sh

# コマンド置換を見つける
grep -n '\$(' script.sh

# すべてのexitを見つける
grep -n "exit" script.sh
```

---

## 18.5 セキュリティチェック

```bash
# 危険なコマンドを見つける
grep -n "rm -rf" script.sh
grep -n "sudo" script.sh
grep -n "eval" script.sh

# 変数インジェクションのリスクを確認
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh
```

---

## 18.6 練習問題

1. `grep` と `awk` を使用して既存のShellスクリプトを分析する
2. スクリプト内のすべての変数を見つけ、その目的を理解する
3. `bash -n` を使用してスクリプトの構文をチェックする
4. コメントのないスクリプトに各セクションを説明するコメントを追加する
