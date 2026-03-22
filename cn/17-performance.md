# 17. 性能优化

---

## 17.1 为什么 Shell 性能重要

Shell 脚本通常用于：
- 批量处理大量文件
- 自动化任务
- CI/CD 流程

一个慢的脚本可能让整个流程延迟数小时。优化 Shell 脚本可以大幅提升效率。

---

## 17.2 避免外部命令

```bash
# 慢：用外部命令
for f in *.txt; do
    name=$(basename "$f")
    echo "$name"
done

# 快：用 Shell 内置功能
for f in *.txt; do
    echo "${f##*/}"
done
```

### 内置 vs 外部命令

| 慢 | 快 | 说明 |
|----|-----|------|
| `$(cat file)` | `$(<file)` | 直接读取 |
| `$(basename $f)` | `${f##*/}` | Shell 参数扩展 |
| `$(dirname $f)` | `${f%/*}` | Shell 参数扩展 |
| `$(expr $a + $b)` | `$((a + b))` | 算术 expansion |
| `$(echo $var)` | `"$var"` | 直接使用 |

---

## 17.3 用 `while read` 取代 `for`

```bash
# 慢：for + command substitution
for line in $(cat file.txt); do
    process "$line"
done

# 快：while read
while IFS= read -r line; do
    process "$line"
done < file.txt
```

### 为什么？

`$(cat file)` 会一次把所有内容读入内存，而 `while read` 是一行一行处理。

---

## 17.4 并行处理

### 用 `&` 和 `wait`

```bash
#!/bin/bash

# 同时执行 3 个任务
task1 &
task2 &
task3 &

# 等待所有任务完成
wait

echo "所有任务完成"
```

### 用 `xargs -P` 并行化

```bash
# 序列执行
cat files.txt | xargs -I {} process {}

# 并行执行（4 个并行）
cat files.txt | xargs -P 4 -I {} process {}
```

### 用 `parallel`（需安装）

```bash
# 安装
brew install parallel

# 平行处理
cat files.txt | parallel -j 4 "process {}"

# 保留目录结构
find . -name "*.txt" | parallel -j 4 "gzip {}"
```

---

## 17.5 避免子 shell

```bash
# 慢：每个循环都建立子 shell
for f in *.txt; do
    content=$(cat "$f")
    echo "$content" | wc -l
done

# 快：使用子 shell 一次处理
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 使用 `find` 的 `-exec`

```bash
# 慢：循环
for f in $(find . -name "*.txt"); do
    gzip "$f"
done

# 快：find -exec
find . -name "*.txt" -exec gzip {} \;

# 更快：合并参数
find . -name "*.txt" -exec gzip {} +
```

---

## 17.7 字符串操作

```bash
# 慢
upper=$(echo "$var" | tr '[:lower:]' '[:upper:]')

# 快：用 bash 功能
upper="${var^^}"

# 慢
trim=$(echo "$var" | xargs)

# 快
trim="${var#"${var%%[![:space:]]*}"}"
trim="${trim%"${trim##*[![:space:]]}"}"
```

---

## 17.8 数组操作

```bash
# 慢：外部命令
count=$(echo "${array[@]}" | wc -w)

# 快：内置
count=${#array[@]}

# 慢：外部排序
sorted=$(echo "${array[@]}" | tr ' ' '\n' | sort)

# 快：用 Bash 4+ 内置排序
mapfile -t sorted < <(printf '%s\n' "${array[@]}" | sort)
```

---

## 17.9 延迟展开

```bash
#!/bin/bash
set -euo pipefail

# 在大循环中，避免重复展开不变的变量
for i in {1..10000}; do
    # 慢：每次都展开
    echo "$prefix $i $suffix"
    
    # 快：合并后只展开一次
    line="$prefix $i $suffix"
    echo "$line"
done
```

---

## 17.10 缓存昂贵计算

```bash
#!/bin/bash

declare -A CACHE

expensive() {
    local key=$1
    if [[ -v CACHE[$key] ]]; then
        echo "${CACHE[$key]}"
        return
    fi
    
    local result=$(compute "$key")
    CACHE[$key]=$result
    echo "$result"
}
```

---

## 17.11 测量性能

```bash
#!/bin/bash

time my-slow-script.sh

# 或在脚本内
start=$(date +%s)
# ... 工作 ...
end=$(date +%s)
echo "耗时：$((end - start)) 秒"
```

### 用 `time`

```bash
time find . -name "*.txt" -exec gzip {} \;

# 输出：
# real    0m2.345s
# user    0m1.234s
# sys     0m0.567s
```

---

## 17.12 速查表

| 优化技巧 | 慢 | 快 |
|----------|-----|-----|
| 读文件 | `$(cat file)` | `$(<file)` 或 `while read` |
| 路径处理 | `$(basename $f)` | `${f##*/}` |
| 数学计算 | `$(expr $a + $b)` | `$((a + b))` |
| 排序 | `sort` | Bash 4+ 内置 |
| 找文件 | for + find | `find -exec` |
| 并行 | 序列执行 | `&` + `wait` 或 `xargs -P` |
| 字符串大写 | `tr` | `${var^^}` |

---

## 17.13 练习题

1. 用 `time` 测量一个循环处理 1000 个文件的时间
2. 把一个序列处理的脚本改成并行处理
3. 比较 `$(cat file)` 和 `while read` 的性能差异
4. 用 `xargs -P` 加速批量图片处理