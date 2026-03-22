# 4. 文字生成与写入

---

## 4.1 为什么 AI 不需要编辑器

大多数人类工程师写代码的流程是：
1. 打开编辑器（VS Code、Vim、Emacs...）
2. 输入代码
3. 保存文件
4. 关闭编辑器

对 AI 来说：
```
「写一个 Python 程序」 = 产生一段文字
「把这个程序存成文件」 = 把文字写入磁盘
```

AI 使用的核心工具：
- `echo`：输出单行文字
- `printf`：格式化输出
- `heredoc`：输出多行文字（最重要！）

---

## 4.2 `echo`：最简单的输出

### 基本用法

```bash
# 输出字符串
echo "Hello, World!"

# 输出变量
name="Alice"
echo "Hello, $name!"

# 输出多个值
echo "今天是 $(date +%Y-%m-%d)"
```

### `echo` 的陷阱

```bash
# echo 默认会换行
echo -n "Loading: "  # 不换行
```

### 用 `echo` 写入文件

```bash
# 覆盖写入
echo "Hello, World!" > file.txt

# 附加到文件末尾
echo "第二行" >> file.txt
```

**注意**：用 `echo` 写多行文件很痛苦，所以 AI 几乎不用它写代码。`heredoc` 才是主角。

---

## 4.3 `printf`：更强大的格式化输出

### 与 `echo` 的比较

```bash
# printf 支持 C 语言风格的格式化
printf "Value: %.2f\n" 3.14159
# 输出：Value: 3.14

printf "%s\t%s\n" "名称" "年龄"
```

### 制作表格

```bash
printf "%-15s %10s\n" "名称" "价格"
printf "%-15s %10.2f\n" "iPhone" 999.99
printf "%-15s %10.2f\n" "MacBook" 1999.99
```

---

## 4.4 heredoc：AI 写代码的核心武器

### heredoc 是什么？

heredoc 是 Shell 的一个特殊语法，用于**原样输出多行文字**。

```bash
cat << 'EOF'
这里的所有内容
都会被原样输出
包括换行、空格
EOF
```

### 写入文件（AI 最常用的方式）

```bash
cat > program.py << 'EOF'
#!/usr/bin/env python3

def hello(name):
    print(f"Hello, {name}!")

if __name__ == "__main__":
    hello("World")
EOF
```

### 为什么用 `'EOF'`（单引号）？

```bash
# 单引号 EOF：不解释任何变量或命令
cat << 'EOF'
HOME 是: $HOME
今天是: $(date)
EOF
# 输出：HOME 是: $HOME（不展开）

# 双引号 EOF 或无引号：会展开变量
cat << EOF
HOME 是: $HOME
EOF
# 输出：HOME 是: /home/ai（展开）
```

**AI 的选择**：几乎总用 `'EOF'`（单引号）。因为代码通常不需要 Shell 变量展开。

---

## 4.5 AI 用 heredoc 写各种文件

### 写 Python 程序

```bash
cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""主程序入口"""

import sys
import os

def main():
    print("Python + C 混合项目")
    print(f"工作目录: {os.getcwd()}")

if __name__ == "__main__":
    main()
EOF
```

### 写 Shell 脚本

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

DEPLOY_HOST="server.example.com"

echo "🚀 开始部署到 $DEPLOY_HOST"
rsync -avz --delete ./dist/ "$DEPLOY_HOST:/var/www/app/"
ssh "$DEPLOY_HOST" "systemctl restart myapp"
echo "✅ 部署完成！"
EOF

chmod +x scripts/deploy.sh
```

### 写配置文件

```bash
cat > config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF
```

### 写 Docker 文件

```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "http.server", "8000"]
EOF
```

---

## 4.6 heredoc 的陷阱与解决方案

### 陷阱 1：包含单引号

```bash
# 问题：单引号 EOF 不允许单引号
cat << 'EOF'
He's going.
EOF
# 输出：语法错误

# 解决：用双引号 EOF
cat << "EOF"
He's going.
EOF
```

### 陷阱 2：包含 `$` 字符（但不想要展开）

```bash
# 问题：双引号 EOF 会展开 $
cat << "EOF"
价格是 $100
EOF
# 输出：价格是（空）

# 解决：个别 escape
cat << "EOF"
价格是 $$100
EOF
# 输出：价格是 $100
```

### 陷阱 3：包含 EOF 作为文字内容

```bash
# 解决：用其他 delimiter
cat << 'ENDOFLETTER'
Dear valued customer,
Best regards,
ENDOFLETTER
```

---

## 4.7 实战：从无到有建立一个完整的项目

```bash
# 1. 建立目录结构
mkdir -p myblog/{src,themes,content}

# 2. 建立配置文件
cat > myblog/config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF

# 3. 建立 Python 主程序
cat > myblog/src/blog.py << 'EOF'
#!/usr/bin/env python3
"""Simple blog generator"""
import json
from pathlib import Path

def load_config():
    config_path = Path(__file__).parent.parent / "config.json"
    with open(config_path) as f:
        return json.load(f)

if __name__ == "__main__":
    config = load_config()
    print(f"Generating: {config['site_name']}")
EOF

# 4. 建立构建脚本
cat > myblog/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🔨 Building blog..."
cd "$(dirname "$0")"
python3 src/blog.py
echo "✅ Build complete!"
EOF

chmod +x myblog/build.sh

# 5. 验证结构
find myblog -type f | sort
```

**这个脚本执行后，会建立一个完整的博客项目，没有使用任何编辑器。**

---

## 4.8 速查表

| 工具 | 用途 | 示例 |
|------|------|------|
| `echo` | 输出单行文字 | `echo "Hello"` |
| `echo -n` | 输出不换行 | `echo -n "Loading..."` |
| `printf` | 格式化输出 | `printf "%s: %d\n" "age" 25` |
| `>` | 覆盖写入文件 | `echo "hi" > file.txt` |
| `>>` | 附加到文件末尾 | `echo "hi" >> file.txt` |
| `<< 'EOF'` | heredoc（不解释变量） | 写代码首选 |
| `<< "EOF"` | heredoc（展开变量） | 少用 |

---

## 4.9 练习题

1. 用 `echo -n` 和 `for` 循环做一个 Loading 动画
2. 用 `printf` 制作一个格式化表格（姓名、年龄、职业）
3. 用 heredoc 写一个 20 行的 Python 程序
4. 用 heredoc 写一个 docker-compose.yml
