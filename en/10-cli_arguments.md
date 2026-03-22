# 10. Argument Parsing and CLI Tools

---

## 10.1 Command Line Arguments Basics

```bash
#!/bin/bash

echo "Script: $0"
echo "First arg: $1"
echo "Second arg: $2"
echo "Third arg: ${3:-default}"  # default value
echo "Arg count: $#"
echo "All args: $@"
```

### Execution

```bash
./script.sh foo bar
# Output:
# Script: ./script.sh
# First arg: foo
# Second arg: bar
# Third arg: default
# Arg count: 2
# All args: foo bar
```

---

## 10.2 Simple Argument Parsing

### Positional Parameters

```bash
#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <file>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "Error: file does not exist"
    exit 1
fi

echo "Processing $FILE..."
```

### Handling Optional Arguments

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

$VERBOSE && echo "verbose mode on"
[[ -n "$OUTPUT" ]] && echo "Output to: $OUTPUT"
```

---

## 10.3 `getopts`: Standard Option Parsing

```bash
#!/bin/bash

while getopts "hv:o:" opt; do
    case $opt in
        h)
            echo "Help info"
            exit 0
            ;;
        v)
            echo "verbose mode: $OPTARG"
            ;;
        o)
            echo "output file: $OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "Remaining args: $@"
```

### Option Format Reference

| Format | Meaning |
|--------|---------|
| `getopts "hv:"` | `-h` no arg, `-v` needs arg |
| `OPTARG` | Current option's argument value |
| `OPTIND` | Next argument index |

---

## 10.4 Interactive Input

### `read`: Read User Input

```bash
#!/bin/bash

# Basic read
read -p "Enter your name: " name
echo "Hello, $name"

# Password (hidden)
read -sp "Enter password: " password
echo

# Read multiple values
read -p "Enter name and age: " name age
echo "$name is $age years old"

# Timeout
read -t 5 -p "Enter within 5 seconds: " value
```

### Confirmation Prompt

```bash
confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

if confirm "Delete this file?"; then
    echo "Deleting..."
fi
```

---

## 10.5 Menu Interface

```bash
#!/bin/bash

PS3="Select operation: "

select choice in "Create project" "Delete project" "Exit"; do
    case $choice in
        "Create project")
            echo "Creating..."
            ;;
        "Delete project")
            echo "Deleting..."
            ;;
        "Exit")
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done
```

---

## 10.6 Quick Reference

| Syntax | Description |
|--------|-------------|
| `$0` | Script name |
| `$1`, `$2`... | Positional parameters |
| `$#` | Argument count |
| `${var:-default}` | Default value |
| `getopts "hv:" opt` | Parse options |
| `$OPTARG` | Current option's arg |
| `read -p "prompt:" var` | Read input |
| `read -s var` | Hidden input (password) |
| `read -t 5 var` | 5 second timeout |
| `select` | Menu interface |

---

## 10.7 Exercises

1. Write a CLI tool accepting `-n` for count, `-v` for verbose
2. Use `getopts` to parse `-h` (help), `-o` (output file) options
3. Write a confirmation function that only proceeds on y answer
4. Create a simple calculator menu with `select`
