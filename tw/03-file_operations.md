# 3. 檔案操作

---

## 3.1 AI 的檔案系統心智模型

在深入每個命令之前，先理解 AI 如何看待檔案系統。

人類工程師通常**視覺化**地看待檔案系統——像 Windows 檔案總管或 macOS Finder那樣，用圖示和資料夾的形狀理解。

AI 看待檔案系統的方式完全不同：

```
路徑         = 絕對位置 /home/user/project/src/main.py
相對位置     = 從目前位置往下走
節點         = 每一個檔案或目錄都是一個「節點」
屬性         = 權限、大小、時間戳、擁有者
類型         = 普通檔案(-)、目錄(d)、連結(l)、設備(b/c)
```

當 AI 執行 `ls -la` 時，它看到的是：

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI 能立即從這些資訊中讀出：
- 哪些是目錄（`d`）
- 哪些是隱藏檔（以 `.` 開頭）
- 誰有什麼權限
- 檔案大小（判斷是否為大型檔案）
- 最後修改時間

---

## 3.2 `ls`：AI 最常用的第一個命令

幾乎每一次操作之前，AI 都會先執行 `ls` 確認現況。

### AI 常用的 `ls` 組合

```bash
# 基本列表
ls

# 顯示隱藏檔（非常重要！）
ls -a

# 長格式（包含詳細資訊）
ls -l

# 長格式 + 隱藏檔（最常用）
ls -la

# 依修改時間排序（最新的在前）
ls -lt

# 依修改時間排序（最舊的在前）
ls -ltr

# 人類可讀的大小（K、M、G）
ls -lh

# 只顯示目錄
ls -d */

# 遞迴顯示所有檔案
ls -R

# 顯示 inode 編號（找硬連結時很有用）
ls -li
```

### AI 的實際工作流程

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

# AI 分析：有一個 .env 檔、src 和 tests 目錄、package.json
# 這是一個 Node.js 專案
```

---

## 3.3 `cd`：AI 永遠不會忘記去的目錄

### AI 的 `cd` 習慣

```bash
# 回到 home 目錄
cd ~

# 回到上一個目錄（非常實用！）
cd -

# 回到上層目錄
cd ..

# 進入子目錄
cd src

# 進入很深的路徑（Tab 補全的功勞）
cd ~/project/backend/api/v2/routes
```

### AI 的 `cd` + `&&` 模式

這是 AI 最常用的模式之一：

```bash
# 先 cd，確認成功後才執行下一個命令
cd ~/project && ls -la
```

### 常見錯誤

```bash
# 錯誤：沒有確認目錄存在
cd nonexistent
# 輸出：bash: cd: nonexistent: No such file or directory

# AI 的做法：先檢查
[ -d "nonexistent" ] && cd nonexistent || echo "目錄不存在"
```

---

## 3.4 `mkdir`：建立目錄的藝術

### 基本用法

```bash
# 建立單一目錄
mkdir myproject

# 建立多個目錄
mkdir src tests docs

# 建立巢狀目錄（-p 是關鍵！）
mkdir -p project/src/components project/tests
```

### AI 為什麼幾乎總是用 `-p`

`-p` 參數（parents）的意義：
1. 如果目錄已存在，**不報錯**
2. 如果父目錄不存在，**自動建立**

### AI 的典型專案建立模式

```bash
# 建立一個標準專案結構
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`：刪除的藝術

**警告**：這是 Shell 中最危險的命令之一。

### 基本用法

```bash
# 刪除檔案
rm file.txt

# 刪除目錄（需要 -r）
rm -r directory/

# 刪除目錄和所有內容（危險！）
rm -rf directory/
```

### `rm -rf` 的危險性

```bash
# 千萬不要在 root 身份下執行這個！
# rm -rf /

# 假設你不小心多了空格：
rm -rf * 
# (空格) = rm -rf 刪除當前目錄的所有東西
```

---

## 3.6 `cp`：複製檔案與目錄

### 基本用法

```bash
# 複製檔案
cp source.txt destination.txt

# 複製目錄（需要 -r）
cp -r source_directory/ destination_directory/

# 複製時顯示進度（-v verbose）
cp -v large_file.iso /backup/

# 互動模式（覆蓋前詢問）
cp -i *.py src/
```

### 萬用字元的威力

```bash
# 複製所有 .txt 檔案
cp *.txt backup/

# 複製所有圖片檔案
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`：移動與重新命名

### 基本用法

```bash
# 移動檔案
mv file.txt backup/

# 移動並重新命名
mv oldname.txt newname.txt

# 批次重新命名
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 速查表

| 命令 | 基本用法 | 常用參數 | AI 備註 |
|------|----------|----------|---------|
| `ls` | `ls [路徑]` | `-l` 長格式, `-a` 隱藏檔, `-h` 人類可讀 | 先 `ls -la` 總是好的 |
| `cd` | `cd [路徑]` | `-` 回上一個, `..` 上層 | `cd xxx &&` 是好習慣 |
| `mkdir` | `mkdir [目錄]` | `-p` 巢狀建立 | 幾乎總是用 `-p` |
| `rm` | `rm [檔案]` | `-r` 遞迴, `-f` 強制 | 小心 `rm -rf /*` |
| `cp` | `cp [來源] [目標]` | `-r` 目錄, `-i` 詢問, `-p` 保留屬性 | 用 `-i` 防呆 |
| `mv` | `mv [來源] [目標]` | `-i` 詢問, `-n` 不覆蓋 | 就是 rename |

---

## 3.9 練習題

1. 用 `mkdir -p` 建立三層巢狀目錄，然後用 `tree` 或 `find` 確認
2. 用 `cp` 複製一個大檔案，加上 `-v` 看看輸出什麼
3. 用 `mv` 批次將 10 個 `.txt` 檔案重新命名為 `.md`
4. 用 `rm -i` 刪除一個測試檔案，體驗詢問過程
