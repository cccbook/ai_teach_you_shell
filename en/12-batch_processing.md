# 12. Batch File Processing

---

## 12.1 Batch Renaming

### Simple Extension Replacement

```bash
# Change all .txt to .md
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### Add Prefix

```bash
# Add thumb_ prefix to all images
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### Remove Spaces

```bash
# Replace spaces in filenames with underscores
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### Add Numbers

```bash
# Number files 001, 002, 003...
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 Batch Image Processing

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "Processing: $img"
    
    if command -v convert &>/dev/null; then
        # Create thumbnail
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # Create large version
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ Done: thumb_$img, large_$img"
    fi
done
```

---

## 12.3 Batch Find and Replace

```bash
#!/bin/bash

# Replace "foo" with "bar" in all .txt files
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done
```

---

## 12.4 Batch Compression

```bash
#!/bin/bash

# Compress each file
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# Decompress all
gunzip *.gz
```

---

## 12.5 Batch Download

```bash
#!/bin/bash
set -euo pipefail

while read -r url; do
    filename=$(basename "$url")
    echo "Downloading: $url"
    curl -L -o "$filename" "$url"
done < urls.txt
```

---

## 12.6 Quick Reference

| Task | Command |
|------|---------|
| Change extension | `mv "$f" "${f%.old}.new"` |
| Add prefix | `mv "$f" "prefix_$f"` |
| Remove spaces | `mv "$f" "${f// /_}"` |
| Add numbers | `mv "$f" "$(printf '%03d' $i)"` |
| Batch replace | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| Batch compress | `for f in *.txt; do gzip "$f"; done` |
| Batch download | `while read url; do curl -LO "$url"; done < urls.txt` |

---

## 12.7 Exercises

1. Batch rename 10 files from `.txt` to `.md`
2. Add `thumb_` prefix to all images and create thumbnails
3. Replace `old-site.com` with `new-site.com` in all `.html` files
4. Create a cleanup script that deletes all `__pycache__`, `.pyc`, and `.log` files
