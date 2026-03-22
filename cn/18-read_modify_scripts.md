# 18. 读懂并修改别人的脚本

---

## 18.1 为什么要读懂别人的脚本

- 接手维护项目
- 使用开源工具
- Debug 问题
- 学习新技巧

AI 每天都会遇到陌生的脚本，所以学习如何快速理解他人写的 Shell 脚本是必备技能。

---

## 18.2 初步观察

### 第一步：看 shebang

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # 使用 bash
#!/bin/sh        # 使用 POSIX sh（兼容性更好）
#!/usr/bin/env python3  # Python 脚本
```

### 第二步：看权限和大小

```bash
ls -la script.sh
wc -l script.sh
```

### 第三步：快速语法检查

```bash
bash -n script.sh  # 只检查语法，不执行
```

---

## 18.3 理解结构

### 典型结构

```bash
#!/bin/bash
# 注释：脚本功能说明

# 设置
set -euo pipefail
VAR="value"

# 函数定义
function help() { ... }

# 主流程
main() { ... }

# 执行
main "$@"
```

### 快速找到主流程

```bash
# 找最后几行
tail -20 script.sh

# 找函数定义
grep -n "^function\|^[a-z_]+\(\)" script.sh
```

---

## 18.4 追踪变量

### 找出所有变量

```bash
# 找赋值
grep -E '^[A-Za-z_][A-Za-z0-9_]*=' script.sh

# 找使用
grep -o '\$[A-Za-z_][A-Za-z0-9_]*' script.sh | sort -u
```

### 理解变量作用域

```bash
# 全局变量（开头）
MY_VAR="global"

# 局部变量（在函数内）
my_function() {
    local MY_LOCAL="local"
}
```

---

## 18.5 常用 grep 分析

```bash
# 找所有函数定义
grep -n "^[[:space:]]*function" script.sh

# 找所有条件判断
grep -n "if\|\[\[" script.sh

# 找所有循环
grep -n "for\|while\|do\|done" script.sh

# 找所有命令替换
grep -n '\$(' script.sh

# 找所有 exit
grep -n "exit" script.sh
```

---

## 18.6 用 `awk` 提取结构

```bash
# 提取函数名称
awk '/^[a-z_]+\(\)/ {print NR": "$0}' script.sh

# 提取条件分支
awk '/^\s*(if|case)/ {print NR": "$0}' script.sh

# 提取命令行参数
awk '/\$\{?[0-9]/{print NR": "$0}' script.sh
```

---

## 18.7 可视化脚本结构

```bash
#!/bin/bash
# 可视化工具

script=$1

echo "=== 结构分析：$script ==="
echo ""

echo "--- 函数 ---"
grep -n "^[[:space:]]*function\|^[[:space:]]*[a-z_][a-z_0-9]*\(\)" "$script"

echo ""
echo "--- 条件判断 ---"
grep -n "if\|\[\[$\|case\|^[[:space:]]*then\|^[[:space:]]*esac" "$script"

echo ""
echo "--- 循环 ---"
grep -n "for\|while\|^do$\|^done$" "$script"

echo ""
echo "--- 外部命令 ---"
grep -oE '^[^#]*[a-z][a-z0-9-]+' "$script" | sort -u
```

---

## 18.8 安全检查

### 检查危险命令

```bash
# 找 rm -rf
grep -n "rm -rf" script.sh

# 找 sudo
grep -n "sudo" script.sh

# 找 >
grep -n ">" script.sh

# 找 `eval`
grep -n "eval" script.sh
```

### 检查变量注入风险

```bash
# 找未加引号的变量
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh

# 找 user input
grep -n '\$1\|\$2\|read' script.sh
```

---

## 18.9 改写陌生脚本

### 步骤 1：注释理解

```bash
#!/bin/bash
# 读取脚本，一边读一边加注释
# 2024-03-22 分析：这是备份脚本
# 作者：某人
# 用途：每日备份数据库

# Step 1: 设置变量
# BACKUP_DIR: 备份目标目录
BACKUP_DIR="/backup"
```

### 步骤 2：测试片段

```bash
# 提取并测试函数
# 把函数复制到新文件测试
```

### 步骤 3：简化

```bash
# 用更清晰的方式重写
```

---

## 18.10 常见模式识别

### 初始化模式

```bash
# 常用初始化
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### 参数解析模式

```bash
# while + case 解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) help; exit 0 ;;
        -*) echo "Unknown"; exit 1 ;;
    esac
done
```

### 错误处理模式

```bash
# 典型错误处理
command || { echo "Failed"; exit 1; }
```

---

## 18.11 用 AI 帮你理解

```bash
#!/bin/bash
# 把脚本贴给 AI 让它解释

cat > /tmp/analyze.sh << 'HELPER'
#!/bin/bash
# 分析输入的脚本，解释每个部分

script=$(cat)

echo "=== AI 脚本分析 ==="
echo ""
echo "## 文件头"
head -10

echo ""
echo "## 函数列表"
grep -n "^function\|^[[:space:]]*[a-z_]*\(\)"

echo ""
echo "## 可能的问题"
# 检查危险操作
grep -n "rm -rf\|eval\|\$($" || echo "未发现明显危险操作"

echo ""
echo "## 建议"
echo "- 可加入 set -euo pipefail"
echo "- 变量应加引号"
HELPER
```

---

## 18.12 练习题

1. 用 `grep` 和 `awk` 分析一个现有的 Shell 脚本
2. 找出脚本中的所有变量并理解它们的用途
3. 用 `bash -n` 检查一个脚本的语法
4. 为一个没有注释的脚本加入注释，说明每个部分的功能