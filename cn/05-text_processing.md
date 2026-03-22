# 5. 文字处理

---

## 5.1 AI 的文字处理哲学

在 AI 的世界里，**一切都是文字**。

- 代码是文字
- 配置文件是文字
- 日志是文字
- JSON、HTML、Markdown 都是文字

所以文字处理命令是 AI 工具箱中最核心的部分。

人类工程师遇到问题时：「我要找一个工具来处理这个...」
AI 遇到问题时：「这个用 `grep | sed | awk` 一行就能解决。」

---

## 5.2 `cat`：读取文件的艺术

### 基本用法

```bash
# 显示文件内容
cat file.txt

# 合并文件
cat part1.txt part2.txt > whole.txt

# 显示行号
cat -n script.sh
```

### `cat` 的真正用途：组合与建立

```bash
# 从 stdin 建立文件
cat << 'EOF' > newfile.txt
这是文件内容
可以写很多行
EOF
```

---

## 5.3 `head` 和 `tail`：只看需要的部分

### `head`：看前面

```bash
# 看前 10 行（默认）
head file.txt

# 看前 5 行
head -n 5 file.txt

# 看前 100 字节
head -c 100 file.txt
```

### `tail`：看后面

```bash
# 看最后 10 行（默认）
tail file.txt

# 看最后 5 行
tail -n 5 file.txt

# 实时监控文件（最常用！）
tail -f /var/log/syslog

# 实时监控日志，发现错误就停止
tail -f app.log | grep --line-buffered ERROR
```

### 看特定行范围

```bash
# 看第 100-150 行
tail -n +100 file.txt | head -n 50
```

---

## 5.4 `wc`：计数工具

```bash
# 计算行数
wc -l file.txt

# 计算多个文件的行数
wc -l *.py

# 统计文件夹中有多少个文件
ls | wc -l
```

---

## 5.5 `grep`：文字搜索之王

### 基本用法

```bash
# 搜索包含 "error" 的行
grep "error" log.txt

# 忽略大小写
grep -i "error" log.txt

# 显示行号
grep -n "error" log.txt

# 只显示文件名
grep -l "TODO" *.md

# 反向（不匹配的行）
grep -v "debug" log.txt

# 只显示完全匹配的单词
grep -w "error" log.txt
```

### 正则表达式

```bash
# 开头匹配
grep "^Error" log.txt

# 结尾匹配
grep "done.$" log.txt

# 任意字符
grep "e.or" log.txt

# 范围
grep -E "[0-9]{3}-" log.txt
```

### 高级技巧

```bash
# 递归搜索
grep -r "TODO" src/

# 只搜索特定扩展名
grep -r "TODO" --include="*.py" src/

# 显示前后行
grep -B 2 -A 2 "ERROR" log.txt

# 多重条件（OR）
grep -E "error|warning|fatal" log.txt
```

---

## 5.6 `sed`：文字替换利器

### 基本替换

```bash
# 替换第一个匹配
sed 's/old/new/' file.txt

# 替换所有匹配
sed 's/old/new/g' file.txt

# 原地替换
sed -i 's/old/new/g' file.txt

# 备份后原地替换
sed -i.bak 's/old/new/g' file.txt
```

### 删除行

```bash
# 删除空行
sed '/^$/d' file.txt

# 删除以 # 开头的行（注释）
sed '/^#/d' file.txt

# 删除行尾空白
sed 's/[[:space:]]*$//' file.txt
```

### 实用示例

```bash
# 批量改扩展名（.txt → .md）
for f in *.txt; do
    mv "$f" "$(sed 's/.txt$/.md/' <<< "$f")"
done

# 移除 Windows 换行符
sed -i 's/\r$//' file.txt

# 把所有空白变成 Tab
sed 's/  */\t/g' file.txt
```

---

## 5.7 `awk`：文字处理的瑞士刀

### 基本概念

`awk` 会逐行读取文字，自动分割成字段（$1, $2, $3...），对每一行执行指定的动作。

### 基本用法

```bash
# 默认以空白分割字段
awk '{print $1}' file.txt

# 指定分隔符
awk -F: '{print $1}' /etc/passwd

# 输出多个字段
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### 条件判断

```bash
# 只处理符合条件的行
awk -F: '$3 > 1000 {print $1}' /etc/passwd

# BEGIN 和 END
awk 'BEGIN {print "开始"} {print} END {print "完成"}' file.txt
```

### 实用示例

```bash
# 计算 CSV 的总和
awk -F, '{sum += $3} END {print sum}' data.csv

# 找最大值
awk 'NR==1 {max=$3} $3>max {max=$3} END {print max}' data.csv

# 格式化输出
awk '{printf "%-20s %10.2f\n", $1, $2}' data.txt
```

---

## 5.8 实战：组合使用所有工具

### 情境：分析服务器日志

```bash
# 1. 找出错误消息
grep -i "error" access.log

# 2. 统计错误数量
grep -ci "error" access.log

# 3. 找出最常见的错误
grep "error" access.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# 4. 统计每小时的请求数
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

### 情境：批量修改代码

```bash
# 把所有 .py 文件中的 "print" 改成 "logger.info"
find . -name "*.py" -exec sed -i 's/print(/logger.info(/g' {} +

# 把所有的 var 改成 const
find . -name "*.js" -exec sed -i 's/\bvar\b/const/g' {} +
```

---

## 5.9 速查表

| 命令 | 用途 | 常用参数 |
|------|------|----------|
| `cat` | 显示/合并文件 | `-n` 行号 |
| `head` | 看文件开头 | `-n` 行数, `-c` 字节 |
| `tail` | 看文件结尾 | `-n` 行数, `-f` 实时监控 |
| `wc` | 计数 | `-l` 行, `-w` 字, `-c` 字节 |
| `grep` | 搜索文字 | `-i` 忽略, `-n` 行号, `-r` 递归, `-c` 计数 |
| `sed` | 替换文字 | `s/old/new/g`, `-i` 原地 |
| `awk` | 字段处理 | `-F` 分隔符, `{print}` 动作 |

---

## 5.10 练习题

1. 用 `head` 和 `tail` 组合看文件的第 100-120 行
2. 用 `grep` 找出 `/etc/passwd` 中所有使用 `/bin/bash` 的用户
3. 用 `sed` 把文件中所有的 `\r\n` 换成 `\n`
4. 用 `awk` 计算一个包含数字的文件的最大值、最小值、平均值
