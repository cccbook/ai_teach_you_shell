# 18. Reading and Modifying Others' Scripts

---

## 18.1 Why Read Others' Scripts

- Taking over project maintenance
- Using open source tools
- Debugging issues
- Learning new techniques

AI encounters unfamiliar scripts daily, so learning to quickly understand Shell scripts written by others is essential.

---

## 18.2 Initial Observation

### Step 1: Check shebang

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # Use bash
#!/bin/sh        # Use POSIX sh (more compatible)
```

### Step 2: Check permissions and size

```bash
ls -la script.sh
wc -l script.sh
```

### Step 3: Quick syntax check

```bash
bash -n script.sh  # Check syntax only, don't execute
```

---

## 18.3 Understanding Structure

### Typical Structure

```bash
#!/bin/bash
# Comment: script description

# Setup
set -euo pipefail
VAR="value"

# Function definitions
function help() { ... }

# Main flow
main() { ... }

# Execute
main "$@"
```

### Find Main Flow

```bash
# Check last lines
tail -20 script.sh

# Find function definitions
grep -n "^function\|^[[:space:]]*[a-z_]*\(" script.sh
```

---

## 18.4 Common Analysis Commands

```bash
# Find all function definitions
grep -n "^[[:space:]]*function" script.sh

# Find all conditionals
grep -n "if\|\[\[" script.sh

# Find all loops
grep -n "for\|while\|do\|done" script.sh

# Find command substitutions
grep -n '\$(' script.sh

# Find all exits
grep -n "exit" script.sh
```

---

## 18.5 Security Checks

```bash
# Find dangerous commands
grep -n "rm -rf" script.sh
grep -n "sudo" script.sh
grep -n "eval" script.sh

# Check variable injection risks
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh
```

---

## 18.6 Exercises

1. Analyze an existing Shell script with `grep` and `awk`
2. Find all variables in a script and understand their purposes
3. Use `bash -n` to check a script's syntax
4. Add comments to an uncommented script explaining each section
