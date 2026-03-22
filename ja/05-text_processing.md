# 5. テキスト処理

---

## 5.1 AI のテキスト処理哲学

AI の世界では、**すべてがテキスト**です。

- コードはテキスト
- 設定ファイルはテキスト
- ログはテキスト
- JSON、HTML、Markdown はすべてテキスト

だからテキスト処理コマンドは AI のツールキットの核心です。

人間のエンジニアが問題に遭遇したとき：「これを処理するツールが必要です...」
AI が問題に遭遇したとき：「これは `grep | sed | awk` で1行で解決できる」

---

## 5.2 `cat`：ファイルを読み解く芸術

### 基本的な使用方法

```bash
# ファイル内容を表示
cat file.txt

# ファイルを結合
cat part1.txt part2.txt > whole.txt

# 行番号を表示
cat -n script.sh
```

### 本当の目的：結合と作成

```bash
cat << 'EOF' > newfile.txt
ファイルの内容
何行でも書ける
EOF
```

---

## 5.3 `head` と `tail`：必要な部分だけを見る

### `head`：先頭を見る

```bash
# 最初の10行（デフォルト）
head file.txt

# 最初の5行
head -n 5 file.txt

# 最初の100バイト
head -c 100 file.txt
```

### `tail`：末尾を見る

```bash
# 最後の10行（デフォルト）
tail file.txt

# 最後の5行
tail -n 5 file.txt

# リアルタイムでファイルをフォロー（最も一般的！）
tail -f /var/log/syslog

# フォローして grep
tail -f app.log | grep --line-buffered ERROR
```

### 特定の行範囲を表示

```bash
# 100-150行目を表示
tail -n +100 file.txt | head -n 50
```

---

## 5.4 `wc`：カウントツール

```bash
# 行数をカウント
wc -l file.txt

# 複数のファイルの行数をカウント
wc -l *.py

# ディレクトリ内のファイルをカウント
ls | wc -l
```

---

## 5.5 `grep`：テキスト検索の王

### 基本的な使用方法

```bash
# "error" 行を検索
grep "error" log.txt

# 大文字小文字を無視
grep -i "error" log.txt

# 行番号を表示
grep -n "error" log.txt

# ファイル名のみ表示
grep -l "TODO" *.md

# 反転（一致しない行）
grep -v "debug" log.txt

# 完全一致
grep -w "error" log.txt
```

### 正規表現

```bash
# 行頭と一致
grep "^Error" log.txt

# 行末と一致
grep "done.$" log.txt

# 任意の1文字
grep "e.or" log.txt

# 範囲
grep -E "[0-9]{3}-" log.txt
```

### 高度なテクニック

```bash
# 再帰的検索
grep -r "TODO" src/

# 特定の拡張子のみ
grep -r "TODO" --include="*.py" src/

# 前後の行を表示
grep -B 2 -A 2 "ERROR" log.txt

# 複数の条件（OR）
grep -E "error|warning|fatal" log.txt
```

---

## 5.6 `sed`：テキスト置換ツール

### 基本的な置換

```bash
# 最初のマッチを置換
sed 's/old/new/' file.txt

# すべてのマッチを置換
sed 's/old/new/g' file.txt

# 直接置換
sed -i 's/old/new/g' file.txt

# バックアップしてから置換
sed -i.bak 's/old/new/g' file.txt
```

### 行を削除

```bash
# 空行を削除
sed '/^$/d' file.txt

# コメント行を削除
sed '/^#/d' file.txt

# 行末の空白を削除
sed 's/[[:space:]]*$//' file.txt
```

### 実践的な例

```bash
# 拡張子を一括変更（.txt → .md）
for f in *.txt; do
    mv "$f" "$(sed 's/.txt$/.md/' <<< "$f")"
done

# Windows の改行を削除
sed -i 's/\r$//' file.txt
```

---

## 5.7 `awk`：テキスト処理のスイスアーミーナイフ

### 基本的な概念

`awk` はテキストを行ごとに処理し、自動的にフィールド（$1、$2、$3...）に分割し、各行に対して指定されたアクションを実行します。

### 基本的な使用方法

```bash
# デフォルトの空白分割
awk '{print $1}' file.txt

# 区切り文字を指定
awk -F: '{print $1}' /etc/passwd

# 複数のフィールドを出力
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### 条件付き処理

```bash
# 一致する行のみ処理
awk -F: '$3 > 1000 {print $1}' /etc/passwd

# BEGIN と END
awk 'BEGIN {print "開始"} {print} END {print "終了"}' file.txt
```

### 実践的な例

```bash
# CSV の列を合計
awk -F, '{sum += $3} END {print sum}' data.csv

# 最大値を見つける
awk 'NR==1 {max=$3} $3>max {max=$3} END {print max}' data.csv

# フォーマットされた出力
awk '{printf "%-20s %10.2f\n", $1, $2}' data.txt
```

---

## 5.8 実践：すべてのツールを組み合わせる

### シナリオ：サーバーログを分析

```bash
# 1. エラーメッセージを見つける
grep -i "error" access.log

# 2. エラーをカウント
grep -ci "error" access.log

# 3. 最も一般的なエラーを見つける
grep "error" access.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# 4. 時間ごとのリクエスト数をカウント
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

### シナリオ：コードを一括修正

```bash
# すべての .py ファイルで "print" を "logger.info" に変更
find . -name "*.py" -exec sed -i 's/print(/logger.info(/g' {} +

# var を const に変更
find . -name "*.js" -exec sed -i 's/\bvar\b/const/g' {} +
```

---

## 5.9 クイックリファレンス

| コマンド | 目的 | 一般的なフラグ |
|---------|---------|--------------|
| `cat` | ファイルを表示/結合 | `-n` 行番号 |
| `head` | ファイルの先頭を表示 | `-n` 行数、`-c` バイト |
| `tail` | ファイルの末尾を表示 | `-n` 行数、`-f` フォロー |
| `wc` | カウント | `-l` 行数、`-w` 単語、`-c` バイト |
| `grep` | テキスト検索 | `-i` 無視、`-n` 行番号、`-r` 再帰的、`-c` カウント |
| `sed` | テキスト置換 | `s/old/new/g`、`-i` 直接置換 |
| `awk` | フィールド処理 | `-F` 区切り、`{print}` アクション |

---

## 5.10 演習

1. `head` と `tail` を使って100-120行目を表示する
2. `grep` を使って /etc/passwd で `/bin/bash` を持つすべてのユーザーを検索する
3. `sed` を使ってすべての `\r\n` を `\n` に置換する
4. `awk` を使って数値ファイルの最大値、最小値、平均を計算する
