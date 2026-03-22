# 4. Text Generation and Writing

---

## 4.1 Why AI Doesn't Need an Editor

Most human engineers' workflow for writing code:
1. Open editor (VS Code, Vim, Emacs...)
2. Type code
3. Save file
4. Close editor

For AI:
```
"Write a Python program" = generate some text
"Save this program to a file" = write text to disk
```

AI's code generation process is a **text generation process**. So AI uses Shell's text tools:

- `echo`: output single line of text
- `printf`: formatted output
- `heredoc`: output multi-line text (most important!)

---

## 4.2 `echo`: Simplest Output

### Basic Usage

```bash
# Output string
echo "Hello, World!"

# Output variable
name="Alice"
echo "Hello, $name!"

# Output multiple values
echo "Today is $(date +%Y-%m-%d)"
```

### `echo` Traps

```bash
# echo adds newline by default
echo -n "Loading: "  # No newline
```

### Writing Files with `echo`

```bash
# Overwrite
echo "Hello, World!" > file.txt

# Append
echo "Second line" >> file.txt
```

**Note**: Using `echo` for multi-line files is painful, so AI almost never uses it for code. `heredoc` is the star.

---

## 4.3 `printf`: More Powerful Formatted Output

### Comparison with `echo`

```bash
# printf supports C-style formatting
printf "Value: %.2f\n" 3.14159
# Output: Value: 3.14

printf "%s\t%s\n" "Name" "Age"
```

### Creating Tables

```bash
printf "%-15s %10s\n" "Name" "Price"
printf "%-15s %10.2f\n" "iPhone" 999.99
printf "%-15s %10.2f\n" "MacBook" 1999.99
```

---

## 4.4 heredoc: AI's Core Weapon for Writing Code

### What is heredoc?

heredoc is a special Shell syntax for **outputting multi-line text verbatim**.

```bash
cat << 'EOF'
All this content
will be output verbatim
including newlines, spaces
EOF
```

### Writing Files (AI's Most Common Use)

```bash
cat > program.py << 'EOF'
#!/usr/bin/env python3

def hello(name):
    print(f"Hello, {name}!")

if __name__ == "__main__":
    hello("World")
EOF
```

### Why Use `'EOF'` (Single Quote)?

```bash
# Single quote EOF: don't expand anything
cat << 'EOF'
HOME is: $HOME
Today is: $(date)
EOF
# Output: HOME is: $HOME (not expanded)

# Double quote EOF or no quotes: will expand
cat << EOF
HOME is: $HOME
EOF
# Output: HOME is: /home/ai (expanded)
```

**AI's choice**: almost always use `'EOF'` (single quote). Because code usually doesn't need Shell variable expansion.

---

## 4.5 AI Writes Various Files with heredoc

### Write Python Program

```bash
cat > src/main.py << 'EOF'
#!/usr/bin/env python3
"""Main entry point"""

import sys
import os

def main():
    print("Python + C Hybrid Project")
    print(f"Working directory: {os.getcwd()}")

if __name__ == "__main__":
    main()
EOF
```

### Write Shell Script

```bash
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e

DEPLOY_HOST="server.example.com"

echo "🚀 Deploying to $DEPLOY_HOST"
rsync -avz --delete ./dist/ "$DEPLOY_HOST:/var/www/app/"
ssh "$DEPLOY_HOST" "systemctl restart myapp"
echo "✅ Deploy complete!"
EOF

chmod +x scripts/deploy.sh
```

### Write Config File

```bash
cat > config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF
```

### Write Dockerfile

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

## 4.6 heredoc Traps and Solutions

### Trap 1: Contains Single Quotes

```bash
# Problem: single quote EOF doesn't allow single quotes
cat << 'EOF'
He's going.
EOF
# Output: syntax error

# Solution: use double quote EOF
cat << "EOF"
He's going.
EOF
```

### Trap 2: Contains `$` (But Don't Want Expansion)

```bash
# Problem: double quote EOF expands $
cat << "EOF"
Price is $100
EOF
# Output: Price is (empty)

# Solution: escape individually
cat << "EOF"
Price is $$100
EOF
# Output: Price is $100
```

---

## 4.7 Practice: Building a Complete Project from Scratch

```bash
# 1. Create directory structure
mkdir -p myblog/{src,themes,content}

# 2. Create config file
cat > myblog/config.json << 'EOF'
{
    "site_name": "My Blog",
    "author": "Anonymous",
    "theme": "minimal"
}
EOF

# 3. Create Python main program
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

# 4. Create build script
cat > myblog/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🔨 Building blog..."
cd "$(dirname "$0")"
python3 src/blog.py
echo "✅ Build complete!"
EOF

chmod +x myblog/build.sh

# 5. Verify structure
find myblog -type f | sort
```

---

## 4.8 Quick Reference

| Tool | Purpose | Example |
|------|---------|---------|
| `echo` | Output single line | `echo "Hello"` |
| `echo -n` | No newline | `echo -n "Loading..."` |
| `printf` | Formatted output | `printf "%s: %d\n" "age" 25` |
| `>` | Overwrite file | `echo "hi" > file.txt` |
| `>>` | Append to file | `echo "hi" >> file.txt` |
| `<< 'EOF'` | heredoc (no expansion) | preferred for code |
| `<< "EOF"` | heredoc (expand) | rarely used |

---

## 4.9 Exercises

1. Create a Loading animation with `echo -n` and `for` loop
2. Create a formatted table (name, age, job) with `printf`
3. Write a 20-line Python program with heredoc
4. Write a docker-compose.yml with heredoc
