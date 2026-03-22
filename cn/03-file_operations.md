# 3. 文件操作

---

## 3.1 AI 的文件系统心智模型

在深入每个命令之前，先理解 AI 如何看待文件系统。

人类工程师通常**可视化**地看待文件系统——像 Windows 文件资源管理器或 macOS Finder那样，用图标和文件夹的形状理解。

AI 看待文件系统的方式完全不同：

```
路径         = 绝对位置 /home/user/project/src/main.py
相对位置     = 从当前位置往下走
节点         = 每一个文件或目录都是一个「节点」
属性         = 权限、大小、时间戳、拥有者
类型         = 普通文件(-)、目录(d)、链接(l)、设备(b/c)
```

当 AI 执行 `ls -la` 时，它看到的是：

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI 能立即从这些信息中读出：
- 哪些是目录（`d`）
- 哪些是隐藏文件（以 `.` 开头）
- 谁有什么权限
- 文件大小（判断是否为大型文件）
- 最后修改时间

---

## 3.2 `ls`：AI 最常用的第一个命令

几乎每一次操作之前，AI 都会先执行 `ls` 确认现况。

### AI 常用的 `ls` 组合

```bash
# 基本列表
ls

# 显示隐藏文件（非常重要！）
ls -a

# 长格式（包含详细信息）
ls -l

# 长格式 + 隐藏文件（最常用）
ls -la

# 依修改时间排序（最新的在前）
ls -lt

# 依修改时间排序（最旧的在前）
ls -ltr

# 人类可读的大小（K、M、G）
ls -lh

# 只显示目录
ls -d */

# 递归显示所有文件
ls -R

# 显示 inode 编号（找硬链接时很有用）
ls -li
```

### AI 的实际工作流程

```bash
cd ~/project && ls -la

# 结果：
# drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
# drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
# -rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
# -rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
# drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
# drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
# -rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json

# AI 分析：有一个 .env 文件、src 和 tests 目录、package.json
# 这是一个 Node.js 项目
```

---

## 3.3 `cd`：AI 永远不会忘记去的目录

### AI 的 `cd` 习惯

```bash
# 回到 home 目录
cd ~

# 回到上一个目录（非常实用！）
cd -

# 回到上层目录
cd ..

# 进入子目录
cd src

# 进入很深的路径（Tab 补全的功劳）
cd ~/project/backend/api/v2/routes
```

### AI 的 `cd` + `&&` 模式

这是 AI 最常用的模式之一：

```bash
# 先 cd，确认成功后才执行下一个命令
cd ~/project && ls -la
```

### 常见错误

```bash
# 错误：没有确认目录存在
cd nonexistent
# 输出：bash: cd: nonexistent: No such file or directory

# AI 的做法：先检查
[ -d "nonexistent" ] && cd nonexistent || echo "目录不存在"
```

---

## 3.4 `mkdir`：建立目录的艺术

### 基本用法

```bash
# 建立单个目录
mkdir myproject

# 建立多个目录
mkdir src tests docs

# 建立嵌套目录（-p 是关键！）
mkdir -p project/src/components project/tests
```

### AI 为什么几乎总用 `-p`

`-p` 参数（parents）的意义：
1. 如果目录已存在，**不报错**
2. 如果父目录不存在，**自动建立**

### AI 的典型项目建立模式

```bash
# 建立一个标准项目结构
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`：删除的艺术

**警告**：这是 Shell 中最危险的命令之一。

### 基本用法

```bash
# 删除文件
rm file.txt

# 删除目录（需要 -r）
rm -r directory/

# 删除目录和所有内容（危险！）
rm -rf directory/
```

### `rm -rf` 的危险性

```bash
# 千万不要在 root 身份下执行这个！
# rm -rf /

# 假设你不小心多了空格：
rm -rf * 
# (空格) = rm -rf 删除当前目录的所有东西
```

---

## 3.6 `cp`：复制文件与目录

### 基本用法

```bash
# 复制文件
cp source.txt destination.txt

# 复制目录（需要 -r）
cp -r source_directory/ destination_directory/

# 复制时显示进度（-v verbose）
cp -v large_file.iso /backup/

# 交互模式（覆盖前询问）
cp -i *.py src/
```

### 通配符的威力

```bash
# 复制所有 .txt 文件
cp *.txt backup/

# 复制所有图片文件
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`：移动与重命名

### 基本用法

```bash
# 移动文件
mv file.txt backup/

# 移动并重命名
mv oldname.txt newname.txt

# 批量重命名
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 速查表

| 命令 | 基本用法 | 常用参数 | AI 备注 |
|------|----------|----------|---------|
| `ls` | `ls [路径]` | `-l` 长格式, `-a` 隐藏文件, `-h` 人类可读 | 先 `ls -la` 总是好的 |
| `cd` | `cd [路径]` | `-` 回上一个, `..` 上层 | `cd xxx &&` 是好习惯 |
| `mkdir` | `mkdir [目录]` | `-p` 嵌套建立 | 几乎总用 `-p` |
| `rm` | `rm [文件]` | `-r` 递归, `-f` 强制 | 小心 `rm -rf /*` |
| `cp` | `cp [来源] [目标]` | `-r` 目录, `-i` 询问, `-p` 保留属性 | 用 `-i` 防呆 |
| `mv` | `mv [来源] [目标]` | `-i` 询问, `-n` 不覆盖 | 就是 rename |

---

## 3.9 练习题

1. 用 `mkdir -p` 建立三层嵌套目录，然后用 `tree` 或 `find` 确认
2. 用 `cp` 复制一个大文件，加上 `-v` 看看输出什么
3. 用 `mv` 批量将 10 个 `.txt` 文件重命名为 `.md`
4. 用 `rm -i` 删除一个测试文件，体验询问过程
