# 3. File Operations

---

## 3.1 AI's Mental Model of Filesystem

Before diving into each command, understand how AI views the filesystem.

Human engineers typically see the filesystem **visually**—like Windows Explorer or macOS Finder, understanding through icons and folder shapes.

AI's view is completely different:

```
path          = absolute location /home/user/project/src/main.py
relative      = walk down from current location
nodes         = every file or directory is a "node"
attributes    = permissions, size, timestamps, owner
type          = regular file(-), directory(d), link(l), device(b/c)
```

When AI executes `ls -la`, it sees:

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI can immediately read from this:
- Which are directories (`d`)
- Which are hidden files (starting with `.`)
- Who has what permissions
- File sizes (determining if large files)
- Last modification time

---

## 3.2 `ls`: AI's Most Used First Command

Almost before every operation, AI executes `ls` to confirm the current state.

### AI's Common `ls` Combinations

```bash
# Basic list
ls

# Show hidden files (very important!)
ls -a

# Long format (detailed info)
ls -l

# Long format + hidden files (most common)
ls -la

# Sort by modification time (newest first)
ls -lt

# Sort by modification time (oldest first)
ls -ltr

# Human-readable sizes (K, M, G)
ls -lh

# Only show directories
ls -d */

# Recursively show all files
ls -R

# Show inode numbers (useful for hard links)
ls -li
```

### AI's Actual Workflow

```bash
cd ~/project && ls -la

# Result:
# drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
# drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
# -rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
# -rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
# drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
# drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
# -rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json

# AI analysis: there's a .env file, src and tests directories, package.json
# This is a Node.js project
```

---

## 3.3 `cd`: The Directory AI Never Forgets

### AI's `cd` Habits

```bash
# Go to home directory
cd ~

# Go to previous directory (very useful!)
cd -

# Go to parent directory
cd ..

# Go into subdirectory
cd src

# Navigate deep paths (Tab completion's功劳)
cd ~/project/backend/api/v2/routes
```

### AI's `cd` + `&&` Pattern

This is one of AI's most common patterns:

```bash
# First cd, only execute next command after confirming success
cd ~/project && ls -la
```

### Common Errors

```bash
# Error: not confirming directory exists
cd nonexistent
# Output: bash: cd: nonexistent: No such file or directory

# AI's approach: check first
[ -d "nonexistent" ] && cd nonexistent || echo "Directory does not exist"
```

---

## 3.4 `mkdir`: The Art of Creating Directories

### Basic Usage

```bash
# Create single directory
mkdir myproject

# Create multiple directories
mkdir src tests docs

# Create nested directories (-p is key!)
mkdir -p project/src/components project/tests
```

### Why AI Almost Always Uses `-p`

The `-p` (parents) flag means:
1. If directory exists, **no error**
2. If parent doesn't exist, **create it automatically**

### AI's Typical Project Creation Pattern

```bash
# Create a standard project structure
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`: The Art of Deletion

**Warning**: This is one of the most dangerous commands in Shell.

### Basic Usage

```bash
# Delete file
rm file.txt

# Delete directory (needs -r)
rm -r directory/

# Delete directory and everything (dangerous!)
rm -rf directory/
```

### The Danger of `rm -rf`

```bash
# Never run this as root!
# rm -rf /

# If you accidentally add an extra space:
rm -rf * 
# (space) = rm -rf deletes everything in current directory
```

---

## 3.6 `cp`: Copying Files and Directories

### Basic Usage

```bash
# Copy file
cp source.txt destination.txt

# Copy directory (needs -r)
cp -r source_directory/ destination_directory/

# Show progress during copy (-v verbose)
cp -v large_file.iso /backup/

# Interactive mode (ask before overwriting)
cp -i *.py src/
```

### Wildcard Power

```bash
# Copy all .txt files
cp *.txt backup/

# Copy all image files
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`: Moving and Renaming

### Basic Usage

```bash
# Move file
mv file.txt backup/

# Move and rename
mv oldname.txt newname.txt

# Batch rename
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 Quick Reference

| Command | Basic Usage | Common Flags | AI Note |
|---------|-------------|--------------|---------|
| `ls` | `ls [path]` | `-l` long, `-a` hidden, `-h` human | `ls -la` is always good |
| `cd` | `cd [path]` | `-` previous, `..` parent | `cd xxx &&` is good habit |
| `mkdir` | `mkdir [dir]` | `-p` nested | almost always use `-p` |
| `rm` | `rm [file]` | `-r` recursive, `-f` force | beware `rm -rf /*` |
| `cp` | `cp [src] [dst]` | `-r` directory, `-i` ask, `-p` preserve | use `-i` for safety |
| `mv` | `mv [src] [dst]` | `-i` ask, `-n` no-overwrite | it's rename |

---

## 3.9 Exercises

1. Use `mkdir -p` to create a three-level nested directory, then confirm with `tree` or `find`
2. Copy a large file with `cp -v` and see the output
3. Batch rename 10 `.txt` files to `.md` with `mv`
4. Delete a test file with `rm -i` to experience the prompt
