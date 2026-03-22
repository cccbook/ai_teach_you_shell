# 20. Shell と他の言語の橋渡し

---

## 20.1 どのようなタスクにShellを使用すべきか

Shellが得意的タスク：
- ファイル操作
- システム管理
- 自動化ワークフロー
- パイプライン構築
- クイックプロトタイプ

他の言語がより合适的タスク：
- 複雑なデータ処理（Python、AWK）
- Webプログラミング（JavaScript、Go）
- 数値計算（Python、R、Julia）
- システムプログラミング（C、Rust）

---

## 20.2 Shell から Python を呼び出す

### シンプルな呼び出し

```bash
#!/bin/bash

# Pythonスクリプトを呼び出す
python3 process_data.py input.csv

# 引数を渡す
python3 script.py arg1 arg2

# 出力を取得
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### Shell に Python を埋め込む

```bash
#!/bin/bash

python3 << 'PYEOF'
import csv

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['amount']) for row in reader)
    print(f"Total: {total}")
PYEOF
```

---

## 20.3 Python から Shell を呼び出す

### `subprocess` を使用

```python
import subprocess

# シンプルなコマンドを実行
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# 複雑なコマンドを実行
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
```

---

## 20.4 Shell から JavaScript/Node.js を呼び出す

```bash
#!/bin/bash

# Node.jsコマンドを実行
node -e "console.log('hello from node')"

# Node.jsスクリプトを実行
node process-json.js data.json
```

---

## 20.5 橋渡しツール

### `jq`：JSON処理

```bash
# JSONをパース
echo '{"name": "Alice", "age": 25}' | jq '.name'

# ファイルから読み込み
jq '.users[] | select(.age > 18)' data.json
```

### `yq`：YAML処理

```bash
# YAMLをパース
yq '.database.host' config.yaml

# YAMLをJSONに変換
yq -o=json config.yaml
```

---

## 20.6 クイックリファレンス

| 橋渡し | 構文 |
|--------|------|
| Shell→Python | `python3 script.py` または `python3 << PYEOF` |
| Python→Shell | `subprocess.run(['ls'])` |
| Shell→Node | `node script.js` または `node << JSEOF` |
| JSON解析 | `jq '.key' file.json` |
| YAML解析 | `yq '.key' file.yaml` |
| オーケストレーション | `make` |

---

## 20.7 練習問題

1. Shell から Python を呼び出してCSVファイルを処理する
2. Python の `subprocess` を使用してShellコマンドを実行する
3. `jq` を使用してJSON APIレスポンスを解析する
4. Makefile を使用してShell、Python、Node.jsタスクをオーケストレートする
