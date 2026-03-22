# 12. 一括ファイル処理

---

## 12.1 一括リネーム

### シンプルな拡張子変更

```bash
# すべての .txt を .md に変更
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### プレフィックスを追加

```bash
# すべての画像に thumb_ プレフィックスを追加
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### スペースを削除

```bash
# ファイル名のスペースをアンダースコアに置き換える
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### 番号を追加

```bash
# ファイルに 001、002、003... と番号を付ける
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 一括画像処理

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "処理中: $img"
    
    if command -v convert &>/dev/null; then
        # サムネイルを作成
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # 大きいバージョンを作成
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ 完了: thumb_$img, large_$img"
    fi
done
```

---

## 12.3 一括検索と置換

```bash
#!/bin/bash

# すべての .txt ファイルで "foo" を "bar" に置換
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done
```

---

## 12.4 一括圧縮

```bash
#!/bin/bash

# 各ファイルを圧縮
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# すべて解凍
gunzip *.gz
```

---

## 12.5 一括ダウンロード

```bash
#!/bin/bash
set -euo pipefail

while read -r url; do
    filename=$(basename "$url")
    echo "ダウンロード中: $url"
    curl -L -o "$filename" "$url"
done < urls.txt
```

---

## 12.6 クイックリファレンス

| タスク | コマンド |
|------|---------|
| 拡張子を変更 | `mv "$f" "${f%.old}.new"` |
| プレフィックスを追加 | `mv "$f" "prefix_$f"` |
| スペースを削除 | `mv "$f" "${f// /_}"` |
| 番号を追加 | `mv "$f" "$(printf '%03d' $i)"` |
| 一括置換 | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| 一括圧縮 | `for f in *.txt; do gzip "$f"; done` |
| 一括ダウンロード | `while read url; do curl -LO "$url"; done < urls.txt` |

---

## 12.7 演習問題

1. 10個のファイルを `.txt` から `.md` へ一括リネームする
2. すべての画像に `thumb_` プレフィックスを追加し、サムネイルを作成する
3. すべての `.html` ファイルで `old-site.com` を `new-site.com` に置き換える
4. `__pycache__`、`.pyc`、`.log` ファイルをすべて削除するクリーンアップスクリプトを作成する
