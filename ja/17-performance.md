# 17. パフォーマンス最適化

---

## 17.1 Shell パフォーマンスが重要な理由

Shellスクリプトは多くの場合、以下に使用されます：
- 大量ファイルのバッチ処理
- 自動化タスク
- CI/CDパイプライン

遅いスクリプトはプロセス全体を数時間遅らせる可能性があります。Shellスクリプトの最適化は効率性を大きく向上させます。

---

## 17.2 外部コマンドを避ける

```bash
# 遅い：外部コマンド
for f in *.txt; do
    name=$(basename "$f")
    echo "$name"
done

# 速い：シェル組み込みコマンド
for f in *.txt; do
    echo "${f##*/}"
done
```

### 組み込みコマンド vs 外部コマンド

| 遅い | 速い | 説明 |
|------|------|------|
| `$(cat file)` | `$(<file)` | 直接読み込み |
| `$(basename $f)` | `${f##*/}` | パラメータ展開 |
| `$(expr $a + $b)` | `$((a + b))` | 四則演算 |
| `$(echo $var)` | `"$var"` | 直接使用 |

---

## 17.3 `for` の代わりに `while read` を使用

```bash
# 遅い：for + コマンド置換
for line in $(cat file.txt); do
    process "$line"
done

# 速い：while read
while IFS= read -r line; do
    process "$line"
done < file.txt
```

---

## 17.4 並列処理

### `&` と `wait` を使用

```bash
#!/bin/bash

task1 &
task2 &
task3 &

wait

echo "全タスク完了"
```

### `xargs -P` を使用

```bash
# 逐次処理
cat files.txt | xargs -I {} process {}

# 並列処理（4並列）
cat files.txt | xargs -P 4 -I {} process {}
```

---

## 17.5 サブシェルを避ける

```bash
# 遅い：ループごとにサブシェル
for f in *.txt; do
    content=$(cat "$f")
    echo "$content" | wc -l
done

# 速い：単一のサブシェル
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 クイックリファレンス

| 最適化 | 遅い | 速い |
|--------|------|------|
| ファイル読み込み | `$(cat file)` | `$(<file)` または `while read` |
| パス | `$(basename $f)` | `${f##*/}` |
| 計算 | `$(expr $a + $b)` | `$((a + b))` |
| 並列処理 | 逐次処理 | `&` + `wait` または `xargs -P` |

---

## 17.7 練習問題

1. `time` を使用して1000ファイル処理するループの実行時間を測定する
2. 逐次処理スクリプトを並列処理に変換する
3. `$(cat file)` と `while read` のパフォーマンスを比較する
4. `xargs -P` を使用してバッチ画像処理高速化する
