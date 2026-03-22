# 8. 变量与函数

---

## 8.1 变量的基础

### 基本赋值

```bash
# 字符串
name="Alice"
greeting="Hello, World!"

# 数字
age=25
count=0

# 空值
empty=
empty2=""
```

### 读取变量

```bash
echo $name
echo ${name}    # 建议用这个形式，更明确

# 在双引号中使用
echo "我叫 ${name}"
```

### 避免常见错误

```bash
# 错误：等号两边有空格
name = "Alice"   # 会被当成命令执行

# 错误：未加引号
greeting=Hello World  # 只会 echo "Hello"

# 正确：
name="Alice"
greeting="Hello World"
```

---

## 8.2 引号的艺术

### 双引号 `"`

会展开变量和命令替换

```bash
name="Alice"
echo "Hello, $name"           # Hello, Alice
echo "今天是 $(date +%Y)"     # 今天是 2026
```

### 单引号 `'`

原样输出，不展开任何东西

```bash
name="Alice"
echo 'Hello, $name'           # Hello, $name
echo '今天是 $(date +%Y)'     # 今天是 $(date +%Y)
```

### 无引号

尽量避免使用，除非你确定变量值不包含空白

```bash
# 有风险
file=my document.txt
ls $file  # 会出错

# 安全
file="my document.txt"
ls "$file"
```

---

## 8.3 特殊变量

```bash
$0          # 脚本名称
$1, $2...   # 命令行参数
$#          # 参数个数
$@          # 所有参数（个别）
$*          # 所有参数（合并成一个）
$?          # 上一个命令的退出码
$$          # 当前程序的 PID
$!          # 上一个后台程序的 PID
$-          # 当前 shell 的选项
```

### 示例

```bash
#!/bin/bash
echo "脚本名：$0"
echo "第一个参数：$1"
echo "第二个参数：$2"
echo "参数总数：$#"
echo "所有参数：$@"

# 执行 ./script.sh foo bar
# 输出：
# 脚本名：./script.sh
# 第一个参数：foo
# 第二个参数：bar
# 参数总数：2
# 所有参数：foo bar
```

---

## 8.4 数组

### 基本用法

```bash
# 定义数组
colors=("red" "green" "blue")

# 读取元素
echo ${colors[0]}    # red
echo ${colors[1]}    # green
echo ${colors[2]}    # blue

# 读取所有元素
echo ${colors[@]}    # red green blue

# 数组长度
echo ${#colors[@]}   # 3

# 获取最后一个元素
echo ${colors[-1]}   # blue
```

### 关联数组（Bash 4+）

```bash
declare -A user
user["name"]="Alice"
user["email"]="alice@example.com"

echo ${user["name"]}    # Alice
echo ${!user[@]}        # name email
```

### 实用示例

```bash
# 读取目录中的文件
files=(*.txt)
echo "找到 ${#files[@]} 个 .txt 文件"

# 读取命令输出到数组
mapfile -t lines < file.txt
echo "文件有 ${#lines[@]} 行"
```

---

## 8.5 函数的基础

### 定义函数

```bash
# 方式 1：function 关键字
function greet {
    echo "Hello!"
}

# 方式 2：直接定义（推荐）
greet() {
    echo "Hello!"
}
```

### 函数参数

```bash
greet() {
    echo "Hello, $1!"
}

greet "Alice"    # Hello, Alice!
greet "Bob"      # Hello, Bob!
```

### 返回值

```bash
# return：用于退出码（0-255）
check() {
    if [[ $1 -gt 10 ]]; then
        return 0  # 成功
    else
        return 1  # 失败
    fi
}

if check 15; then
    echo "大于 10"
fi
```

---

## 8.6 局部变量

```bash
counter() {
    local count=0
    ((count++))
    echo $count
}
```

### 为什么要 `local`？

```bash
count=0

increment() {
    local count=1
    ((count++))
    echo "函数内: $count"
}

increment
echo "函数外: $count"  # 仍是 0，因为 local 保护了外部变量
```

---

## 8.7 函数库

### 创建函数库

```bash
cat > lib.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date +%H:%M:%S)] $@"
}

error() {
    echo "[$(date +%H:%M:%S)] ERROR: $@" >&2
}

confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}
EOF
```

### 使用函数库

```bash
#!/bin/bash

source lib.sh

log "开始处理"
error "发生了问题"
confirm "确定要继续？" && echo "继续执行"
```

---

## 8.8 递归函数

```bash
# 计算阶乘
factorial() {
    if [[ $1 -le 1 ]]; then
        echo 1
    else
        local prev=$(factorial $(( $1 - 1 )))
        echo $(( $1 * prev ))
    fi
}

factorial 5  # 输出：120
```

---

## 8.9 实战：完整的项目初始化脚本

```bash
cat > init-project.sh << 'EOF'
#!/bin/bash
set -euo pipefail

PROJECT_NAME="${1:-myproject}"

log() { echo "📦 $@"; }
success() { echo "✅ $@"; }
error() { echo "❌ $@" >&2; }

create_project() {
    log "建立项目：${PROJECT_NAME}"
    
    mkdir -p "${PROJECT_NAME}"/{src,tests,docs,scripts}
    
    cat > "${PROJECT_NAME}/README.md" << MD
# ${PROJECT_NAME}

MD

    cat > "${PROJECT_NAME}/src/__init__.py" << MD
"""${PROJECT_NAME}"""
MD

    success "项目建立完成"
    tree "${PROJECT_NAME}"
}

create_project
EOF

chmod +x init-project.sh
./init-project.sh myblog
```

---

## 8.10 速查表

| 主题 | 语法 | 说明 |
|------|------|------|
| 赋值 | `var=value` | 等号两边不能有空格 |
| 读取 | `$var` 或 `${var}` | 建议用 `${var}` |
| 双引号 | `"..."` | 展开变量和命令 |
| 单引号 | `'...'` | 不展开任何东西 |
| 命令行参数 | `$1`, `$2`, `$@` | 获取参数 |
| 函数 | `name() { }` | 推荐的函数定义方式 |
| 局部变量 | `local var=value` | 只在函数内有效 |
| 数组 | `arr=(a b c)` | 支持索引和关联 |
| source | `source file.sh` | 加载函数库 |

---

## 8.11 练习题

1. 写一个脚本，接受名字和年龄参数，输出「X 岁的 Y 你好！」
2. 创建一个包含 `log` 和 `error` 函数的函数库，并在另一个脚本中使用它
3. 写一个递归函数计算斐波那契数列
4. 用 `mapfile` 读取一个文件的每一行到数组，然后倒序输出
