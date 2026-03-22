# 9. 错误处理

---

## 9.1 为什么错误处理重要

没有错误处理的脚本：
- 一个命令失败后，继续执行错误的操作
- 可能删除错误的文件
- 可能覆盖重要的数据
- 可能让系统进入不一致的状态

有错误处理的脚本：
- 遇到错误立即停止
- 提供有意义的错误消息
- 可以在退出前做清理工作

---

## 9.2 退出码（Exit Code）

每一个命令执行后，都会返回一个退出码：

- `0`：成功
- `非 0`：失败

```bash
# 查看上一个命令的退出码
ls /tmp
echo $?  # 输出：0（如果成功）

ls /nonexistent
echo $?  # 输出：2（如果失败，数字因命令而异）
```

### 在条件判断中使用

```bash
# 如果成功才执行
if ls /tmp &>/dev/null; then
    echo "目录存在"
fi

# 或用 && 和 ||
ls /tmp && echo "成功" || echo "失败"
```

---

## 9.3 `set -e`：遇到错误就停止

```bash
#!/bin/bash
set -e

mkdir -p backup
cp important.txt backup/  # 如果这个失败，脚本就会停止
rm important.txt          # 不会执行到这里
```

### 何时使用

几乎所有脚本都应该用 `set -e`：
- 初始化脚本
- 部署脚本
- 自动化测试脚本

### 何时不使用

- 允许某个步骤失败的脚本
- 需要尝试多个选项的脚本

```bash
# 错误示范：set -e 下，这会导致脚本提前退出
#!/bin/bash
set -e

# 尝试多种可能的工具
which rg || which grep  # 如果都找不到，脚本就退出
```

---

## 9.4 `set -u`：使用未定义变量时报错

```bash
#!/bin/bash
set -u

echo $undefined_var
# 输出：bash: undefined_var: unbound variable
```

### 组合使用

```bash
#!/bin/bash
set -euo pipefail

# -e：遇到错误停止
# -u：使用未定义变量时报错
# -o pipefail：管道中任何一个命令失败就失败
```

**这是 AI 写脚本时的标准开头！**

---

## 9.5 `trap`：优雅地处理错误

### 基本用法

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "清理中..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# 主程序
echo "开始处理..."
```

### 捕获错误

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    echo "❌ 脚本在第 $1 行失败，退出码：$exit_code"
    exit $exit_code
}

trap 'error_handler $LINENO' ERR

# 主程序
echo "开始..."
false  # 这会失败
echo "这行不会执行"
```

### 常见的 trap 用途

```bash
# Ctrl+C 中断时清理
trap 'echo "中断，正在清理..."; rm -f /tmp/lock; exit 130' INT TERM

# 当脚本被 kill 时清理
trap 'cleanup' EXIT

# 调试模式（见下一章）
trap 'echo "执行: $BASH_COMMAND"' DEBUG
```

---

## 9.6 自定义错误函数

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "❌ $@" >&2
    exit 1
}

warn() {
    echo "⚠️ $@"
}

need_command() {
    command -v "$1" &>/dev/null || die "需要命令：$1"
}

need_file() {
    [[ -f "$1" ]] || die "需要文件：$1"
}

need_dir() {
    [[ -d "$1" ]] || die "需要目录：$1"
}

# 使用
need_command git
need_file config.yaml
need_dir data/

echo "所有检查通过"
```

---

## 9.7 实战：安全的部署脚本

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $@"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

# 清理函数
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "部署失败，正在回滚..."
        # 回滚逻辑
        ssh "$DEPLOY_HOST" "cp -r $DEPLOY_PATH.backup/* $DEPLOY_PATH/"
    fi
    rm -f /tmp/deploy.lock
    exit $exit_code
}
trap cleanup EXIT

# 检查参数
if [[ $# -lt 2 ]]; then
    error "用法: $0 <host> <path>"
    exit 1
fi

DEPLOY_HOST="$1"
DEPLOY_PATH="$2"

# 检查必要工具
for cmd in ssh rsync; do
    command -v "$cmd" &>/dev/null || die "需要命令：$cmd"
done

# 检查是否有其他部署在执行
if ssh "$DEPLOY_HOST" "test -f $DEPLOY_PATH/.deploying" 2>/dev/null; then
    die "主机 $DEPLOY_HOST 正在部署中"
fi

log "开始部署到 $DEPLOY_HOST:$DEPLOY_PATH"

# 建立备份
ssh "$DEPLOY_HOST" "cp -r $DEPLOY_PATH $DEPLOY_PATH.backup.$(date +%s)"
log "备份完成"

# 建立部署标记
ssh "$DEPLOY_HOST" "touch $DEPLOY_PATH/.deploying"

# 上传新版本
rsync -avz --delete ./dist/ "$DEPLOY_HOST:$DEPLOY_PATH/"

# 移除部署标记
ssh "$DEPLOY_HOST" "rm $DEPLOY_PATH/.deploying"

# 重启服务
ssh "$DEPLOY_HOST" "systemctl restart myapp"

log "部署完成！"
EOF

chmod +x deploy.sh
```

---

## 9.8 验证函数

```bash
#!/bin/bash
set -euo pipefail

# 验证 email 格式
is_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# 验证数字范围
is_between() {
    [[ $1 =~ ^[0-9]+$ ]] && [[ $1 -ge $2 ]] && [[ $1 -le $3 ]]
}

# 验证 URL
is_url() {
    [[ "$1" =~ ^https?:// ]]
}

# 使用
if is_email "user@example.com"; then
    echo "有效的 email"
fi
```

---

## 9.9 速查表

| 指令 | 说明 |
|------|------|
| `$?` | 上一个命令的退出码 |
| `set -e` | 遇到错误就停止 |
| `set -u` | 使用未定义变量时报错 |
| `set -o pipefail` | 管道中任何命令失败就失败 |
| `set -euo pipefail` | 组合使用（推荐） |
| `trap 'func' EXIT` | 退出时执行 |
| `trap 'func' ERR` | 发生错误时执行 |
| `trap 'func' INT` | Ctrl+C 时执行 |
| `exit 1` | 以错误码 1 退出 |

---

## 9.10 练习题

1. 写一个脚本，用 `set -euo pipefail` 并在失败时输出「发生错误」
2. 创建一个 `die()` 函数，在错误时输出消息并退出
3. 用 `trap` 在脚本退出时显示「再见」
4. 写一个部署脚本，在失败时自动回滚
