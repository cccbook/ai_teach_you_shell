# 13. Kiểm Thử Tự Động

---

## 13.1 Tại Sao Dùng Shell Để Kiểm Thử

- Thực thi nhanh các xác minh đơn giản
- Kiểm thử lệnh hệ thống và script
- Kiểm thử tích hợp trong CI/CD
- Kiểm thử hồi quy các script hiện có

---

## 13.2 Framework Test Cơ Bản

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
        echo "  Mong đợi: $expected"
        echo "  Thực tế: $actual"
        ((TESTS_FAILED++))
    fi
}

test "Phép cộng" "echo \$((1 + 1))" "2"
test "Chuỗi bằng nhau" "echo hello" "hello"

echo ""
echo "Kết quả: $TESTS_PASSED/$TESTS_RUN đã đạt"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 Test File và Thư Mục

```bash
#!/bin/bash

test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ Không tìm thấy file: $file"; return 1; }
}

test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ Không tìm thấy thư mục: $dir"; return 1; }
}

test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ File thiếu: $pattern"; return 1; }
}
```

---

## 13.4 Test Đầu Ra Lệnh

```bash
#!/bin/bash

test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (mã thoát: $?)"
        return 1
    fi
}

test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (thất bại đúng)"
    else
        echo "✗ $name (phải thất bại nhưng thành công)"
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

## 13.5 Script Test Thân Thiện CI

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
    
    echo -n "Test: $name ... "
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
    fi
}

run_test "Script init tồn tại" "[[ -x scripts/init-project.sh ]]"
run_test "Script build tồn tại" "[[ -f scripts/build.sh ]]"
run_test "Script deploy tồn tại" "[[ -f scripts/deploy.sh ]]"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ Tất cả test đã đạt${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED test thất bại${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.6 Bài Tập

1. Viết framework test với các hàm `test_eq`, `test_contains`, `test_success`
2. Viết 5 test case cho một trong các script của bạn
3. Tạo script test thân thiện CI xuất định dạng TAP
4. Test script xử lý hàng loạt để đảm bảo xử lý đúng tất cả file
