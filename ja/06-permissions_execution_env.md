# 6. 権限、実行、環境と設定

---

## 6.1 `chmod`：権限の芸術

### Linux/Unix 権限の基礎

```
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 .
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 README.md
-rwxr-xr-x  1 ai  staff   128 Mar 22 10:30 script.sh
```

9文字は3つのグループに分かれています：
- `rwx`（所有者）：読み取り、書き込み、実行
- `r-x`（グループ）：読み取り、実行
- `r--`（その他）：読み取りのみ

### chmod の2つの表現方法

**数値（8進数）**：

```
r = 4, w = 2, x = 1

rwx = 7, r-x = 5, r-- = 4
```

一般的な組み合わせ：
- `777` = rwxrwxrwx（危険！）
- `755` = rwxr-xr-x
- `644` = rw-r--r--
- `700` = rwx------
- `600` = rw-------

**記号式**：

```bash
chmod u+x script.sh    # 所有者が実行を追加
chmod g-w file.txt     # グループが書き込みを削除
chmod +x script.sh     # 全員が実行を追加
```

### AI の一般的な chmod 使用法

```bash
# スクリプトを実行可能にする（ほぼすべてのスクリプト）
chmod +x script.sh

# ディレクトリを移動可能にする
chmod +x ~/projects

# グループ書き込み可能ディレクトリ
chmod -R g+w project/
```

---

## 6.2 Shell スクリプトの実行

### 実行方法

```bash
# 方法1：パスで実行（実行権限が必要）
./script.sh

# 方法2：bash を使用（実行権限が不要）
bash script.sh

# 方法3：source を使用（現在のシェルで実行）
source script.sh
```

### どれをいつ使うか

| 方法 | 使用时机 | 特徴 |
|--------|-------------|-----------------|
| `./script.sh` | 標準実行 | `chmod +x` が必要、サブシェル |
| `bash script.sh` | シェルを指定 | 実行権限が不要 |
| `source script.sh` | 環境を設定 | 現在のシェルで実行 |

### `source` と `./script` の主な違い

```bash
# script.sh の内容: export MY_VAR="hello"

# ./ で実行
./script.sh
echo $MY_VAR  # 出力: (空) ← サブシェルなので変数は消える

# source で実行
source script.sh
echo $MY_VAR  # 出力: hello ← 現在のシェルなので変数は残る
```

---

## 6.3 `export`：環境変数

```bash
# 環境変数を設定
export NAME="Alice"
export PATH="$PATH:/new/directory"

# すべての環境変数を表示
export

# 一般的な変数
echo $HOME      # ホームディレクトリ
echo $USER      # ユーザー名
echo $PATH      # 検索パス
echo $PWD       # 現在のディレクトリ
```

### 環境変数を永続化

```bash
# ~/.bashrc に追加
echo 'export EDITOR=vim' >> ~/.bashrc

# 変更を適用
source ~/.bashrc
```

---

## 6.4 `source`：ファイルを読み込む

同等：`現在の位置にファイルのコンテンツを直接 **貼り付け** て実行`。

### 一般的な使用法

```bash
# 仮想環境を読み込む
source venv/bin/activate

# .env ファイルを読み込む
source .env

# ライブラリを読み込む
source ~/scripts/common.sh
```

### 実践：モジュラー設定ファイル

```bash
# config.sh
export DB_HOST="localhost"
export DB_PORT="5432"

# 他のスクリプトで使用
source config.sh
psql -h $DB_HOST -p $DB_PORT
```

---

## 6.5 `env`：環境管理

```bash
# すべての環境変数を表示
env

# クリーンな環境で実行
env -i HOME=/tmp PATH=/bin sh

# 変数を設定して実行
env VAR1=value1 VAR2=value2 ./my_program
```

### コマンドを探す

```bash
which python      # コマンドの場所を探す
type cd           # シェル組み込みを探す
whereis gcc       # すべての関連ファイルを探す
```

---

## 6.6 `sudo`：権限を上げる

```bash
# root として実行
sudo rm /var/log/old.log

# 特定のユーザーとして実行
sudo -u postgres psql

# できること表示
sudo -l
```

### 危険警告

```bash
# これを実行しないでください！
sudo rm -rf /

# これもしないでください！
sudo curl http://unknown-site.com | sh
```

---

## 6.7 クイックリファレンス

| コマンド | 目的 | 一般的なフラグ |
|---------|---------|--------------|
| `chmod` | ファイルの権限を変更 | `+x` 実行を追加、`755` 8進数、`-R` 再帰的 |
| `chown` | 所有者を変更 | `user:group`、`-R` 再帰的 |
| `./script` | スクリプトを実行（x が必要） | - |
| `bash script` | スクリプトを実行（x 不要） | - |
| `source` | 現在のシェルで実行 | - |
| `export` | 環境変数を設定 | `-n` 削除 |
| `env` | 環境を表示/管理 | `-i` クリア |
| `sudo` | root として実行 | `-u user` ユーザーを指定 |

---

## 6.8 演習

1. スクリプトを作成し、`chmod 755` で権限を設定し、実行する
2. 同じ環境変数スクリプトを `source` と `./` で実行し、違いを観察する
3. `env -i` でクリーンな環境を作成し、`python --version` を実行する
4. `.env` ファイルを作成し、`source` で変数を読み込む
