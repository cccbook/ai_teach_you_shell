# 7. Flow Control and Conditional Loops

---

## 7.1 Combining Commands: The Essence of Shell

Single commands have limited capability. Only by **combining** them can you accomplish complex tasks.

AI is powerful largely because it masters these combinations:

```bash
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -10
```

This means: "From access.log, find errors, count occurrences, show top 10"

---

## 7.2 `|` (Pipe): The Art of Data Flow

The pipe turns the **output** of the previous command into the **input** of the next.

```bash
# Sort file content
cat unsorted.txt | sort

# Find most common commands
history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

# Extract IPs from log and count
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
```

### Piping stderr

```bash
# Send stderr to pipe
command1 2>&1 | command2

# Or Bash 4+
command1 |& command2
```

---

## 7.3 `&&`: Execute Next Only If Successful

**Only if `command1` succeeds (exit code = 0) will `command2` execute.**

```bash
# Create directory then cd into it
mkdir -p project && cd project

# Compile then run
gcc -o program source.c && ./program

# Download then extract
curl -L -o archive.tar.gz http://example.com/file && tar -xzf archive.tar.gz
```

---

## 7.4 `||`: Execute Next Only If Failed

**Only if `command1` fails (exit code ≠ 0) will `command2` execute.**

```bash
# Create file if it doesn't exist
[ -f config.txt ] || echo "Config missing" > config.txt

# Try one way, fallback to another
cd /opt/project || cd /home/user/project

# Ensure success even on failure (common in makefiles)
cp file.txt file.txt.bak || true
```

### Combining `&&` and `||`

```bash
# Conditional expression
[ -f config ] && echo "Found" || echo "Not found"

# Equivalent to:
if [ -f config ]; then
    echo "Found"
else
    echo "Not found"
fi
```

---

## 7.5 `;`: Execute Regardless

```bash
# All three execute
mkdir /tmp/test ; cd /tmp/test ; pwd
```

---

## 7.6 `$()`: Command Substitution

**Execute command, replace `$()` with its output.**

```bash
# Basic usage
echo "Today is $(date +%Y-%m-%d)"
# Output: Today is 2026-03-22

# In variables
FILES=$(ls *.txt)

# Get directory name
DIR=$(dirname /path/to/file.txt)
BASE=$(basename /path/to/file.txt)

# Calculate
echo "Result is $((10 + 5))"
# Output: Result is 15
```

### vs Backticks

```bash
# Both are equivalent
echo "Today is $(date +%Y)"
echo "Today is `date +%Y`"

# But $() is better because it can nest
echo $(echo $(echo nested))
```

---

## 7.7 `[[ ]]` and `[ ]`: Conditional Tests

### File Tests

```bash
[[ -f file.txt ]]      # Regular file exists
[[ -d directory ]]     # Directory exists
[[ -e path ]]           # Any type exists
[[ -L link ]]           # Symbolic link exists
[[ -r file ]]           # Readable
[[ -w file ]]           # Writable
[[ -x file ]]           # Executable
[[ file1 -nt file2 ]]  # file1 is newer than file2
```

### String Tests

```bash
[[ -z "$str" ]]        # String is empty
[[ -n "$str" ]]        # String is not empty
[[ "$str" == "value" ]] # Equal
[[ "$str" =~ pattern ]]  # Match regex
```

### Numeric Tests

```bash
[[ $num -eq 10 ]]      # Equal
[[ $num -ne 10 ]]      # Not equal
[[ $num -gt 10 ]]      # Greater than
[[ $num -lt 10 ]]      # Less than
```

---

## 7.8 `if`: Conditional Statements

```bash
if [[ condition ]]; then
    # do something
elif [[ condition2 ]]; then
    # do something else
else
    # fallback
fi
```

### Complete Example

```bash
#!/bin/bash

FILE="config.yaml"

if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE does not exist"
    exit 1
fi

if [[ -r "$FILE" ]]; then
    echo "File is readable"
else
    echo "File is not readable"
fi
```

---

## 7.9 `for`: Loops

### Basic Syntax

```bash
for variable in list; do
    # use $variable
done
```

### AI's Common Patterns

```bash
# Process all .txt files
for file in *.txt; do
    echo "Processing $file"
done

# Number range
for i in {1..10}; do
    echo "Iteration $i"
done

# Array
for color in red green blue; do
    echo $color
done

# C-style loop (Bash 3+)
for ((i=0; i<10; i++)); do
    echo $i
done
```

---

## 7.10 `while`: Conditional Loops

```bash
# Read lines
while IFS= read -r line; do
    echo "Read: $line"
done < file.txt

# Counting loop
count=0
while [[ $count -lt 10 ]]; do
    echo $count
    ((count++))
done
```

---

## 7.11 `case`: Pattern Matching

```bash
case $ACTION in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

### Wildcard Patterns

```bash
case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.jpg|*.png|*.gif)
        echo "Image file"
        ;;
    *)
        echo "Unknown type"
        ;;
esac
```

---

## 7.12 Quick Reference

| Symbol | Name | Description |
|--------|------|-------------|
| `\|` | Pipe | Pass output to next input |
| `&&` | AND | Execute next only if previous succeeds |
| `\|\|` | OR | Execute next only if previous fails |
| `;` | Semicolon | Execute regardless |
| `$()` | Command substitution | Execute, replace with output |
| `[[ ]]` | Conditional test | recommended test syntax |
| `if` | Conditional | branch based on condition |
| `for` | Count loop | iterate through list |
| `while` | Conditional loop | repeat while condition true |
| `case` | Pattern match | multi-way branch |

---

## 7.13 Exercises

1. Use `|` to combine `ls`, `grep`, `wc` to count `.log` files
2. Use `&&` to ensure `cd` succeeds before continuing
3. Use `for` loop to create 10 directories (dir1 to dir10)
4. Use `while read` to read and display /etc/hosts
5. Write a simple calculator with `case` (add, sub, mul, div)
