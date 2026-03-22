# 16. Debugging Techniques

---

## 16.1 AI's Debugging Mindset

When humans encounter errors: panic, search online, copy-paste
When AI encounters errors: analyze message, infer cause, execute fix

AI's debugging flow:
```
Observe error output → Understand error type → Locate problem → Fix → Verify
```

---

## 16.2 `bash -x`: Trace Execution

Simplest debugging: add `-x` flag

```bash
bash -x script.sh
```

Outputs each executed line with `+` prefix:

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### Debug Only a Section

```bash
#!/bin/bash

echo "This won't show"
set -x
# Debugging starts here
name="Alice"
echo "Hello, $name"
set +x
# Debugging ends here
echo "This won't show"
```

---

## 16.3 Common Errors and Fixes

### Error 1: Permission Denied

```bash
# Error
./script.sh
# Output: Permission denied

# Fix
chmod +x script.sh
./script.sh
```

### Error 2: Command Not Found

```bash
# Error
python script.py
# Output: command not found: python

# Fix: use full path
/usr/bin/python3 script.py
```

### Error 3: Undefined Variable

```bash
#!/bin/bash
set -u

echo $undefined_var
# Output: bash: undefined_var: unbound variable

# Fix: give default value
echo ${undefined_var:-default}
```

---

## 16.4 `echo` Debugging

When `-x` isn't enough, manually add `echo`:

```bash
#!/bin/bash

echo "DEBUG: Entering function"
echo "DEBUG: Parameter = $@"

process() {
    echo "DEBUG: In process"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
}
```

---

## 16.5 Quick Reference

| Command | Description |
|---------|-------------|
| `bash -n script.sh` | Check syntax only |
| `bash -x script.sh` | Trace execution |
| `set -x` | Enable debug mode |
| `set +x` | Disable debug mode |
| `trap 'echo cmd' DEBUG` | Trace every command |

---

## 16.6 Exercises

1. Execute a script with `bash -x` and observe the output format
2. Use `set -x` in a script to debug only a specific function
3. Find a command that fails, analyze the error message, and fix it
4. Create graceful error handling with `trap`
