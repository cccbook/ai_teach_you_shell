# 6. Permissions, Execution, Environment and Settings

---

## 6.1 `chmod`: The Art of Permissions

### Linux/Unix Permissions Basics

```
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 .
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 README.md
-rwxr-xr-x  1 ai  staff   128 Mar 22 10:30 script.sh
```

The 9 characters are in three groups:
- `rwx` (owner): read, write, execute
- `r-x` (group): read, execute
- `r--` (others): read only

### chmod Two Representations

**Numeric (octal)**:

```
r = 4, w = 2, x = 1

rwx = 7, r-x = 5, r-- = 4
```

Common combinations:
- `777` = rwxrwxrwx (dangerous!)
- `755` = rwxr-xr-x
- `644` = rw-r--r--
- `700` = rwx------
- `600` = rw-------

**Symbolic**:

```bash
chmod u+x script.sh    # Owner adds execute
chmod g-w file.txt     # Group removes write
chmod +x script.sh     # Everyone adds execute
```

### AI's Common chmod Usage

```bash
# Make script executable (almost every script)
chmod +x script.sh

# Make directory traversable
chmod +x ~/projects

# Group writable directories
chmod -R g+w project/
```

---

## 6.2 Executing Shell Scripts

### Execution Methods

```bash
# Method 1: Path execution (needs execute permission)
./script.sh

# Method 2: Using bash (doesn't need execute permission)
bash script.sh

# Method 3: Using source (executes in current shell)
source script.sh
```

### When to Use Which?

| Method | When to Use | Characteristics |
|--------|-------------|-----------------|
| `./script.sh` | Standard execution | needs `chmod +x`, subshell |
| `bash script.sh` | Specify shell | no execute permission needed |
| `source script.sh` | Set environment | executes in current shell |

### `source` vs `./script` Key Difference

```bash
# script.sh content: export MY_VAR="hello"

# Execute with ./
./script.sh
echo $MY_VAR  # Output: (empty) ← in subshell, variable gone

# Execute with source
source script.sh
echo $MY_VAR  # Output: hello ← in current shell, variable remains
```

---

## 6.3 `export`: Environment Variables

```bash
# Set environment variable
export NAME="Alice"
export PATH="$PATH:/new/directory"

# Show all environment variables
export

# Common variables
echo $HOME      # Home directory
echo $USER      # Username
echo $PATH      # Search path
echo $PWD       # Current directory
```

### Persisting Environment Variables

```bash
# Add to ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc

# Apply changes
source ~/.bashrc
```

---

## 6.4 `source`: Loading Files

Equivalent to: directly **paste** the file's content at the current position and execute.

### Common Uses

```bash
# Load virtual environment
source venv/bin/activate

# Load .env file
source .env

# Load library
source ~/scripts/common.sh
```

### Practical: Modular Config Files

```bash
# config.sh
export DB_HOST="localhost"
export DB_PORT="5432"

# Use in other scripts
source config.sh
psql -h $DB_HOST -p $DB_PORT
```

---

## 6.5 `env`: Environment Management

```bash
# Show all environment variables
env

# Execute with clean environment
env -i HOME=/tmp PATH=/bin sh

# Set variables and execute
env VAR1=value1 VAR2=value2 ./my_program
```

### Finding Commands

```bash
which python      # Find command location
type cd           # Find shell builtins
whereis gcc       # Find all related files
```

---

## 6.6 `sudo`: Escalating Privileges

```bash
# Execute as root
sudo rm /var/log/old.log

# Execute as specific user
sudo -u postgres psql

# Show what you can do
sudo -l
```

### Danger Warning

```bash
# Never run this!
sudo rm -rf /

# Never do this!
sudo curl http://unknown-site.com | sh
```

---

## 6.7 Quick Reference

| Command | Purpose | Common Flags |
|---------|---------|--------------|
| `chmod` | Change file permissions | `+x` add exec, `755` octal, `-R` recursive |
| `chown` | Change owner | `user:group`, `-R` recursive |
| `./script` | Execute script (needs x) | - |
| `bash script` | Execute script (no x needed) | - |
| `source` | Execute in current shell | - |
| `export` | Set environment variables | `-n` remove |
| `env` | Display/manage environment | `-i` clear |
| `sudo` | Execute as root | `-u user` specify user |

---

## 6.8 Exercises

1. Create a script, set permissions with `chmod 755`, then execute it
2. Execute the same environment variable script with `source` and `./`, observe the difference
3. Use `env -i` to create a clean environment, run `python --version`
4. Create a `.env` file, use `source` to load its variables
