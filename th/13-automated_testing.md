# 13. การทดสอบอัตโนมัติ

---

## 13.1 ทำไมต้องใช้ Shell สำหรับการทดสอบ

- การตรวจสอบอย่างง่ายทำงานได้เร็ว
- ทดสอบคำสั่งระบบและสคริปต์
- ทดสอบการรวมใน CI/CD
- ทดสอบการถดถอยสคริปต์ที่มีอยู่

---

## 13.2 เฟรมเวิร์กการทดสอบพื้นฐาน

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
        echo "  คาดหวัง: $expected"
        echo "  จริง: $actual"
        ((TESTS_FAILED++))
    fi
}

test "การบวก" "echo \$((1 + 1))" "2"
test "สตริงเท่ากัน" "echo hello" "hello"

echo ""
echo "ผลลัพธ์: $TESTS_PASSED/$TESTS_RUN ผ่าน"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 ทดสอบไฟล์และไดเรกทอรี

```bash
#!/bin/bash

test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ ไม่พบไฟล์: $file"; return 1; }
}

test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ ไม่พบไดเรกทอรี: $dir"; return 1; }
}

test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ ไฟล์ไม่มี: $pattern"; return 1; }
}
```

---

## 13.4 ทดสอบผลลัพธ์คำสั่ง

```bash
#!/bin/bash

test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (รหัสออก: $?)"
        return 1
    fi
}

test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (ล้มเหลวอย่างถูกต้อง)"
    else
        echo "✗ $name (ควรล้มเหลวแต่สำเร็จ)"
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

## 13.5 สคริปต์ทดสอบสำหรับ CI

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
    
    echo -n "ทดสอบ: $name ... "
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
    fi
}

run_test "มีสคริปต์ init" "[[ -x scripts/init-project.sh ]]"
run_test "มีสคริปต์ build" "[[ -f scripts/build.sh ]]"
run_test "มีสคริปต์ deploy" "[[ -f scripts/deploy.sh ]]"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ ทดสอบทั้งหมดผ่าน${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED การทดสอบล้มเหลว${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.6 แบบฝึกหัด

1. เขียนเฟรมเวิร์กการทดสอบที่มีฟังก์ชัน `test_eq`, `test_contains`, `test_success`
2. เขียน 5 กรณีทดสอบสำหรับสคริปต์หนึ่งของคุณ
3. สร้างสคริปต์ทดสอบสำหรับ CI ที่แสดงผลในรูปแบบ TAP
4. ทดสอบสคริปต์ประมวลผลเป็นชุดเพื่อให้แน่ใจว่าจัดการไฟล์ทั้งหมดถูกต้อง
