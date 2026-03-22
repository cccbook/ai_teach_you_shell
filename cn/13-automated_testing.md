# 13. 自动化测试

---

## 13.1 为什么要用 Shell 做测试

- 快速执行简单的验证
- 测试系统命令和脚本
- CI/CD 流程中的集成测试
- 回归测试现有脚本

---

## 13.2 基本测试框架

```bash
#!/bin/bash
set -euo pipefail

# 测试计数
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
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
        echo "  预期：$expected"
        echo "  实际：$actual"
        ((TESTS_FAILED++))
    fi
}

# 执行测试
test "加法" "echo \$((1 + 1))" "2"
test "字符串相等" "echo hello" "hello"
test "数组长度" "echo \${#arr[@]}" "3"

# 报告结果
echo ""
echo "测试结果：$TESTS_PASSED/$TESTS_RUN 通过"
[[ $TESTS_FAILED -eq 0 ]] || exit 1
```

---

## 13.3 测试文件和目录

```bash
#!/bin/bash
set -euo pipefail

# 测试文件存在
test_file_exists() {
    local file=$1
    [[ -f "$file" ]] || { echo "✗ 文件不存在：$file"; return 1; }
}

# 测试目录存在
test_dir_exists() {
    local dir=$1
    [[ -d "$dir" ]] || { echo "✗ 目录不存在：$dir"; return 1; }
}

# 测试文件内容包含
test_file_contains() {
    local file=$1
    local pattern=$2
    grep -q "$pattern" "$file" || { echo "✗ 文件不包含：$pattern"; return 1; }
}

# 测试文件行数
test_file_lines() {
    local file=$1
    local expected=$2
    local actual=$(wc -l < "$file")
    [[ "$actual" -eq "$expected" ]] || { echo "✗ 行数错误：$actual vs $expected"; return 1; }
}
```

---

## 13.4 测试命令输出

```bash
#!/bin/bash

# 测试命令成功执行
test_success() {
    local name=$1
    shift
    if "$@"; then
        echo "✓ $name"
    else
        echo "✗ $name (退出码: $?)"
        return 1
    fi
}

# 测试命令失败
test_failure() {
    local name=$1
    shift
    if ! "$@" 2>/dev/null; then
        echo "✓ $name (正确失败)"
    else
        echo "✗ $name (应该失败但成功了)"
        return 1
    fi
}

# 测试输出包含
test_output() {
    local name=$1
    local expected=$2
    shift 2
    
    local output=$("$@" 2>/dev/null)
    if [[ "$output" == *"$expected"* ]]; then
        echo "✓ $name"
    else
        echo "✗ $name"
        echo "  输出不包含：$expected"
        return 1
    fi
}

# 使用
test_success "mkdir" mkdir -p testdir
test_success "ls" ls -la
test_failure "rm 不存在文件" rm /nonexistent
test_output "echo hello" "hello" echo hello
```

---

## 13.5 实战：测试一个项目初始化脚本

```bash
cat > test-init.sh << 'EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="testproject"

# 清理
rm -rf "$PROJECT_NAME"

# 执行初始化
"$SCRIPT_DIR/init-project.sh" "$PROJECT_NAME"

# 验证目录结构
test -d "$PROJECT_NAME" || { echo "✗ 项目目录未建立"; exit 1; }
test -d "$PROJECT_NAME/src" || { echo "✗ src 目录未建立"; exit 1; }
test -d "$PROJECT_NAME/tests" || { echo "✗ tests 目录未建立"; exit 1; }
test -d "$PROJECT_NAME/docs" || { echo "✗ docs 目录未建立"; exit 1; }

# 验证文件
test -f "$PROJECT_NAME/README.md" || { echo "✗ README 未建立"; exit 1; }
test -f "$PROJECT_NAME/src/__init__.py" || { echo "✗ __init__.py 未建立"; exit 1; }

# 清理测试数据
rm -rf "$PROJECT_NAME"

echo "✅ 所有测试通过"
EOF

chmod +x test-init.sh
```

---

## 13.6 测试覆盖率

```bash
#!/bin/bash

# 计算测试覆盖率
calculate_coverage() {
    local total=$1
    local covered=$2
    
    local percent=$((covered * 100 / total))
    echo "覆盖率：${percent}%"
    
    if [[ $percent -lt 50 ]]; then
        echo "⚠️ 覆盖率过低"
        return 1
    fi
}

# 测试每个函数是否被调用
TRACE_FILE="/tmp/trace.log"
> "$TRACE_FILE"

test_with_trace() {
    local name=$1
    local func=$2
    
    # 执行并追踪
    "$@" 2>&1 | tee -a "$TRACE_FILE"
    
    if grep -q "$func" "$TRACE_FILE"; then
        echo "✓ $name (函数 $func 被调用)"
    else
        echo "✗ $name (函数 $func 未被调用)"
    fi
}
```

---

## 13.7 持续测试

```bash
cat > scripts/test.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "🔬 执行测试..."

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAILED=0

run_test() {
    local name=$1
    local cmd=$2
    
    echo -n "测试：$name ... "
    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
    fi
}

# 测试初始化脚本
run_test "初始化脚本存在" "[[ -x scripts/init-project.sh ]]"
run_test "初始化脚本执行成功" "scripts/init-project.sh testrun"

# 测试构建脚本
run_test "构建脚本存在" "[[ -f scripts/build.sh ]]"

# 测试部署脚本
run_test "部署脚本存在" "[[ -f scripts/deploy.sh ]]"

# 清理测试数据
rm -rf testrun

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ 所有测试通过${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED 个测试失败${NC}"
    exit 1
fi
EOF

chmod +x scripts/test.sh
```

---

## 13.8 练习题

1. 写一个测试框架，包含 `test_eq`、`test_contains`、`test_success` 函数
2. 为你的一个脚本写 5 个测试案例
3. 创建一个 CI 友好的测试脚本，输出 TAP 格式
4. 测试一个批处理脚本，确保它正确处理所有文件
