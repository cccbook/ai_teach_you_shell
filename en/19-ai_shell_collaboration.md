# 19. AI + Shell Collaboration

---

## 19.1 New Form of Human-Machine Collaboration

Traditional programming:
- Humans type with keyboard
- Humans use mouse to operate IDE
- Humans execute and test

Programming in the AI era:
- Humans describe requirements
- AI generates Shell commands and scripts
- Humans review and execute
- Humans and AI debug together

---

## 19.2 Describing Requirements to AI

### Good Descriptions

```bash
# Clear task
"Find all .log files larger than 100MB in /var/log"

# Include expected output format
"List all .py files, showing: line_count filename per line"

# State constraints
"Compress all .txt files, but skip any containing 'test'"
```

### Bad Descriptions

```bash
# Too vague
"help me process logs"

# Unrealistic
"help me write an operating system"
```

---

## 19.3 AI-Generated Shell Command Patterns

### Pattern 1: Single Command

```bash
# Human asks: find top 10 Python files with most lines
find . -name "*.py" -exec wc -l {} + | sort -rn | head -10
```

### Pattern 2: Shell Script

```bash
# Human asks: batch process images
cat > process_images.sh << 'EOF'
#!/bin/bash
for img in *.jpg; do
    convert "$img" -resize 800x600 "thumb_$img"
done
EOF
```

---

## 19.4 Iterative Development

### Round 1: Generate Initial Version

```bash
# Human: write a backup script
# AI generates initial version, then human tests, raises issues:

# Human: good, but need --dry-run mode
```

### Round 2: Add Features

```bash
# Human: also add error handling and logging
```

### Round 3: Debug

```bash
# Human: got 'Permission denied' error after running
# AI: fixes the problem...
```

---

## 19.5 Let AI Help Debug

```bash
# Human: got error after running this command
$ ./deploy.sh
# Output: /bin/bash^M: bad interpreter: No such file or directory

# AI: this is a Windows line ending problem. Run:
sed -i 's/\r$//' deploy.sh
```

---

## 19.6 Recommended Collaboration Tools

### Terminal Multiplexer

```bash
# tmux: split windows
tmux new -s mysession
# Ctrl+b %  # vertical split
# Ctrl+b "  # horizontal split
```

---

## 19.7 Exercises

1. Describe a complex task and have AI generate Shell commands
2. Have AI review an existing script for security issues
3. Use iteration to have AI help write a practical tool
4. Have AI help explain Shell code you don't understand
