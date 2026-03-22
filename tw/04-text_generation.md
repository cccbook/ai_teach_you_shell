# 4. 文字生成與寫入

---

## 4.1 為什麼 AI 不需要編輯器

大多數人類工程師寫程式碼的流程是：
1. 開啟編輯器（VS Code、Vim、Emacs...）
2. 輸入程式碼
3. 儲存檔案
4. 關閉編輯器

對 AI 來說：
```
「寫一個 Python 程式」 = 產生一段文字
「把這個程式存成檔案」 = 把文字寫入磁碟
```

AI 使用的核心工具：
- `echo`：輸出單行文字
- `printf`：格式化輸出
- `heredoc`：輸出多行文字（最重要！）

---

## 4.2 `echo`：最簡單的輸出

### 基本用法

```bash
# 輸出字串
echo "Hello, World!"

# 輸出變數
name="Alice"
echo "Hello, $name!"

# 輸出多個值
echo "今天是 $(date +%Y-%m-%d)"
```

### `echo` 的陷阱

```bash
# echo 預設會換行
echo -n "Loading: "  # 不換行
```

### 用 `echo` 寫入檔案

```bash
# 覆蓋寫入
echo "Hello, World!" > file.txt

# 附加到檔案末尾
echo "第二行" >> file.txt
```

**注意**：用 `echo` 寫多行檔案很痛苦，所以 AI 幾乎不用它寫程式碼。`heredoc` 才是主角。

---

## 4.3 `printf`：更強大的格式化輸出

### 與 `echo` 的比較

```bash
# printf 支援 C 語言風格的格式化
printf "Value: %.2f\n" 3.14159
# 輸出：Value: 3.14

printf "%s\t%s\n" "名稱" "年齡"
```

### 製作表格

```bash
printf "%-15s %10s\n" "名稱" "價格"
printf "%-15s %10.2f\n" "iPhone" 999.99
printf "%-15s %10.2f\n" "MacBook" 1999.99
```

---

## 4.4 heredoc：AI 寫程式碼的核心武器

### heredoc 是什麼？

heredoc 是 Shell 的一個特殊語法，用於**原樣輸出多行文字**。

```bash
cat << 'EOF'
這裡的所有內容
都會被原樣輸出
包括換行、空格
EOF
```

### 寫入檔案（AI 最常用的方式）

```bash
cat > program.py << 'EOF'
#!/usr/bin/env python3

def hello(name):
    print(f"Hello, {name}!")

if __name__ == "__main__":
    hello("World")
EOF
```

### 為什麼用 `'EOF'`（單引號）？

```bash
# 單引號 EOF：不解釋任何變數或命令
cat << 'EOF'
HOME 是: $HOME
今天是: $(date)
EOF
# 輸出：HOME 是: $HOME（不展開）

# 雙引號 EOF 或無引號：會展開變數
cat << EOF
HOME 是: $HOME
EOF
# 輸出：HOME 是: /home/ai（展開）
```

**AI 的選擇**：幾乎總是用 `'EOF'`（單引號）。因為程式碼通常不需要 Shell 變數展開。

---

## 4.5 AI 用 heredoc 寫各種檔案

### 寫 Python 程式

```bash
cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""主程式入口"""

import sys
import os

def main():
    print("Python + C 混合專案")
    print(f"工作目錄: {os.getcwd()}")

if __name__ == "__main__":
    main()
EOF
```

### 寫 Shell 腳本

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

DEPLOY_HOST="server.example.com"

echo "🚀 開始部署到 $DEPLOY_HOST"
rsync -avz --delete ./dist/ "$DEPLOY_HOST:/var/www/app/"
ssh "$DEPLOY_HOST" "systemctl restart myapp"
echo "✅ 部署完成！"
EOF

chmod +x scripts/deploy.sh
```

### 寫設定檔

```bash
cat > config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF
```

### 寫 Docker 檔案

```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "http.server", "8000"]
EOF
```

---

## 4.6 heredoc 的陷阱與解決方案

### 陷阱 1：包含單引號

```bash
# 問題：單引號 EOF 不允許單引號
cat << 'EOF'
He's going.
EOF
# 輸出：語法錯誤

# 解決：用雙引號 EOF
cat << "EOF"
He's going.
EOF
```

### 陷阱 2：包含 `$` 字元（但不想要展開）

```bash
# 問題：雙引號 EOF 會展開 $
cat << "EOF"
價格是 $100
EOF
# 輸出：價格是（空）

# 解決：個別 escape
cat << "EOF"
價格是 $$100
EOF
# 輸出：價格是 $100
```

### 陷阱 3：包含 EOF 作為文字內容

```bash
# 解決：用其他 delimiter
cat << 'ENDOFLETTER'
Dear valued customer,
Best regards,
ENDOFLETTER
```

---

## 4.7 實戰：從無到有建立一個完整的專案

```bash
# 1. 建立目錄結構
mkdir -p myblog/{src,themes,content}

# 2. 建立設定檔
cat > myblog/config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF

# 3. 建立 Python 主程式
cat > myblog/src/blog.py << 'EOF'
#!/usr/bin/env python3
"""Simple blog generator"""
import json
from pathlib import Path

def load_config():
    config_path = Path(__file__).parent.parent / "config.json"
    with open(config_path) as f:
        return json.load(f)

if __name__ == "__main__":
    config = load_config()
    print(f"Generating: {config['site_name']}")
EOF

# 4. 建立建置腳本
cat > myblog/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🔨 Building blog..."
cd "$(dirname "$0")"
python3 src/blog.py
echo "✅ Build complete!"
EOF

chmod +x myblog/build.sh

# 5. 驗證結構
find myblog -type f | sort
```

**這個腳本執行後，會建立一個完整的部落格專案，沒有使用任何編輯器。**

---

## 4.8 速查表

| 工具 | 用途 | 範例 |
|------|------|------|
| `echo` | 輸出單行文字 | `echo "Hello"` |
| `echo -n` | 輸出不換行 | `echo -n "Loading..."` |
| `printf` | 格式化輸出 | `printf "%s: %d\n" "age" 25` |
| `>` | 覆蓋寫入檔案 | `echo "hi" > file.txt` |
| `>>` | 附加到檔案末尾 | `echo "hi" >> file.txt` |
| `<< 'EOF'` | heredoc（不解釋變數） | 寫程式碼首選 |
| `<< "EOF"` | heredoc（展開變數） | 少用 |

---

## 4.9 練習題

1. 用 `echo -n` 和 `for` 迴圈做一個 Loading 動畫
2. 用 `printf` 製作一個格式化表格（姓名、年齡、職業）
3. 用 heredoc 寫一個 20 行的 Python 程式
4. 用 heredoc 寫一個 docker-compose.yml
