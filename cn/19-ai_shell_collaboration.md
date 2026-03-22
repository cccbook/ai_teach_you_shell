# 19. AI + Shell 的协作模式

---

## 19.1 人机协作的新形态

传统的程序设计：
- 人类用键盘输入
- 人类用鼠标操作 IDE
- 人类执行和测试

AI 时代的程序设计：
- 人类描述需求
- AI 生成 Shell 命令和脚本
- 人类审查和执行
- 人类和 AI 一起调试

---

## 19.2 描述需求给 AI

### 好的描述

```bash
# 明确的任务
"找出 /var/log 目录下所有大于 100MB 的 .log 文件"

# 包含预期输出格式
"列出所有 .py 文件，每行显示：行数 文件名"

# 说明限制条件
"把所有 .txt 文件压缩，但跳过任何包含 'test' 的文件"
```

### 不好的描述

```bash
# 太模糊
"帮我处理日志"

# 不切实际
"帮我写一个操作系统"
```

---

## 19.3 AI 生成的 Shell 命令模式

### 模式 1：一行命令

```bash
# 人类问：找出行数最多的 10 个 Python 文件
find . -name "*.py" -exec wc -l {} + | sort -rn | head -10
```

### 模式 2：Shell 脚本

```bash
# 人类问：批量处理图片
cat > process_images.sh << 'EOF'
#!/bin/bash
for img in *.jpg; do
    convert "$img" -resize 800x600 "thumb_$img"
done
EOF
```

### 模式 3：完整工具

```bash
# 人类问：写一个 HTTP 服务器健康检查工具
cat > health-check.sh << 'EOF'
#!/bin/bash
URLS=(
    "https://api.example.com/health"
    "https://web.example.com"
)

for url in "${URLS[@]}"; do
    if curl -sf "$url" &>/dev/null; then
        echo "✓ $url OK"
    else
        echo "✗ $url FAILED"
    fi
done
EOF
```

---

## 19.4 迭代式开发

### 第一轮：生成初版

```bash
# 人类：帮我写一个备份脚本
```

AI 生成初版，然后人类测试、提出问题：

```bash
# 人类：好，但需要支持 --dry-run 模式
```

### 第二轮：加入功能

```bash
# 人类：再加入错误处理和日志
```

### 第三轮：调试

```bash
# 人类：执行后报错 'Permission denied'
# AI：修复这个问题...
```

---

## 19.5 AI 帮你写 Prompt

有时候你不知道怎麼描述需求，这时可以让 AI 帮你：

```bash
# 人类：我想批量重命名图片，但我不知道怎么描述
# AI：试试这样描述：
# "批量处理所有 .jpg 文件：
#  1. 从 EXIF 读取拍摄日期
#  2. 重命名为 YYYY-MM-DD_originalname.jpg
#  3. 建立缩图 thumb_YYYY-MM-DD_originalname.jpg"
```

---

## 19.6 让 AI 审查你的脚本

```bash
# 人类：审查这个脚本的安全问题
# （贴上脚本）

# AI 回应：
# 1. 第 15 行：rm 没有绝对路径，可能误删
# 2. 第 23 行：变量未加引号
# 3. 缺少 set -euo pipefail
```

---

## 19.7 让 AI 解释别人的脚本

```bash
# 人类：解释这个脚本做什么
# （贴上别人的脚本）

# AI 回应：
# 这是一个 Nginx 日志分析脚本：
# - 统计 HTTP 状态码分布
# - 找出最慢的 20 个请求
# - 识别错误模式
```

---

## 19.8 AI 帮你调试

```bash
# 人类：执行这个命令后报错
$ ./deploy.sh
# 输出：/bin/bash^M: bad interpreter: No such file or directory

# AI：这是 Windows 换行符问题。执行：
sed -i 's/\r$//' deploy.sh
```

---

## 19.9 实战：AI 帮你建立项目

```bash
# 人类：建立一个 Flask 项目，包含：
# - 标准目录结构
# - Flask 最小示例
# - requirements.txt
# - Dockerfile
# - docker-compose.yml
# - GitHub Actions CI

# AI：
cat > init-flask.sh << 'EOF'
#!/bin/bash
mkdir -p app/{routes,templates,static}
touch app/__init__.py app/routes/__init__.py
# ... 完整生成 ...
EOF
```

---

## 19.10 协作工具推荐

### 终端多工

```bash
# tmux：分割窗口
tmux new -s mysession
# Ctrl+b %  # 垂直分割
# Ctrl+b "  # 水平分割
```

### AI 接口

- 直接在终端调用 AI CLI
- 用管道把命令传给 AI
- 让 AI 直接修改文件

### 版本控制

```bash
# 每次重大改动都 commit
git add .
git commit -m "AI: 加入 XXX 功能"
```

---

## 19.11 练习题

1. 描述一个复杂的任务，让 AI 生成 Shell 命令
2. 用 AI 帮你审查一个现有的脚本
3. 用迭代方式让 AI 帮你写一个实用的工具
4. 用 AI 帮你解释一段你不理解的 Shell 代码