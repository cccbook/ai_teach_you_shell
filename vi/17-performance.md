# 17. Tối Ưu Hiệu Suất

---

## 17.1 Tại Sao Shell Performance Quan Trọng

Shell scripts thường được sử dụng cho:
- Xử lý batch số lượng lớn file
- Tự động hóa tác vụ
- CI/CD pipelines

Một script chậm có thể làm chậm cả quy trình hàng giờ. Tối ưu Shell scripts có thể cải thiện đáng kể hiệu quả.

---

## 17.2 Tránh Các Lệnh Ngoài

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

| Chậm | Nhanh | Description |
|------|------|-------------|
| `$(cat file)` | `$(<file)` | Đọc trực tiếp |
| `$(basename $f)` | `${f##*/}` | Mở rộng tham số |
| `$(expr $a + $b)` | `$((a + b))` | Số học |
| `$(echo $var)` | `"$var"` | Sử dụng trực tiếp |

---

## 17.3 Sử Dụng `while read` Thay vì `for`

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

## 17.4 Xử Lý Song Song

### Sử dụng `&` và `wait`

```bash
#!/bin/bash

task1 &
task2 &
task3 &

wait

echo "All tasks complete"
```

### Sử dụng `xargs -P`

```bash
# Sequential
cat files.txt | xargs -I {} process {}

# Parallel (4 concurrent)
cat files.txt | xargs -P 4 -I {} process {}
```

---

## 17.5 Tránh Subshells

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

## 17.6 Tham Khảo Nhanh

| Optimization | Slow | Fast |
|--------------|------|------|
| Đọc file | `$(cat file)` | `$(<file)` hoặc `while read` |
| Đường dẫn | `$(basename $f)` | `${f##*/}` |
| Toán học | `$(expr $a + $b)` | `$((a + b))` |
| Song song | sequential | `&` + `wait` hoặc `xargs -P` |

---

## 17.7 Bài Tập

1. Sử dụng `time` đo thời gian vòng lặp xử lý 1000 file
2. Chuyển script tuần tự thành xử lý song song
3. So sánh hiệu suất `$(cat file)` vs `while read`
4. Sử dụng `xargs -P` để tăng tốc xử lý batch image
