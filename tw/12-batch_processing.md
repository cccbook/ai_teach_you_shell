# 12. 批次處理檔案

---

## 12.1 批次重新命名

### 簡單的副檔名替換

```bash
# 把所有 .txt 改成 .md
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### 批次加前綴

```bash
# 給所有圖片加上 thumb_ 前綴
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### 批次去空格

```bash
# 把檔名中的空格換成底線
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### 批次編號

```bash
# 給檔案編號 001, 002, 003...
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 批次處理圖片

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "處理：$img"
    
    # 如果有 ImageMagick
    if command -v convert &>/dev/null; then
        # 製作縮圖
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # 製作大圖
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ 完成：thumb_$img, large_$img"
    else
        echo "⚠ 需要 ImageMagick：brew install imagemagick"
    fi
done
```

---

## 12.3 批次尋找和取代

```bash
#!/bin/bash

# 在所有 .txt 檔案中把 "foo" 換成 "bar"
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done

# 或直接用 find + sed
find . -name "*.txt" -exec sed -i 's/foo/bar/g' {} +
```

### 正規表達式批次取代

```bash
# 把所有 "date(YYYY-MM-DD)" 換成實際日期
for f in *.txt; do
    sed -i.bak -E 's/date\(([0-9]{4})-([0-9]{2})-([0-9]{2})\)/\1年\2月\3日/g' "$f"
done
```

---

## 12.4 批次壓縮和解壓

```bash
#!/bin/bash

# 批次壓縮每個檔案
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# 批次解壓
for f in *.gz; do
    gunzip "$f"
done

# 一次解壓所有
gunzip *.gz

# 備份整個目錄
tar -czvf backup.tar.gz directory/
```

---

## 12.5 批次下載

```bash
#!/bin/bash
set -euo pipefail

# 從 URL 列表下載
while read -r url; do
    filename=$(basename "$url")
    echo "下載：$url"
    curl -L -o "$filename" "$url"
done < urls.txt

# 或並行下載
cat urls.txt | xargs -P 4 -I {} curl -L -o {/} {}
```

---

## 12.6 批次轉換編碼

```bash
# 批次轉換檔案編碼
for f in *.txt; do
    iconv -f BIG5 -t UTF8 "$f" -o "utf8_$f"
done

# 批次轉換影片編碼（需要 ffmpeg）
for f in *.avi; do
    ffmpeg -i "$f" "${f%.avi}.mp4"
done
```

---

## 12.7 批次建立連結

```bash
#!/bin/bash

# 為所有 .py 檔案建立軟連結到 scripts/
for f in *.py; do
    [[ -f "$f" ]] || continue
    ln -sf "$PWD/$f" "scripts/$f"
done

# 建立目錄結構的鏡像
for d in */; do
    mkdir -p "backup/$d"
    cp "$d"*.txt "backup/$d"
done
```

---

## 12.8 實戰：清理專案

```bash
cat > scripts/clean.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🧹 清理專案..."

# 刪除暫存檔
rm -f *~
rm -f .*~
rm -f *.bak
rm -f *.tmp

# 刪除備份檔
rm -f */*.bak
rm -rf */.*.bak

# 刪除編譯產出
rm -f *.o *.so *.a *.dylib
rm -rf __pycache__ */__pycache__
rm -rf *.egg-info .pytest_cache .mypy_cache

# 刪除日誌
rm -f *.log
rm -rf logs/

# 刪除空目錄
find . -type d -empty -delete 2>/dev/null || true

echo "✅ 清理完成"
echo ""
echo "📊 清理後的目錄結構："
du -sh */
EOF

chmod +x scripts/clean.sh
```

---

## 12.9 批次同步

```bash
#!/bin/bash

# rsync 批次同步
rsync -avz --delete ./source/ user@server:/backup/

# 排除特定檔案
rsync -avz --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    ./source/ user@server:/backup/
```

---

## 12.10 速查表

| 任務 | 命令 |
|------|------|
| 改副檔名 | `mv "$f" "${f%.old}.new"` |
| 加前綴 | `mv "$f" "prefix_$f"` |
| 去空格 | `mv "$f" "${f// /_}"` |
| 批次號碼 | `mv "$f" "$(printf '%03d' $i)"` |
| 批次取代 | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| 批次壓縮 | `for f in *.txt; do gzip "$f"; done` |
| 批次下載 | `while read url; do curl -LO "$url"; done < urls.txt` |
| 批次同步 | `rsync -avz --delete ./source/ ./target/` |

---

## 12.11 練習題

1. 批次將 10 個檔案的 `.txt` 副檔名改成 `.md`
2. 批次給所有圖片加上 `thumb_` 前綴並製作縮圖
3. 批次將所有 `.html` 檔案中的 `old-site.com` 換成 `new-site.com`
4. 建立一個清理腳本，刪除所有 `__pycache__`、`.pyc` 和 `.log` 檔案
