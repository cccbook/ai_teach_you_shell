# 13. Automated Testing

---

## 13.1 Why Use Shell for Testing

- Quick execution of simple verifications
- Test system commands and scripts
- Integration testing in CI/CD
- Regression testing existing scripts

---

## 13.2 Basic Test Framework

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
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
}

test "Addition" "echo \$((1 + 1))" "2"
test "String equals" "echo hello" "hello"

echo ""
echo "Results: $TESTS_PASSED/$TESTS_RUN passed"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 Test File and Directory

```bash
#!/bin/bash

test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ File not found: $file"; return 1; }
}

test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ Directory not found: $dir"; return 1; }
}

test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ File missing: $pattern"; return 1; }
}
```

---

## 13.4 Test Command Output

```bash
#!/bin/bash

test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (exit code: $?)"
        return 1
    fi
}

test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (correctly failed)"
    else
        echo "✗ $name (should fail but succeeded)"
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

## 13.5 CI-Friendly Test Script

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

run_test "Init script exists" "[[ -x scripts/init-project.sh ]]"
run_test "Build script exists" "[[ -f scripts/build.sh ]]"
run_test "Deploy script exists" "[[ -f scripts/deploy.sh ]]"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED tests failed${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.6 Exercises

1. Write a test framework with `test_eq`, `test_contains`, `test_success` functions
2. Write 5 test cases for one of your scripts
3. Create a CI-friendly test script outputting TAP format
4. Test a batch processing script to ensure it handles all files correctly
