# 6. 權限、執行、環境與設定

---

## 6.1 `chmod`：權限的藝術

### Linux/Unix 權限基礎

```
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 .
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 README.md
-rwxr-xr-x  1 ai  staff   128 Mar 22 10:30 script.sh
```

後面 9 個字元分成三組：
- `rwx`（擁有者）：讀取、寫入、執行
- `r-x`（群組）：讀取、執行
- `r--`（其他人）：只能讀取

### chmod 的兩種表示法

**數字表示法（八進位）**：

```
r = 4, w = 2, x = 1

rwx = 7, r-x = 5, r-- = 4
```

常用組合：
- `777` = rwxrwxrwx（危險！）
- `755` = rwxr-xr-x
- `644` = rw-r--r--
- `700` = rwx------
- `600` = rw-------

**符號表示法**：

```bash
chmod u+x script.sh    # 擁有者加上執行權限
chmod g-w file.txt     # 群組移除寫入權限
chmod +x script.sh     # 所有人加上執行權限
```

### AI 的 chmod 常用場景

```bash
# 讓腳本能執行（幾乎每個腳本都要）
chmod +x script.sh

# 讓目錄可以被進入
chmod +x ~/projects

# 讓目錄和裡面的所有檔案可被群組寫入
chmod -R g+w project/
```

---

## 6.2 執行 Shell 腳本

### 執行方式

```bash
# 方式 1：用路徑執行（需要執行權限）
./script.sh

# 方式 2：用 bash 執行（不需要執行權限）
bash script.sh

# 方式 3：用 source 執行（在當前 shell 中執行）
source script.sh
```

### 什麼時候用哪種？

| 方式 | 使用時機 | 特點 |
|------|----------|------|
| `./script.sh` | 標準執行 | 需要 `chmod +x`，子 shell 執行 |
| `bash script.sh` | 指定 shell | 不需要執行權限 |
| `source script.sh` | 設定環境變數 | 在當前 shell 執行 |

### `source` vs `./script` 的關鍵差異

```bash
# script.sh 內容：export MY_VAR="hello"

# 用 ./script.sh 執行
./script.sh
echo $MY_VAR  # 輸出：（空）← 在子 shell，環境變數消失了

# 用 source script.sh 執行
source script.sh
echo $MY_VAR  # 輸出：hello ← 在當前 shell，變數保留
```

---

## 6.3 `export`：環境變數

```bash
# 設定環境變數
export NAME="Alice"
export PATH="$PATH:/new/directory"

# 顯示所有環境變數
export

# 常用變數
echo $HOME      # 家目錄
echo $USER      # 使用者名稱
echo $PATH      # 搜尋路徑
echo $PWD       # 目前目錄
```

### 持久化環境變數

```bash
# 寫入 ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc

# 讓設定生效
source ~/.bashrc
```

---

## 6.4 `source`：載入檔案

等價於：把檔案的內容**直接貼到當前位置**執行。

### 常見用途

```bash
# 載入虛擬環境
source venv/bin/activate

# 載入 .env 檔案
source .env

# 載入函式庫
source ~/scripts/common.sh
```

### 實用：模組化設定檔

```bash
# config.sh
export DB_HOST="localhost"
export DB_PORT="5432"

# 在其他腳本中使用
source config.sh
psql -h $DB_HOST -p $DB_PORT
```

---

## 6.5 `env`：環境管理

```bash
# 顯示所有環境變數
env

# 清除所有環境變數後執行
env -i HOME=/tmp PATH=/bin sh

# 設定環境變數並執行
env VAR1=value1 VAR2=value2 ./my_program
```

### 找命令

```bash
which python      # 找命令的位置
type cd           # 找 shell 內建命令
whereis gcc       # 找所有相關檔案
```

---

## 6.6 `sudo`：提升權限

```bash
# 以 root 身份執行
sudo rm /var/log/old.log

# 以特定使用者身份執行
sudo -u postgres psql

# 顯示會用什麼身份執行
sudo -l
```

### 危險警告

```bash
# 千萬不要執行這個！
sudo rm -rf /

# 永遠不要這樣做！
sudo curl http://unknown-site.com | sh
```

---

## 6.7 速查表

| 命令 | 用途 | 常用參數 |
|------|------|----------|
| `chmod` | 改變檔案權限 | `+x` 加執行, `755` 八進位, `-R` 遞迴 |
| `chown` | 改變擁有者 | `user:group`, `-R` 遞迴 |
| `./script` | 執行腳本（需要 x） | - |
| `bash script` | 執行腳本（不需要 x） | - |
| `source` | 在當前 shell 執行 | - |
| `export` | 設定環境變數 | `-n` 移除 |
| `env` | 顯示/管理環境 | `-i` 清除 |
| `sudo` | 以 root 執行 | `-u user` 指定使用者 |

---

## 6.8 練習題

1. 建立一個腳本，用 `chmod 755` 設定權限，然後執行它
2. 用 `source` 和 `./` 分別執行同一個設定環境變數的腳本，觀察差異
3. 用 `env -i` 建立一個乾淨環境，執行 `python --version`
4. 建立一個 `.env` 檔案，用 `source` 載入其中的變數
