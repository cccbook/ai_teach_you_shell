# 9. Error Handling

---

## 9.1 Why Error Handling Matters

Without error handling:
- After one command fails, continue with wrong operations
- May delete wrong files
- May overwrite important data
- May leave system in inconsistent state

With error handling:
- Stop immediately on error
- Provide meaningful error messages
- Clean up before exiting

---

## 9.2 Exit Codes

Every command returns an exit code after execution:

- `0`: success
- `non-zero`: failure

```bash
# Check last command's exit code
ls /tmp
echo $?  # Output: 0 (if successful)

ls /nonexistent
echo $?  # Output: 2 (if failed)
```

---

## 9.3 `set -e`: Stop on Error

```bash
#!/bin/bash
set -e

mkdir -p backup
cp important.txt backup/  # If this fails, script stops here
rm important.txt          # Won't reach here
```

### When to Use

Almost all scripts should use `set -e`:
- Initialization scripts
- Deployment scripts
- Automated test scripts

---

## 9.4 `set -u`: Error on Undefined Variables

```bash
#!/bin/bash
set -u

echo $undefined_var
# Output: bash: undefined_var: unbound variable
```

### Combined Usage

```bash
#!/bin/bash
set -euo pipefail

# -e: stop on error
# -u: error on undefined variable
# -o pipefail: pipe fails if any command fails
```

**This is AI's standard script header!**

---

## 9.5 `trap`: Graceful Error Handling

### Basic Usage

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# Main program
echo "Starting process..."
```

### Capture Errors

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    echo "❌ Script failed at line $1, exit code: $exit_code"
    exit $exit_code
}

trap 'error_handler $LINENO' ERR
```

---

## 9.6 Custom Error Functions

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "❌ $@" >&2
    exit 1
}

warn() {
    echo "⚠️ $@"
}

need_command() {
    command -v "$1" &>/dev/null || die "Required command: $1"
}

need_file() {
    [[ -f "$1" ]] || die "Required file: $1"
}
```

---

## 9.7 Quick Reference

| Command | Description |
|---------|-------------|
| `$?` | Last command's exit code |
| `set -e` | Stop on error |
| `set -u` | Error on undefined variable |
| `set -o pipefail` | Pipe fails if any command fails |
| `set -euo pipefail` | Combined (recommended) |
| `trap 'func' EXIT` | Execute on exit |
| `trap 'func' ERR` | Execute on error |
| `trap 'func' INT` | Execute on Ctrl+C |
| `exit 1` | Exit with error code 1 |

---

## 9.8 Exercises

1. Write a script with `set -euo pipefail` that outputs "Error occurred" on failure
2. Create a `die()` function that prints message and exits
3. Use `trap` to display "Goodbye" when script exits
4. Write a deployment script with automatic rollback on failure
