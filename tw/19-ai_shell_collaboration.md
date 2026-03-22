# 19. AI + Shell 的協作模式

---

## 19.1 人機協作的新形態

傳統的程式設計：
- 人類用鍵盤輸入
- 人類用滑鼠操作 IDE
- 人類執行和測試

AI 時代的程式設計：
- 人類描述需求
- AI 生成 Shell 命令和腳本
- 人類審查和執行
- 人類和 AI 一起除錯

---

## 19.2 描述需求給 AI

### 好的描述

```bash
# 明確的任務
"找出 /var/log 目錄下所有大於 100MB 的 .log 檔案"

# 包含預期輸出格式
"列出所有 .py 檔案，每行顯示：行數 檔名"

# 說明限制條件
"把所有 .txt 檔案壓縮，但跳過任何包含 'test' 的檔案"
```

### 不好的描述

```bash
# 太模糊
"幫我處理日誌"

# 不切實際
"幫我寫一個作業系統"
```

---

## 19.3 AI 生成的 Shell 命令模式

### 模式 1：一行命令

```bash
# 人類問：找出行數最多的 10 個 Python 檔案
find . -name "*.py" -exec wc -l {} + | sort -rn | head -10
```

### 模式 2：Shell 腳本

```bash
# 人類問：批次處理圖片
cat > process_images.sh << 'EOF'
#!/bin/bash
for img in *.jpg; do
    convert "$img" -resize 800x600 "thumb_$img"
done
EOF
```

### 模式 3：完整工具

```bash
# 人類問：寫一個 HTTP 伺服器健康檢查工具
cat > health-check.sh << 'EOF'
#!/bin/bash
URLS=(
    "https://api.example.com/health"
    "https://web.example.com"
)

for url in "${URLS[@]}"; do
    if curl -sf "$url" &>/dev/null; then
        echo "✓ $url OK"
    else
        echo "✗ $url FAILED"
    fi
done
EOF
```

---

## 19.4 迭代式開發

### 第一輪：生成初版

```bash
# 人類：幫我寫一個備份腳本
```

AI 生成初版，然後人類測試、提出問題：

```bash
# 人類：好，但需要支援 --dry-run 模式
```

### 第二輪：加入功能

```bash
# 人類：再加入錯誤處理和日誌
```

### 第三輪：除錯

```bash
# 人類：執行後報錯 'Permission denied'
# AI：修復這個問題...
```

---

## 19.5 AI 幫你寫 Prompt

有時候你不知道怎麼描述需求，這時可以讓 AI 幫你：

```bash
# 人類：我想批次重新命名圖片，但我不知道怎麼描述
# AI：試試這樣描述：
# "批次處理所有 .jpg 檔案：
#  1. 從 EXIF 讀取拍攝日期
#  2. 重新命名為 YYYY-MM-DD_originalname.jpg
#  3. 建立缩圖 thumb_YYYY-MM-DD_originalname.jpg"
```

---

## 19.6 讓 AI 審查你的腳本

```bash
# 人類：審查這個腳本的安全問題
# （貼上腳本）

# AI 回應：
# 1. 第 15 行：rm 沒有絕對路徑，可能誤刪
# 2. 第 23 行：變數未加引號
# 3. 缺少 set -euo pipefail
```

---

## 19.7 讓 AI 解釋別人的腳本

```bash
# 人類：解釋這個腳本做什麼
# （貼上別人的腳本）

# AI 回應：
# 這是一個 Nginx 日誌分析腳本：
# - 統計 HTTP 狀態碼分布
# - 找出最慢的 20 個請求
# - 識別錯誤模式
```

---

## 19.8 AI 幫你除錯

```bash
# 人類：執行這個命令後報錯
$ ./deploy.sh
# 輸出：/bin/bash^M: bad interpreter: No such file or directory

# AI：這是 Windows 換行符問題。執行：
sed -i 's/\r$//' deploy.sh
```

---

## 19.9 實戰：AI 幫你建立專案

```bash
# 人類：建立一個 Flask 專案，包含：
# - 標準目錄結構
# - Flask 最小範例
# - requirements.txt
# - Dockerfile
# - docker-compose.yml
# - GitHub Actions CI

# AI：
cat > init-flask.sh << 'EOF'
#!/bin/bash
mkdir -p app/{routes,templates,static}
touch app/__init__.py app/routes/__init__.py
# ... 完整生成 ...
EOF
```

---

## 19.10 協作工具推薦

### 終端多工

```bash
# tmux：分割視窗
tmux new -s mysession
# Ctrl+b %  # 垂直分割
# Ctrl+b "  # 水平分割
```

### AI 介面

- 直接在終端呼叫 AI CLI
- 用管道把命令傳給 AI
- 讓 AI 直接修改檔案

### 版本控制

```bash
# 每次重大改動都 commit
git add .
git commit -m "AI: 加入 XXX 功能"
```

---

## 19.11 練習題

1. 描述一個複雜的任務，讓 AI 生成 Shell 命令
2. 用 AI 幫你審查一個現有的腳本
3. 用迭代方式讓 AI 幫你寫一個實用的工具
4. 用 AI 幫你解釋一段你不理解的 Shell 程式碼
