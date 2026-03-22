# 8. Variables and Functions

---

## 8.1 Variable Basics

### Basic Assignment

```bash
# String
name="Alice"
greeting="Hello, World!"

# Number
age=25
count=0

# Empty
empty=
empty2=""
```

### Reading Variables

```bash
echo $name
echo ${name}    # Recommended form, more explicit

# In double quotes
echo "My name is ${name}"
```

### Common Mistakes

```bash
# Wrong: spaces around =
name = "Alice"   # Interpreted as command

# Wrong: no quotes
greeting=Hello World  # Only echoes "Hello"

# Correct:
name="Alice"
greeting="Hello World"
```

---

## 8.2 The Art of Quotes

### Double Quotes `"`
Expand variables and command substitution

```bash
name="Alice"
echo "Hello, $name"           # Hello, Alice
echo "Today is $(date +%Y)"     # Today is 2026
```

### Single Quotes `'`
Output literally, expand nothing

```bash
name="Alice"
echo 'Hello, $name'           # Hello, $name
echo 'Today is $(date +%Y)'     # Today is $(date +%Y)
```

### No Quotes
Avoid unless you're sure variable doesn't contain spaces

---

## 8.3 Special Variables

```bash
$0          # Script name
$1, $2...   # Positional parameters
$#          # Argument count
$@          # All arguments (individual)
$*          # All arguments (as one string)
$?          # Last command's exit code
$$          # Current process PID
$!          # Last background process PID
$-          # Current shell options
```

---

## 8.4 Arrays

### Basic Usage

```bash
# Define array
colors=("red" "green" "blue")

# Read elements
echo ${colors[0]}    # red
echo ${colors[1]}    # green

# Read all
echo ${colors[@]}    # red green blue

# Array length
echo ${#colors[@]}   # 3
```

### Associative Arrays (Bash 4+)

```bash
declare -A user
user["name"]="Alice"
user["email"]="alice@example.com"

echo ${user["name"]}    # Alice
```

---

## 8.5 Function Basics

### Defining Functions

```bash
# Method 1: function keyword
function greet {
    echo "Hello!"
}

# Method 2: direct definition (recommended)
greet() {
    echo "Hello!"
}
```

### Function Parameters

```bash
greet() {
    echo "Hello, $1!"
}

greet "Alice"    # Hello, Alice!
```

### Return Values

```bash
# return: for exit code (0-255)
check() {
    if [[ $1 -gt 10 ]]; then
        return 0  # success
    else
        return 1  # failure
    fi
}

if check 15; then
    echo "Greater than 10"
fi
```

---

## 8.6 Local Variables

```bash
counter() {
    local count=0
    ((count++))
    echo $count
}
```

---

## 8.7 Function Libraries

### Create Library

```bash
cat > lib.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date +%H:%M:%S)] $@"
}

error() {
    echo "[$(date +%H:%M:%S)] ERROR: $@" >&2
}

confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}
EOF
```

### Use Library

```bash
#!/bin/bash

source lib.sh

log "Starting process"
error "Something went wrong"
confirm "Continue?" && echo "Continuing"
```

---

## 8.8 Quick Reference

| Topic | Syntax | Description |
|-------|--------|-------------|
| Assignment | `var=value` | No spaces around = |
| Read | `$var` or `${var}` | Use `${var}` |
| Double quotes | `"..."` | Expand variables |
| Single quotes | `'...'` | No expansion |
| Arguments | `$1`, `$2`, `$@` | Get parameters |
| Function | `name() { }` | recommended definition |
| Local var | `local var=value` | only in function |
| Array | `arr=(a b c)` | indexed and associative |
| source | `source file.sh` | Load library |

---

## 8.9 Exercises

1. Write a script that accepts name and age parameters, outputs "Hello, Y, you are X years old!"
2. Create a library with `log` and `error` functions, use it in another script
3. Write a recursive function to calculate Fibonacci numbers
4. Use `mapfile` to read a file line by line into an array, then output in reverse
