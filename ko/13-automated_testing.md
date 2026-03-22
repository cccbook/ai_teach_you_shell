# 13. 자동화 테스트

---

## 13.1 왜 셸로 테스트하는가

- 간단한 검증의 빠른 실행
- 시스템 명령어 및 스크립트 테스트
- CI/CD의 통합 테스트
- 기존 스크립트의 회귀 테스트

---

## 13.2 기본 테스트 프레임워크

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
        echo "  예상: $expected"
        echo "  실제: $actual"
        ((TESTS_FAILED++))
    fi
}

test "덧셈" "echo \$((1 + 1))" "2"
test "문자열 같음" "echo hello" "hello"

echo ""
echo "결과: $TESTS_PASSED/$TESTS_RUN 통과"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 파일 및 디렉토리 테스트

```bash
#!/bin/bash

test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ 파일을 찾을 수 없음: $file"; return 1; }
}

test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ 디렉토리를 찾을 수 없음: $dir"; return 1; }
}

test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ 파일에 누락됨: $pattern"; return 1; }
}
```

---

## 13.4 명령어 출력 테스트

```bash
#!/bin/bash

test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (종료 코드: $?)"
        return 1
    fi
}

test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (올바르게 실패함)"
    else
        echo "✗ $name (실패해야 하는데 성공함)"
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

## 13.5 CI 친화적 테스트 스크립트

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
    
    echo -n "테스트: $name ... "
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
    fi
}

run_test "초기화 스크립트 존재" "[[ -x scripts/init-project.sh ]]"
run_test "빌드 스크립트 존재" "[[ -f scripts/build.sh ]]"
run_test "배포 스크립트 존재" "[[ -f scripts/deploy.sh ]]"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ 모든 테스트 통과${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED개의 테스트 실패${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.6 연습문제

1. `test_eq`, `test_contains`, `test_success` 함수가 있는 테스트 프레임워크를 작성하세요
2. 자신의 스크립트 중 하나에 대해 5개의 테스트 케이스를 작성하세요
3. TAP 형식으로 출력하는 CI 친화적 테스트 스크립트를 만드세요
4. 모든 파일을 올바르게 처리하는지 확인하기 위해 일괄 처리 스크립트를 테스트하세요
