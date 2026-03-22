# 3. ファイル操作

---

## 3.1 AI のファイルシステムのメンタルモデル

各コマンドを詳しく見る前に、AI がファイルシステムをどのように見るかを理解しましょう。

人間のエンジニアは通常、ファイルシステムを **視覚的に** 見ます—Windows エクスプローラーや macOS Finder のように、アイコンとフォルダの形を通じて理解します。

AI の見方は全く異なります：

```
path          = 絶対的な場所 /home/user/project/src/main.py
relative      = 現在位置から降りる
nodes         = すべてのファイルまたはディレクトリは「ノード」
attributes    = 権限、サイズ、タイムスタンプ、オーナー
type          = 通常ファイル(-)、ディレクトリ(d)、リンク(l)、デバイス(b/c)
```

AI が `ls -la` を実行したとき、見ているもの：

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI はこれ即座に読み取れます：
- どれがディレクトリか（`d`）
- どれが隠しファイルか（`.` で始まる）
- 誰がどんな権限を持っているか
- ファイルのサイズ（大きいか判断）
- 最終更新日時

---

## 3.2 `ls`：AI が最も使う最初のコマンド

ほぼすべての操作の前、AI は現在の状態を確認するために `ls` を実行します。

### AI の一般的な `ls` 組み合わせ

```bash
# 基本的な一覧
ls

# 隠しファイルを表示（非常重要！）
ls -a

# 詳細形式（詳しい情報）
ls -l

# 詳細形式 + 隠しファイル（最も一般的）
ls -la

# 更新日時順ソート（新しい順）
ls -lt

# 更新日時順ソート（古い順）
ls -ltr

# 読みやすいサイズ（K、M、G）
ls -lh

# ディレクトリのみ表示
ls -d */

# すべてのファイルを再帰的に表示
ls -R

# inode 番号を表示（ハードリンクに有用）
ls -li
```

### AI の実際のワークフロー

```bash
cd ~/project && ls -la

# 結果：
# drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
# drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
# -rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
# -rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
# drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
# drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
# -rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json

# AI の分析：.env ファイル、src と tests ディレクトリ、package.json がある
# これは Node.js プロジェクトだ
```

---

## 3.3 `cd`：AI が決して忘れないディレクトリ移動

### AI の `cd` の習慣

```bash
# ホームディレクトリに移動
cd ~

# 前のディレクトリに移動（非常に有用！）
cd -

# 親ディレクトリに移動
cd ..

# サブディレクトリに移動
cd src

# 深いパスを移動（Tab補完功劳）
cd ~/project/backend/api/v2/routes
```

### AI の `cd` + `&&` パターン

これは AI のもっとも一般的なパターンの一つです：

```bash
# まず cd し、成功を確認してから次のコマンドを実行
cd ~/project && ls -la
```

### 一般的なエラー

```bash
# エラー：ディレクトリの存在を確認しない
cd nonexistent
# 出力: bash: cd: nonexistent: No such file or directory

# AI のアプローチ：まず確認する
[ -d "nonexistent" ] && cd nonexistent || echo "ディレクトリが存在しません"
```

---

## 3.4 `mkdir`：ディレクトリ作成の芸術

### 基本的な使用方法

```bash
# 単一のディレクトリを作成
mkdir myproject

# 複数のディレクトリを作成
mkdir src tests docs

# ネストしたディレクトリを作成（-p が鍵！）
mkdir -p project/src/components project/tests
```

### なぜ AI はほとんど常に `-p` を使うのか

`-p`（親）フラグの意味：
1. ディレクトリが既に存在する場合、**エラーにならない**
2. 親が存在しない場合、**自動的に作成する**

### AI の典型的なプロジェクト作成パターン

```bash
# 標準的なプロジェクト構造を作成
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`：削除の芸術

**警告**：これは Shell のもっとも危険なコマンドの一つです。

### 基本的な使用方法

```bash
# ファイルを削除
rm file.txt

# ディレクトリを削除（-r が必要）
rm -r directory/

# ディレクトリとそのすべてを削除（危険！）
rm -rf directory/
```

### `rm -rf` の危険

```bash
# root としてこれを実行しないでください！
# rm -rf /

# 誤って余分なスペースを入れると：
rm -rf * 
# （スペース）= rm -rf が現在のディレクトリのすべてを削除
```

---

## 3.6 `cp`：ファイルとディレクトリのコピー

### 基本的な使用方法

```bash
# ファイルをコピー
cp source.txt destination.txt

# ディレクトリをコピー（-r が必要）
cp -r source_directory/ destination_directory/

# コピー中に進捗を表示（-v verbose）
cp -v large_file.iso /backup/

# インタラクティブモード（上書き前に確認）
cp -i *.py src/
```

### ワイルドカードの威力

```bash
# すべての .txt ファイルをコピー
cp *.txt backup/

# すべての画像ファイルをコピー
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`：移動と名前変更

### 基本的な使用方法

```bash
# ファイルを移動
mv file.txt backup/

# 移動して名前を変更
mv oldname.txt newname.txt

# 一括名前変更
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 クイックリファレンス

| コマンド | 基本的な使用法 | 一般的なフラグ | AI メモ |
|---------|-------------|--------------|---------|
| `ls` | `ls [path]` | `-l` 詳細、`-a` 隠し、`-h` 人間 | `ls -la` は常に良い |
| `cd` | `cd [path]` | `-` 前回、`..` 親 | `cd xxx &&` は良い習慣 |
| `mkdir` | `mkdir [dir]` | `-p` ネスト | ほとんど常に `-p` を使う |
| `rm` | `rm [file]` | `-r` 再帰的、`-f` 強制 | `rm -rf /*` に注意 |
| `cp` | `cp [src] [dst]` | `-r` ディレクトリ、`-i` 確認、`-p` 保持 | 安全のため `-i` を使う |
| `mv` | `mv [src] [dst]` | `-i` 確認、`-n` 上書き禁止 | 名前変更用它 |
| `touch` | `touch [file]` | - | 空のファイルを作成 |
| `stat` | `stat [file]` | - | ファイルの詳しい情報を表示 |

---

## 3.9 演習

1. `mkdir -p` を使って3レベルネストされたディレクトリを作成し、`tree` または `find` で確認する
2. `cp -v` で大きなファイルをコピーし、出力を確認する
3. `mv` で10個の `.txt` ファイルを `.md` に一括名前変更する
4. `rm -i` でテストファイルを削除し、プロンプトを体験する
