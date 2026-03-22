# 10. 参数解析与 CLI 工具

---

## 10.1 命令行参数基础

```bash
#!/bin/bash

echo "脚本名：$0"
echo "第一个参数：$1"
echo "第二个参数：$2"
echo "第三个参数：${3:-default}"  # 默认值
echo "参数总数：$#"
echo "所有参数：$@"
```

### 执行

```bash
./script.sh foo bar
# 输出：
# 脚本名：./script.sh
# 第一个参数：foo
# 第二个参数：bar
# 第三个参数：default
# 参数总数：2
# 所有参数：foo bar
```

---

## 10.2 简单的参数解析

### 位置参数

```bash
#!/bin/bash

# 没有参数时显示帮助
if [[ $# -eq 0 ]]; then
    echo "用法: $0 <文件>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "错误：文件不存在"
    exit 1
fi

echo "处理 $FILE..."
```

### 处理可选参数

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "未知选项：$1"
            exit 1
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

$VERBOSE && echo "verbose 模式开启"
[[ -n "$OUTPUT" ]] && echo "输出到：$OUTPUT"
[[ -n "$FILE" ]] && echo "处理文件：$FILE"
```

---

## 10.3 `getopts`：标准选项解析

```bash
#!/bin/bash

# 格式字符串：每个字母是一个选项
# : 在前面表示选项后面需要参数
while getopts "hv:o:" opt; do
    case $opt in
        h)
            echo "帮助信息"
            exit 0
            ;;
        v)
            echo "verbose 模式：$OPTARG"
            ;;
        o)
            echo "输出文件：$OPTARG"
            ;;
        \?)
            echo "无效选项：-$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "剩下的参数：$@"
```

### 选项格式

| 格式 | 意义 |
|------|------|
| `getopts "hv:"` | `-h` 无参数，`-v` 需要参数 |
| `getopts ":hv:"` | 忽略未知选项，用 `:` 开头 |
| `OPTARG` | 当前选项的参数值 |
| `OPTIND` | 下一个要处理的参数索引 |

---

## 10.4 完整的 CLI 工具示例

```bash
cat > gitlike << 'EOF'
#!/bin/bash
set -euo pipefail

VERSION="1.0.0"

usage() {
    cat << USAGE
greet - 问候工具 v${VERSION}

用法:
    greet [选项] [名字]

选项:
    -h, --help      显示帮助
    -v, --version   显示版本
    -t, --time      显示时间问候
    -f, --formal    正式问候

示例:
    greet Alice
    greet -f Alice
    greet -t
USAGE
}

main() {
    local formal=false
    local show_time=false
    local name="World"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                echo "greet v${VERSION}"
                exit 0
                ;;
            -t|--time)
                show_time=true
                shift
                ;;
            -f|--formal)
                formal=true
                shift
                ;;
            -*)
                echo "未知选项：$1"
                exit 1
                ;;
            *)
                name="$1"
                shift
                ;;
        esac
    done

    if $show_time; then
        local hour=$(date +%H)
        if [[ $hour -lt 12 ]]; then
            echo "早安"
        elif [[ $hour -lt 18 ]]; then
            echo "午安"
        else
            echo "晚安"
        fi
    fi

    if $formal; then
        echo "您好，尊贵的 ${name}。"
    else
        echo "你好，${name}！"
    fi
}

main "$@"
EOF

chmod +x gitlike
./gitlike Alice
./gitlike --formal --time Bob
```

---

## 10.5 交互式输入

### `read`：读取用户输入

```bash
#!/bin/bash

# 基本读取
read -p "请输入你的名字：" name
echo "你好，$name"

# 读取密码（不显示）
read -sp "请输入密码：" password
echo

# 读取多个值
read -p "输入名字和年龄：" name age
echo "$name 是 $age 岁"

# 超时
read -t 5 -p "5 秒内输入：" value
```

### 确认提示

```bash
confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

if confirm "确定要删除吗？"; then
    echo "执行删除..."
fi
```

---

## 10.6 菜单式界面

```bash
#!/bin/bash

PS3="请选择操作: "

select choice in "建立项目" "删除项目" "退出"; do
    case $choice in
        "建立项目")
            echo "建立中..."
            ;;
        "删除项目")
            echo "删除中..."
            ;;
        "退出")
            echo "再见！"
            exit 0
            ;;
        *)
            echo "无效选择，请重新选择"
            ;;
    esac
done
```

### 输出

```
1) 建立项目
2) 删除项目
3) 退出
请选择操作: 1
建立中...
```

---

## 10.7 进度条

```bash
progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r[%s%s] %3d%%" \
        "$(printf '#%.0s' $(seq 1 $completed))" \
        "$(printf '.%.0s' $(seq 1 $remaining))" \
        "$percent"
    
    [[ $current -eq $total ]] && echo
}

# 使用
for i in {1..100}; do
    progress $i 100
    sleep 0.05
done
```

---

## 10.8 速查表

| 语法 | 说明 |
|------|------|
| `$0` | 脚本名称 |
| `$1`, `$2`... | 位置参数 |
| `$#` | 参数个数 |
| `${var:-default}` | 默认值 |
| `getopts "hv:" opt` | 解析选项 |
| `$OPTARG` | 当前选项的参数 |
| `$OPTIND` | 下一个参数索引 |
| `read -p "提示：" var` | 读取输入 |
| `read -s var` | 隐藏输入（密码） |
| `read -t 5 var` | 5 秒超时 |
| `select` | 菜单界面 |

---

## 10.9 练习题

1. 写一个 CLI 工具，接受 `-n` 参数指定次数，`-v` 显示详细信息
2. 用 `getopts` 解析 `-h`（帮助）、`-o`（输出文件）选项
3. 写一个确认函数，只有回答 y 才执行删除
4. 用 `select` 制作一个简易的计算器菜单
