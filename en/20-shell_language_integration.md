# 20. Bridging Shell with Other Languages

---

## 20.1 What Tasks Should Use Shell?

Tasks Shell excels at:
- File operations
- System administration
- Automation workflows
- Pipeline composition
- Quick prototypes

Tasks better suited for other languages:
- Complex data processing (Python, AWK)
- Web programming (JavaScript, Go)
- Numerical computation (Python, R, Julia)
- Systems programming (C, Rust)

---

## 20.2 Shell Calls Python

### Simple Invocation

```bash
#!/bin/bash

# Call Python script
python3 process_data.py input.csv

# Pass arguments
python3 script.py arg1 arg2

# Get output
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### Embed Python in Shell

```bash
#!/bin/bash

python3 << 'PYEOF'
import csv

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['amount']) for row in reader)
    print(f"Total: {total}")
PYEOF
```

---

## 20.3 Python Calls Shell

### Using `subprocess`

```python
import subprocess

# Run simple command
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# Run complex command
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
```

---

## 20.4 Shell Calls JavaScript/Node.js

```bash
#!/bin/bash

# Execute Node.js command
node -e "console.log('hello from node')"

# Execute Node.js script
node process-json.js data.json
```

---

## 20.5 Bridging Tools

### `jq`: JSON Processing

```bash
# Parse JSON
echo '{"name": "Alice", "age": 25}' | jq '.name'

# Read from file
jq '.users[] | select(.age > 18)' data.json
```

### `yq`: YAML Processing

```bash
# Parse YAML
yq '.database.host' config.yaml

# Convert YAML to JSON
yq -o=json config.yaml
```

---

## 20.6 Quick Reference

| Bridge | Syntax |
|--------|--------|
| Shell→Python | `python3 script.py` or `python3 << PYEOF` |
| Python→Shell | `subprocess.run(['ls'])` |
| Shell→Node | `node script.js` or `node << JSEOF` |
| Parse JSON | `jq '.key' file.json` |
| Parse YAML | `yq '.key' file.yaml` |
| Orchestrate | `make` |

---

## 20.7 Exercises

1. Use Shell to call Python to process a CSV file
2. Use Python's `subprocess` to execute Shell commands
3. Use `jq` to parse a JSON API response
4. Use Makefile to orchestrate Shell, Python, and Node.js tasks
