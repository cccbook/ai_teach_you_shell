# 11. ログと出力

---

## 11.1 ログが重要な理由

ログがない場合:
- スクリプトがどこにいるかわからない
- なぜ失敗したかわからない
- 成功時に何をしたかわからない

ログがある場合:
- 進捗を追跡できる
- 失敗をデバッグするための十分な情報がある
- 実行履歴を監査できる

---

## 11.2 基本的なログレベル

```bash
#!/bin/bash

DEBUG=0
INFO=1
WARN=2
ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$INFO}

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ $level -ge $LOG_LEVEL ]]; then
        echo "[$timestamp] $message"
    fi
}

log $DEBUG "これはデバッグです"
log $INFO "これは情報です"
log $WARN "これは警告です"
log $ERROR "これはエラーです"
```

---

## 11.3 カラー出力

```bash
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # カラーなし

log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

log_info "インストール完了"
log_warn "デフォルトを使用"
log_error "接続に失敗しました"
```

---

## 11.4 ファイルへの出力

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "アプリケーションを開始しました"
```

---

## 11.5 `tee`: 画面とファイルに同時出力

```bash
# 表示と保存を同時に行う
echo "こんにちは" | tee output.txt

# 追加モード
echo "世界" | tee -a output.txt

# stderr もキャプチャ
./script.sh 2>&1 | tee output.log
```

---

## 11.6 進捗インジケーター

### シンプルなドット

```bash
echo -n "処理中"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " 完了"
```

### 進捗バー

```bash
draw_progress() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local chars=$((width * current / total))
    
    printf "\r[%s%s] %3d%%" \
        "$(printf '%*s' $chars | tr ' ' '=')" \
        "$(printf '%*s' $((width - chars)) | tr ' ' '-')" \
        "$percent"
    
    [[ $current -eq $total ]] && echo
}
```

---

## 11.7 `2>&1` の説明

```bash
# 1 = stdout、2 = stderr

# stderr を stdout にリダイレクト
command 2>&1

# stdout をファイルに、stderr を画面に表示
command > output.txt

# 両方をファイルにリダイレクト
command > output.txt 2>&1

# 両方を /dev/null にリダイレクト（非表示）
command > /dev/null 2>&1
```

---

## 11.8 クイックリファレンス

| 構文 | 説明 |
|--------|-------------|
| `echo "テキスト"` | 基本的な出力 |
| `echo -e "\033[31m"` | カラー出力 |
| `2>&1` | stderr を stdout にリダイレクト |
| `> file` | ファイルを上書き |
| `>> file` | ファイルに追加 |
| `tee file` | 出力して保存 |
| `tee -a file` | 追加モード |
| `/dev/null` | 出力を破棄 |

---

## 11.9 演習問題

1. INFO、WARN、ERROR メッセージを異なる色で表示するスクリプトを書く
2. `tee` を使用して出力を画面に表示しながらログファイルに保存する
3. 進捗バー付きのファイル処理スクリプトを作成する
4. ファイル出力とログレベルをサポートするログユーティリティライブラリを構築する
