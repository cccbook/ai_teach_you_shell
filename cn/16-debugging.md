# 16. 调试心法

---

## 16.1 AI 的调试思维

人类遇到错误时：慌张、上网搜索、复制粘贴
AI 遇到错误时：分析错误信息、推理原因、执行修复

AI 的调试流程：
```
观察错误输出 → 理解错误类型 → 定位问题 → 修复 → 验证
```

---

## 16.2 `bash -x`：追踪执行

最简单的调试方法：加 `-x` 参数

```bash
bash -x script.sh
```

会输出每一行执行的命令前面加 `+`：

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### 只想调试某一段

```bash
#!/bin/bash

# 正常执行
echo "这行不会显示"
set -x
# 这里开始调试
name="Alice"
echo "Hello, $name"
set +x
# 调试结束
echo "这行不会显示"
```

---

## 16.3 `set -v`：原始输入模式

```bash
bash -v script.sh
```

会输出 Shell 读到的**原始行**，在命令扩展之前：

```bash
echo "Hello"
# 输出：echo "Hello"
Hello
```

---

## 16.4 在脚本中设定调试模式

```bash
#!/bin/bash

# 在脚本开头开启调试
set -x
set -v

# ... 脚本内容 ...

set +x
set +v
```

### ERRDEBUG

```bash
#!/bin/bash
set -euo pipefail

# 每个命令失败时输出
DEBUGGING=true
if $DEBUGGING; then
    trap 'echo "失败的命令: $BASH_COMMAND"' ERR
fi
```

---

## 16.5 常见错误及修复

### 错误 1：文件权限不足

```bash
# 错误
./script.sh
# 输出：Permission denied

# 修复
chmod +x script.sh
./script.sh
```

### 错误 2：找不到命令

```bash
# 错误
python script.py
# 输出：command not found: python

# 修复：用完整路径
/usr/bin/python3 script.py

# 或确认路径
which python3
```

### 错误 3：变量未定义

```bash
#!/bin/bash
set -u

echo $undefined_var
# 输出：bash: undefined_var: unbound variable

# 修复：给默认值
echo ${undefined_var:-default}
```

### 错误 4：引号问题

```bash
# 错误
file="my document.txt"
ls $file
# 输出：ls: my: No such file or directory

# 修复：加引号
ls "$file"
```

### 错误 5：空格当分隔符

```bash
# 错误
for f in $(ls *.txt); do
    echo "$f"
done
# 输出可能不预期

# 修复：用 IFS 或 read
while IFS= read -r f; do
    echo "$f"
done < <(ls *.txt)
```

---

## 16.6 `echo` 调试法

当 `-x` 不够用时，手动加入 `echo`：

```bash
#!/bin/bash

echo "DEBUG: 进入函数"
echo "DEBUG: 参数 = $@"

process() {
    echo "DEBUG: 在 process 中"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
    echo "DEBUG: 离开 process"
}
```

---

## 16.7 使用 `set -e`

```bash
#!/bin/bash
set -euo pipefail

# 任何命令失败就停止
mkdir -p backup
cp important.txt backup/  # 如果失败，脚本就停止
rm important.txt         # 不会执行到这里
```

### 排除特定命令

```bash
#!/bin/bash
set -euo pipefail

# 这个命令可能失败，但我们不在乎
command_that_might_fail || true

# 或用子 shell
(set +e; command_might_fail; true)
```

---

## 16.8 trace-trap：追踪函数调用

```bash
#!/bin/bash

# 每执行一个命令就调用一次
trap 'echo "执行: $BASH_COMMAND (行: $LINENO)"' DEBUG

func1() {
    echo "在 func1 中"
    func2
}

func2() {
    echo "在 func2 中"
}

func1
```

---

## 16.9 检查退出码

```bash
#!/bin/bash

command1
echo "command1 退出码: $?"

command2
echo "command2 退出码: $?"

# 或组合
command1 || echo "command1 失败了"
command2 && echo "command2 成功了"
```

---

## 16.10 常用调试命令

```bash
# 检查语法（不执行）
bash -n script.sh

# 追踪执行
bash -x script.sh

# 详细模式
bash -v script.sh

# 显示所有命令
bash -x script.sh

# 组合
bash -xv script.sh
```

---

## 16.11 练习题

1. 用 `bash -x` 执行一个脚本，观察输出格式
2. 在脚本中使用 `set -x` 只调试某个函数
3. 找一个会失败的命令，分析错误信息并修复
4. 用 `trap` 制作一个优雅的错误处理