# 13. 自動テスト

---

## 13.1 なぜシェルでテストするのか

- シンプルな検証をすぐに実行
- システムコマンドやスクリプトをテスト
- CI/CD での統合テスト
- 既存スクリプトの回帰テスト

---

## 13.2 基本的なテストフレームワーク

```bash
#!/bin/bash
set -euo pipefail

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test() {
    local name=$1
    local command=$2
    local expected=$3
    
    ((TESTS_RUN++))
    
    local actual
    actual=$(eval "$command" 2>/dev/null)
    
    if [[ "$actual" == "$expected" ]]; then
        echo "✓ $name"
        ((TESTS_PASSED++))
    else
        echo "✗ $name"
        echo "  期待値: $expected"
        echo "  実際: $actual"
        ((TESTS_FAILED++))
    fi
}

test "足し算" "echo \$((1 + 1))" "2"
test "文字列の一致" "echo hello" "hello"

echo ""
echo "結果: $TESTS_PASSED/$TESTS_RUN テスト合格"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 ファイルとディレクトリのテスト

```bash
#!/bin/bash

test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ ファイルが見つかりません: $file"; return 1; }
}

test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ ディレクトリが見つかりません: $dir"; return 1; }
}

test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ ファイルに欠缺: $pattern"; return 1; }
}
```

---

## 13.4 コマンド出力のテスト

```bash
#!/bin/bash

test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (終了コード: $?)"
        return 1
    fi
}

test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (正しく失敗)"
    else
        echo "✗ $name (失敗すべきなのに成功)"
        return 1
    fi
}

test_output() {
    local name=$1
    local expected=$2
    shift 2
    
    local output=$("$@" 2>/dev/null)
    if [[ "$output" == *"$expected"* ]]; then
        echo "✓ $name"
    else
        echo "✗ $name"
        return 1
    fi
}
```

---

## 13.5 CI 友好的なテストスクリプト

```bash
cat > scripts/test.sh << 'EOF'
#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAILED=0

run_test() {
    local name=$1
    local cmd=$2
    
    echo -n "テスト: $name ... "
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
    fi
}

run_test "初期化スクリプトが存在" "[[ -x scripts/init-project.sh ]]"
run_test "ビルドスクリプトが存在" "[[ -f scripts/build.sh ]]"
run_test "デプロイスクリプトが存在" "[[ -f scripts/deploy.sh ]]"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ すべてのテストが合格${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED 件のテストが失敗${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.6 演習問題

1. `test_eq`、`test_contains`、`test_success` 関数を持つテストフレームワークを書く
2. スクリプトのテストケースを5つ書く
3. TAP フォーマットで出力する CI 友好的なテストスクリプトを作成する
4. 一括処理スクリプトがすべてのファイルを正しく処理することを確認するテストを書く
