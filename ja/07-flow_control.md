# 7. フロー制御と条件ループ

---

## 7.1 コマンドの組み合わせ：Shell の本質

単一のコマンドには能力が限られています。**組み合わせる** ことで初めて複雑なタスクを完了できます。

AI が強力な理由は、これらの組み合わせをマスターしているからです：

```bash
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -10
```

これは意味します：「access.log からエラーを探し、発生回数をカウント、上位10件を表示」

---

## 7.2 `|`（パイプ）：データフローの芸術

パイプは前のコマンドの **出力** を次のコマンドの **入力** にします。

```bash
# ファイルの内容をソート
cat unsorted.txt | sort

# 最も一般的なコマンドを見つける
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

# ログから IP を抽出してカウント
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

### stderr をパイプする

```bash
# stderr をパイプに送信
command1 2>&1 | command2

# または Bash 4+
command1 |& command2
```

---

## 7.3 `&&`：成功した場合のみ次のコマンドを実行

**command1 が成功した場合（終了コード = 0）のみ、command2 が実行されます。**

```bash
# ディレクトリを作成してから移動
mkdir -p project && cd project

# コンパイルしてから実行
gcc -o program source.c && ./program

# ダウンロードしてから展開
curl -L -o archive.tar.gz http://example.com/file && tar -xzf archive.tar.gz
```

---

## 7.4 `||`：失敗した場合のみ次のコマンドを実行

**command1 が失敗した場合（終了コード ≠ 0）のみ、command2 が実行されます。**

```bash
# ファイルが存在しない場合は作成
[ -f config.txt ] || echo "設定がありません" > config.txt

# 別の方法を試す
cd /opt/project || cd /home/user/project

# 失敗しても成功にする（makefile で一般的）
cp file.txt file.txt.bak || true
```

### `&&` と `||` を組み合わせる

```bash
# 条件式
[ -f config ] && echo "見つかりました" || echo "見つかりません"

# 以下と同等：
if [ -f config ]; then
    echo "見つかりました"
else
    echo "見つかりません"
fi
```

---

## 7.5 `;`：関係なく実行

```bash
# 3つすべて実行
mkdir /tmp/test ; cd /tmp/test ; pwd
```

---

## 7.6 `$()`：コマンド置換

**コマンドを実行し、`$()` を出力で置き換えます。**

```bash
# 基本的な使用法
echo "今日は $(date +%Y-%m-%d)"
# 出力: 今日は 2026-03-22

# 変数の中で
FILES=$(ls *.txt)

# ディレクトリ名を取得
DIR=$(dirname /path/to/file.txt)
BASE=$(basename /path/to/file.txt)

# 計算
echo "結果は $((10 + 5))"
# 出力: 結果は 15
```

### バックティックとの比較

```bash
# 両方同等
echo "今日は $(date +%Y)"
echo "今日は `date +%Y`"

# しかし $() はネストできる
echo $(echo $(echo nested))
```

---

## 7.7 `[[ ]]` と `[ ]`：条件テスト

### ファイルテスト

```bash
[[ -f file.txt ]]      # 通常ファイルが存在
[[ -d directory ]]     # ディレクトリが存在
[[ -e path ]]           # 任意のタイプが存在
[[ -L link ]]           # シンボリックリンクが存在
[[ -r file ]]           # 読み取り可能
[[ -w file ]]           # 書き込み可能
[[ -x file ]]           # 実行可能
[[ file1 -nt file2 ]]  # file1 が file2 より新しい
```

### 文字列テスト

```bash
[[ -z "$str" ]]        # 文字列が空
[[ -n "$str" ]]        # 文字列が空でない
[[ "$str" == "value" ]] # 等しい
[[ "$str" =~ pattern ]]  # 正規表現に一致
```

### 数値テスト

```bash
[[ $num -eq 10 ]]      # 等しい
[[ $num -ne 10 ]]      # 等しくない
[[ $num -gt 10 ]]      # より大きい
[[ $num -lt 10 ]]      # より小さい
```

---

## 7.8 `if`：条件文

```bash
if [[ condition ]]; then
    # 何かする
elif [[ condition2 ]]; then
    # 別の何かをする
else
    # フォールバック
fi
```

### 完全な例

```bash
#!/bin/bash

FILE="config.yaml"

if [[ ! -f "$FILE" ]]; then
    echo "エラー: $FILE が存在しません"
    exit 1
fi

if [[ -r "$FILE" ]]; then
    echo "ファイルは読み取り可能です"
else
    echo "ファイルは読み取りできません"
fi
```

---

## 7.9 `for`：ループ

### 基本的な構文

```bash
for variable in list; do
    # $variable を使用
done
```

### AI の一般的なパターン

```bash
# すべての .txt ファイルを処理
for file in *.txt; do
    echo "処理中: $file"
done

# 数値範囲
for i in {1..10}; do
    echo "反復 $i"
done

# 配列
for color in red green blue; do
    echo $color
done

# C スタイルループ（Bash 3+）
for ((i=0; i<10; i++)); do
    echo $i
done
```

---

## 7.10 `while`：条件付きループ

```bash
# 行を読み込む
while IFS= read -r line; do
    echo "読み込み: $line"
done < file.txt

# カウントループ
count=0
while [[ $count -lt 10 ]]; do
    echo $count
    ((count++))
done
```

---

## 7.11 `case`：パターンマッチング

```bash
case $ACTION in
    start)
        echo "サービスを開始..."
        ;;
    stop)
        echo "サービスを停止..."
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "使用方法: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

### ワイルドカードパターン

```bash
case "$filename" in
    *.txt)
        echo "テキストファイル"
        ;;
    *.jpg|*.png|*.gif)
        echo "画像ファイル"
        ;;
    *)
        echo "不明なタイプ"
        ;;
esac
```

---

## 7.12 クイックリファレンス

| 記号 | 名前 | 説明 |
|--------|------|-------------|
| `\|` | パイプ | 出力を次の入力に渡す |
| `&&` | AND | 前の成功時のみ次を実行 |
| `\|\|` | OR | 前の失敗時のみ次を実行 |
| `;` | セミコロン | 関係なく実行 |
| `$()` | コマンド置換 | 実行し、出力で置き換える |
| `[[ ]]` | 条件テスト | 推奨されるテスト構文 |
| `if` | 条件 | 条件に基づいて分岐 |
| `for` | カウントループ | リストを反復 |
| `while` | 条件付きループ | 条件が真の間繰り返す |
| `case` | パターンマッチ | 多方向分岐 |

---

## 7.13 演習

1. `|` を使って `ls`、`grep`、`wc` を組み合わせて `.log` ファイルの数をカウントする
2. `&&` を使って `cd` が成功してから続けることを確認する
3. `for` ループを使って10個のディレクトリ（dir1 から dir10）を作成する
4. `while read` を使って /etc/hosts を読み込んで表示する
5. `case` で簡単な電卓を書く（加算、減算、乗算、除算）
