# 12. 批处理文件

---

## 12.1 批量重命名

### 简单的扩展名替换

```bash
# 把所有 .txt 改成 .md
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### 批量加前缀

```bash
# 给所有图片加上 thumb_ 前缀
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### 批量去空格

```bash
# 把文件名中的空格换成下划线
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### 批量编号

```bash
# 给文件编号 001, 002, 003...
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 批量处理图片

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "处理：$img"
    
    # 如果有 ImageMagick
    if command -v convert &>/dev/null; then
        # 制作缩略图
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # 制作大图
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ 完成：thumb_$img, large_$img"
    else
        echo "⚠ 需要 ImageMagick：brew install imagemagick"
    fi
done
```

---

## 12.3 批量查找和替换

```bash
#!/bin/bash

# 在所有 .txt 文件中把 "foo" 换成 "bar"
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done

# 或直接用 find + sed
find . -name "*.txt" -exec sed -i 's/foo/bar/g' {} +
```

### 正则表达式批量替换

```bash
# 把所有 "date(YYYY-MM-DD)" 换成实际日期
for f in *.txt; do
    sed -i.bak -E 's/date\(([0-9]{4})-([0-9]{2})-([0-9]{2})\)/\1年\2月\3日/g' "$f"
done
```

---

## 12.4 批量压缩和解压

```bash
#!/bin/bash

# 批量压缩每个文件
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# 批量解压
for f in *.gz; do
    gunzip "$f"
done

# 一次解压所有
gunzip *.gz

# 备份整个目录
tar -czvf backup.tar.gz directory/
```

---

## 12.5 批量下载

```bash
#!/bin/bash
set -euo pipefail

# 从 URL 列表下载
while read -r url; do
    filename=$(basename "$url")
    echo "下载：$url"
    curl -L -o "$filename" "$url"
done < urls.txt

# 或并行下载
cat urls.txt | xargs -P 4 -I {} curl -L -o {/} {}
```

---

## 12.6 批量转换编码

```bash
# 批量转换文件编码
for f in *.txt; do
    iconv -f BIG5 -t UTF8 "$f" -o "utf8_$f"
done

# 批量转换视频编码（需要 ffmpeg）
for f in *.avi; do
    ffmpeg -i "$f" "${f%.avi}.mp4"
done
```

---

## 12.7 批量创建链接

```bash
#!/bin/bash

# 为所有 .py 文件创建软链接到 scripts/
for f in *.py; do
    [[ -f "$f" ]] || continue
    ln -sf "$PWD/$f" "scripts/$f"
done

# 创建目录结构的镜像
for d in */; do
    mkdir -p "backup/$d"
    cp "$d"*.txt "backup/$d"
done
```

---

## 12.8 实战：清理项目

```bash
cat > scripts/clean.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🧹 清理项目..."

# 删除临时文件
rm -f *~
rm -f .*~
rm -f *.bak
rm -f *.tmp

# 删除备份文件
rm -f */*.bak
rm -rf */.*.bak

# 删除编译产出
rm -f *.o *.so *.a *.dylib
rm -rf __pycache__ */__pycache__
rm -rf *.egg-info .pytest_cache .mypy_cache

# 删除日志
rm -f *.log
rm -rf logs/

# 删除空目录
find . -type d -empty -delete 2>/dev/null || true

echo "✅ 清理完成"
echo ""
echo "📊 清理后的目录结构："
du -sh */
EOF

chmod +x scripts/clean.sh
```

---

## 12.9 批量同步

```bash
#!/bin/bash

# rsync 批量同步
rsync -avz --delete ./source/ user@server:/backup/

# 排除特定文件
rsync -avz --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    ./source/ user@server:/backup/
```

---

## 12.10 速查表

| 任务 | 命令 |
|------|------|
| 改扩展名 | `mv "$f" "${f%.old}.new"` |
| 加前缀 | `mv "$f" "prefix_$f"` |
| 去空格 | `mv "$f" "${f// /_}"` |
| 批量号码 | `mv "$f" "$(printf '%03d' $i)"` |
| 批量替换 | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| 批量压缩 | `for f in *.txt; do gzip "$f"; done` |
| 批量下载 | `while read url; do curl -LO "$url"; done < urls.txt` |
| 批量同步 | `rsync -avz --delete ./source/ ./target/` |

---

## 12.11 练习题

1. 批量将 10 个文件的 `.txt` 扩展名改成 `.md`
2. 批量给所有图片加上 `thumb_` 前缀并制作缩略图
3. 批量将所有 `.html` 文件中的 `old-site.com` 换成 `new-site.com`
4. 创建一个清理脚本，删除所有 `__pycache__`、`.pyc` 和 `.log` 文件
