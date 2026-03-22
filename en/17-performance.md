# 17. Performance Optimization

---

## 17.1 Why Shell Performance Matters

Shell scripts are often used for:
- Batch processing large numbers of files
- Automation tasks
- CI/CD pipelines

A slow script can delay the entire process by hours. Optimizing Shell scripts can greatly improve efficiency.

---

## 17.2 Avoid External Commands

```bash
# Slow: external commands
for f in *.txt; do
    name=$(basename "$f")
    echo "$name"
done

# Fast: shell builtins
for f in *.txt; do
    echo "${f##*/}"
done
```

### Builtin vs External

| Slow | Fast | Description |
|------|------|-------------|
| `$(cat file)` | `$(<file)` | Direct read |
| `$(basename $f)` | `${f##*/}` | Parameter expansion |
| `$(expr $a + $b)` | `$((a + b))` | Arithmetic |
| `$(echo $var)` | `"$var"` | Direct use |

---

## 17.3 Use `while read` Instead of `for`

```bash
# Slow: for + command substitution
for line in $(cat file.txt); do
    process "$line"
done

# Fast: while read
while IFS= read -r line; do
    process "$line"
done < file.txt
```

---

## 17.4 Parallel Processing

### Use `&` and `wait`

```bash
#!/bin/bash

task1 &
task2 &
task3 &

wait

echo "All tasks complete"
```

### Use `xargs -P`

```bash
# Sequential
cat files.txt | xargs -I {} process {}

# Parallel (4 concurrent)
cat files.txt | xargs -P 4 -I {} process {}
```

---

## 17.5 Avoid Subshells

```bash
# Slow: subshell per iteration
for f in *.txt; do
    content=$(cat "$f")
    echo "$content" | wc -l
done

# Fast: single subshell
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 Quick Reference

| Optimization | Slow | Fast |
|--------------|------|------|
| Read file | `$(cat file)` | `$(<file)` or `while read` |
| Path | `$(basename $f)` | `${f##*/}` |
| Math | `$(expr $a + $b)` | `$((a + b))` |
| Parallel | sequential | `&` + `wait` or `xargs -P` |

---

## 17.7 Exercises

1. Use `time` to measure how long a loop processing 1000 files takes
2. Convert a sequential script to parallel processing
3. Compare performance of `$(cat file)` vs `while read`
4. Use `xargs -P` to speed up batch image processing
