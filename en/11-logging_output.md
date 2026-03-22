# 11. Logging and Output

---

## 11.1 Why Logging Matters

Without logging:
- You don't know where the script is
- Don't know why it failed
- Don't know what it did on success

With logging:
- Can track progress
- Have enough info to debug failures
- Can audit execution history

---

## 11.2 Basic Log Levels

```bash
#!/bin/bash

DEBUG=0
INFO=1
WARN=2
ERROR=3

LOG_LEVEL=${LOG_LEVEL:-$INFO}

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ $level -ge $LOG_LEVEL ]]; then
        echo "[$timestamp] $message"
    fi
}

log $DEBUG "This is debug"
log $INFO "This is info"
log $WARN "This is warning"
log $ERROR "This is error"
```

---

## 11.3 Color Output

```bash
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $@"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $@"; }
log_error() { echo -e "${RED}[ERROR]${NC} $@" >&2; }

log_info "Installation complete"
log_warn "Using defaults"
log_error "Connection failed"
```

---

## 11.4 Output to File

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "Application started"
```

---

## 11.5 `tee`: Output to Both Screen and File

```bash
# Display and save simultaneously
echo "Hello" | tee output.txt

# Append mode
echo "World" | tee -a output.txt

# Capture stderr too
./script.sh 2>&1 | tee output.log
```

---

## 11.6 Progress Indicators

### Simple Dots

```bash
echo -n "Processing"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " Done"
```

### Progress Bar

```bash
draw_progress() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local chars=$((width * current / total))
    
    printf "\r[%s%s] %3d%%" \
        "$(printf '%*s' $chars | tr ' ' '=')" \
        "$(printf '%*s' $((width - chars)) | tr ' ' '-')" \
        "$percent"
    
    [[ $current -eq $total ]] && echo
}
```

---

## 11.7 `2>&1` Explained

```bash
# 1 = stdout, 2 = stderr

# Redirect stderr to stdout
command 2>&1

# Redirect stdout to file, stderr to screen
command > output.txt

# Redirect both to file
command > output.txt 2>&1

# Redirect both to /dev/null (hide)
command > /dev/null 2>&1
```

---

## 11.8 Quick Reference

| Syntax | Description |
|--------|-------------|
| `echo "text"` | Basic output |
| `echo -e "\033[31m"` | Color output |
| `2>&1` | Redirect stderr to stdout |
| `> file` | Overwrite file |
| `>> file` | Append to file |
| `tee file` | Output and save |
| `tee -a file` | Append mode |
| `/dev/null` | Discard output |

---

## 11.9 Exercises

1. Write a script that displays INFO, WARN, ERROR messages in different colors
2. Use `tee` to display and save output to a log file simultaneously
3. Create a file processing script with a progress bar
4. Build a logging utility library that supports file output and log levels
