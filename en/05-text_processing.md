# 5. Text Processing

---

## 5.1 AI's Text Processing Philosophy

In AI's world, **everything is text**.

- Code is text
- Config files are text
- Logs are text
- JSON, HTML, Markdown are all text

So text processing commands are the core of AI's toolkit.

When human engineers encounter problems: "I need a tool to handle this..."
When AI encounters problems: "This can be solved with `grep | sed | awk` in one line."

---

## 5.2 `cat`: The Art of Reading Files

### Basic Usage

```bash
# Display file content
cat file.txt

# Combine files
cat part1.txt part2.txt > whole.txt

# Show line numbers
cat -n script.sh
```

### Real Purpose: Combining and Creating

```bash
cat << 'EOF' > newfile.txt
File content
Can write many lines
EOF
```

---

## 5.3 `head` and `tail`: Seeing Only What You Need

### `head`: Look at the Beginning

```bash
# First 10 lines (default)
head file.txt

# First 5 lines
head -n 5 file.txt

# First 100 bytes
head -c 100 file.txt
```

### `tail`: Look at the End

```bash
# Last 10 lines (default)
tail file.txt

# Last 5 lines
tail -n 5 file.txt

# Follow file in real-time (most common!)
tail -f /var/log/syslog

# Follow and grep
tail -f app.log | grep --line-buffered ERROR
```

### View Specific Line Range

```bash
# View lines 100-150
tail -n +100 file.txt | head -n 50
```

---

## 5.4 `wc`: Counting Tool

```bash
# Count lines
wc -l file.txt

# Count lines for multiple files
wc -l *.py

# Count files in directory
ls | wc -l
```

---

## 5.5 `grep`: King of Text Search

### Basic Usage

```bash
# Search for "error" lines
grep "error" log.txt

# Ignore case
grep -i "error" log.txt

# Show line numbers
grep -n "error" log.txt

# Show only filenames
grep -l "TODO" *.md

# Reverse (non-matching lines)
grep -v "debug" log.txt

# Whole word match
grep -w "error" log.txt
```

### Regular Expressions

```bash
# Match beginning
grep "^Error" log.txt

# Match end
grep "done.$" log.txt

# Any character
grep "e.or" log.txt

# Range
grep -E "[0-9]{3}-" log.txt
```

### Advanced Techniques

```bash
# Recursive search
grep -r "TODO" src/

# Only specific extension
grep -r "TODO" --include="*.py" src/

# Show context lines
grep -B 2 -A 2 "ERROR" log.txt

# Multiple conditions (OR)
grep -E "error|warning|fatal" log.txt
```

---

## 5.6 `sed`: Text Replacement Tool

### Basic Replacement

```bash
# Replace first match
sed 's/old/new/' file.txt

# Replace all matches
sed 's/old/new/g' file.txt

# In-place replacement
sed -i 's/old/new/g' file.txt

# Backup then replace
sed -i.bak 's/old/new/g' file.txt
```

### Delete Lines

```bash
# Delete empty lines
sed '/^$/d' file.txt

# Delete comment lines
sed '/^#/d' file.txt

# Delete trailing whitespace
sed 's/[[:space:]]*$//' file.txt
```

### Practical Examples

```bash
# Batch rename extensions (.txt → .md)
for f in *.txt; do
    mv "$f" "$(sed 's/.txt$/.md/' <<< "$f")"
done

# Remove Windows line endings
sed -i 's/\r$//' file.txt
```

---

## 5.7 `awk`: Swiss Army Knife of Text Processing

### Basic Concept

`awk` processes text line by line, automatically splitting into fields ($1, $2, $3...), executing specified actions for each line.

### Basic Usage

```bash
# Default whitespace splitting
awk '{print $1}' file.txt

# Specify delimiter
awk -F: '{print $1}' /etc/passwd

# Output multiple fields
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### Conditional Processing

```bash
# Only process matching lines
awk -F: '$3 > 1000 {print $1}' /etc/passwd

# BEGIN and END
awk 'BEGIN {print "Start"} {print} END {print "Done"}' file.txt
```

### Practical Examples

```bash
# Sum a CSV column
awk -F, '{sum += $3} END {print sum}' data.csv

# Find maximum
awk 'NR==1 {max=$3} $3>max {max=$3} END {print max}' data.csv

# Formatted output
awk '{printf "%-20s %10.2f\n", $1, $2}' data.txt
```

---

## 5.8 Practice: Combining All Tools

### Scenario: Analyze Server Logs

```bash
# 1. Find error messages
grep -i "error" access.log

# 2. Count errors
grep -ci "error" access.log

# 3. Find most common errors
grep "error" access.log | awk '{print $NF}' | sort | uniq -c | sort -rn | head

# 4. Count requests per hour
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c
```

### Scenario: Batch Modify Code

```bash
# Change "print" to "logger.info" in all .py files
find . -name "*.py" -exec sed -i 's/print(/logger.info(/g' {} +

# Change var to const
find . -name "*.js" -exec sed -i 's/\bvar\b/const/g' {} +
```

---

## 5.9 Quick Reference

| Command | Purpose | Common Flags |
|---------|---------|--------------|
| `cat` | Display/combine files | `-n` line numbers |
| `head` | View file beginning | `-n` lines, `-c` bytes |
| `tail` | View file end | `-n` lines, `-f` follow |
| `wc` | Counting | `-l` lines, `-w` words, `-c` bytes |
| `grep` | Text search | `-i` ignore, `-n` line number, `-r` recursive, `-c` count |
| `sed` | Text replacement | `s/old/new/g`, `-i` in-place |
| `awk` | Field processing | `-F` delimiter, `{print}` action |

---

## 5.10 Exercises

1. Use `head` and `tail` to view lines 100-120
2. Use `grep` to find all users with `/bin/bash` in /etc/passwd
3. Use `sed` to replace all `\r\n` with `\n`
4. Use `awk` to calculate max, min, and average of a numeric file
