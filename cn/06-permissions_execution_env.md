# 6. 权限、执行、环境与设置

---

## 6.1 `chmod`：权限的艺术

### Linux/Unix 权限基础

```
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 .
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 README.md
-rwxr-xr-x  1 ai  staff   128 Mar 22 10:30 script.sh
```

后面 9 个字符分成三组：
- `rwx`（拥有者）：读取、写入、执行
- `r-x`（组）：读取、执行
- `r--`（其他人）：只能读取

### chmod 的两种表示法

**数字表示法（八进制）**：

```
r = 4, w = 2, x = 1

rwx = 7, r-x = 5, r-- = 4
```

常用组合：
- `777` = rwxrwxrwx（危险！）
- `755` = rwxr-xr-x
- `644` = rw-r--r--
- `700` = rwx------
- `600` = rw-------

**符号表示法**：

```bash
chmod u+x script.sh    # 拥有者加上执行权限
chmod g-w file.txt     # 组移除写入权限
chmod +x script.sh     # 所有人加上执行权限
```

### AI 的 chmod 常用场景

```bash
# 让脚本能执行（几乎每个脚本都要）
chmod +x script.sh

# 让目录可以被进入
chmod +x ~/projects

# 让目录和里面的所有文件可被组写入
chmod -R g+w project/
```

---

## 6.2 执行 Shell 脚本

### 执行方式

```bash
# 方式 1：用路径执行（需要执行权限）
./script.sh

# 方式 2：用 bash 执行（不需要执行权限）
bash script.sh

# 方式 3：用 source 执行（在当前 shell 中执行）
source script.sh
```

### 什么时候用哪种？

| 方式 | 使用时机 | 特点 |
|------|----------|------|
| `./script.sh` | 标准执行 | 需要 `chmod +x`，子 shell 执行 |
| `bash script.sh` | 指定 shell | 不需要执行权限 |
| `source script.sh` | 设置环境变量 | 在当前 shell 执行 |

### `source` vs `./script` 的关键差异

```bash
# script.sh 内容：export MY_VAR="hello"

# 用 ./script.sh 执行
./script.sh
echo $MY_VAR  # 输出：（空）← 在子 shell，环境变量消失了

# 用 source script.sh 执行
source script.sh
echo $MY_VAR  # 输出：hello ← 在当前 shell，变量保留
```

---

## 6.3 `export`：环境变量

```bash
# 设置环境变量
export NAME="Alice"
export PATH="$PATH:/new/directory"

# 显示所有环境变量
export

# 常用变量
echo $HOME      # 家目录
echo $USER      # 用户名称
echo $PATH      # 搜索路径
echo $PWD       # 当前目录
```

### 持久化环境变量

```bash
# 写入 ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc

# 让设置生效
source ~/.bashrc
```

---

## 6.4 `source`：加载文件

等价于：把文件的内容**直接贴到当前位置**执行。

### 常见用途

```bash
# 加载虚拟环境
source venv/bin/activate

# 加载 .env 文件
source .env

# 加载函数库
source ~/scripts/common.sh
```

### 实用：模块化配置文件

```bash
# config.sh
export DB_HOST="localhost"
export DB_PORT="5432"

# 在其他脚本中使用
source config.sh
psql -h $DB_HOST -p $DB_PORT
```

---

## 6.5 `env`：环境管理

```bash
# 显示所有环境变量
env

# 清除所有环境变量后执行
env -i HOME=/tmp PATH=/bin sh

# 设置环境变量并执行
env VAR1=value1 VAR2=value2 ./my_program
```

### 找命令

```bash
which python      # 找命令的位置
type cd           # 找 shell 内建命令
whereis gcc       # 找所有相关文件
```

---

## 6.6 `sudo`：提升权限

```bash
# 以 root 身份执行
sudo rm /var/log/old.log

# 以特定用户身份执行
sudo -u postgres psql

# 显示会用什么身份执行
sudo -l
```

### 危险警告

```bash
# 千万不要执行这个！
sudo rm -rf /

# 永远不要这样做！
sudo curl http://unknown-site.com | sh
```

---

## 6.7 速查表

| 命令 | 用途 | 常用参数 |
|------|------|----------|
| `chmod` | 改变文件权限 | `+x` 加执行, `755` 八进制, `-R` 递归 |
| `chown` | 改变拥有者 | `user:group`, `-R` 递归 |
| `./script` | 执行脚本（需要 x） | - |
| `bash script` | 执行脚本（不需要 x） | - |
| `source` | 在当前 shell 执行 | - |
| `export` | 设置环境变量 | `-n` 移除 |
| `env` | 显示/管理环境 | `-i` 清除 |
| `sudo` | 以 root 执行 | `-u user` 指定用户 |

---

## 6.8 练习题

1. 创建一个脚本，用 `chmod 755` 设置权限，然后执行它
2. 用 `source` 和 `./` 分别执行同一个设置环境变量的脚本，观察差异
3. 用 `env -i` 创建一个干净环境，执行 `python --version`
4. 创建一个 `.env` 文件，用 `source` 加载其中的变量
