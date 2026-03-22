# 7. 流程控制与条件循环

---

## 7.1 组合命令：Shell 的精髓

单一命令能做的事有限。把多个命令**组合起来**，才能完成复杂任务。

AI 之所以强大，很大程度上是因为它精通这些组合方式：

```bash
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -10
```

这行指令的意思：「从 access.log 找出错误，统计次数，找出最常见的 10 个」

---

## 7.2 `|`（管道）：数据流的艺术

管道把前一个命令的**输出**变成下一个命令的**输入**。

```bash
# 把文件内容排序后显示
cat unsorted.txt | sort

# 找出最常用的命令
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

# 把日志中所有 IP 取出并统计
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

### 管道 stderr

```bash
# 把 stderr 也传到管道
command1 2>&1 | command2

# 或 Bash 4+
command1 |& command2
```

---

## 7.3 `&&`：成功才执行下一个

**只有当 `command1` 成功（exit code = 0），才执行 `command2`。**

```bash
# 建立目录后进入
mkdir -p project && cd project

# 编译成功后执行
gcc -o program source.c && ./program

# 下载后解压
curl -L -o archive.tar.gz http://example.com/file && tar -xzf archive.tar.gz
```

---

## 7.4 `||`：失败才执行下一个

**只有当 `command1` 失败（exit code ≠ 0），才执行 `command2`。**

```bash
# 文件不存在就建立它
[ -f config.txt ] || echo "配置不存在" > config.txt

# 尝试一种方式，失败了用另一种
cd /opt/project || cd /home/user/project

# 确保即使失败也当作成功（常用于 makefile）
cp file.txt file.txt.bak || true
```

### `&&` 和 `||` 的组合

```bash
# 条件表达式
[ -f config ] && echo "已找到" || echo "没有配置"

# 等价于：
if [ -f config ]; then
    echo "已找到"
else
    echo "没有配置"
fi
```

---

## 7.5 `;`：无论成功失败都执行

```bash
# 三个都执行
mkdir /tmp/test ; cd /tmp/test ; pwd
```

---

## 7.6 `$()`：命令替换

**执行命令，用其输出替换 `$()` 的位置。**

```bash
# 基本用法
echo "今天是 $(date +%Y-%m-%d)"
# 输出：今天是 2026-03-22

# 在变量中使用
FILES=$(ls *.txt)

# 取得目录名
DIR=$(dirname /path/to/file.txt)
BASE=$(basename /path/to/file.txt)

# 计算
echo "结果是 $((10 + 5))"
# 输出：结果是 15
```

### 与反引号的对比

```bash
# 两种语法等价
echo "今天是 $(date +%Y)"
echo "今天是 `date +%Y`"

# 但 $() 更好，因为可以嵌套
echo $(echo $(echo nested))
```

---

## 7.7 `[[ ]]` 和 `[ ]`：条件测试

### 文件测试

```bash
[[ -f file.txt ]]      # 普通文件存在
[[ -d directory ]]     # 目录存在
[[ -e path ]]          # 任何类型存在
[[ -L link ]]          # 符号链接存在
[[ -r file ]]          # 可读
[[ -w file ]]          # 可写
[[ -x file ]]          # 可执行
[[ file1 -nt file2 ]]  # file1 比 file2 新
```

### 字符串测试

```bash
[[ -z "$str" ]]        # 字符串为空
[[ -n "$str" ]]        # 字符串不为空
[[ "$str" == "value" ]] # 相等
[[ "$str" =~ pattern ]]  # 匹配正则表达式
```

### 数值测试

```bash
[[ $num -eq 10 ]]      # 等于
[[ $num -ne 10 ]]      # 不等于
[[ $num -gt 10 ]]      # 大于
[[ $num -lt 10 ]]      # 小于
```

---

## 7.8 `if`：条件判断

```bash
if [[ 条件 ]]; then
    # 条件成立时执行
elif [[ 条件2 ]]; then
    # 条件2 成立时执行
else
    # 都不成立时执行
fi
```

### 完整示例

```bash
#!/bin/bash

FILE="config.yaml"

if [[ ! -f "$FILE" ]]; then
    echo "错误：$FILE 不存在"
    exit 1
fi

if [[ -r "$FILE" ]]; then
    echo "文件可读"
else
    echo "文件不可读"
fi
```

---

## 7.9 `for`：循环

### 基本语法

```bash
for variable in list; do
    # 使用 $variable
done
```

### AI 的常用模式

```bash
# 处理所有 .txt 文件
for file in *.txt; do
    echo "处理 $file"
done

# 数字范围
for i in {1..10}; do
    echo "第 $i 次"
done

# 数组
for color in red green blue; do
    echo $color
done

# C 风格循环（Bash 3+）
for ((i=0; i<10; i++)); do
    echo $i
done
```

---

## 7.10 `while`：条件循环

```bash
# 读取行
while IFS= read -r line; do
    echo "读到: $line"
done < file.txt

# 计数循环
count=0
while [[ $count -lt 10 ]]; do
    echo $count
    ((count++))
done
```

---

## 7.11 `case`：模式匹配

```bash
case $ACTION in
    start)
        echo "启动服务..."
        ;;
    stop)
        echo "停止服务..."
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "用法: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

### 通配符模式

```bash
case "$filename" in
    *.txt)
        echo "文本文件"
        ;;
    *.jpg|*.png|*.gif)
        echo "图片文件"
        ;;
    *)
        echo "未知类型"
        ;;
esac
```

---

## 7.12 速查表

| 符号 | 名称 | 说明 |
|------|------|------|
| `\|` | 管道 | 把输出传给下一个输入 |
| `&&` | AND | 前一个成功才执行下一个 |
| `\|\|` | OR | 前一个失败才执行下一个 |
| `;` | 分号 | 无论成功失败都执行 |
| `$()` | 命令替换 | 执行命令，用输出替换 |
| `[[ ]]` | 条件测试 | 推荐的测试语法 |
| `if` | 条件判断 | 根据条件分支 |
| `for` | 计数循环 | 遍历列表 |
| `while` | 条件循环 | 条件为真时重复 |
| `case` | 模式匹配 | 多条件分支 |

---

## 7.13 练习题

1. 用 `|` 组合 `ls`、`grep`、`wc` 统计某个目录下 `.log` 文件的数量
2. 用 `&&` 确保 `mkdir` 成功后才 `cd` 进去
3. 用 `for` 循环批量建立 10 个目录（dir1 到 dir10）
4. 用 `while read` 读取 `/etc/hosts` 并显示内容
5. 用 `case` 写一个简单的计算器（add、sub、mul、div）
