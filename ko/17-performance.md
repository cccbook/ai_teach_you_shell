# 17. 성능 최적화

---

## 17.1 왜 Shell 성능이 중요한가

Shell 스크립트는 자주 다음과 같은 용도로 사용됩니다:
- 대량의 파일 일괄 처리
- 자동화 작업
- CI/CD 파이프라인

느린 스크립트는 전체 프로세스를 몇 시간이나 지연시킬 수 있습니다. Shell 스크립트를 최적화하면 효율성을 크게 향상시킬 수 있습니다.

---

## 17.2 외부 명령어 피하기

```bash
# 느림: 외부 명령어
for f in *.txt; do
    name=$(basename "$f")
    echo "$name"
done

# 빠름: 쉘 내장 명령어
for f in *.txt; do
    echo "${f##*/}"
done
```

### 내장 명령어 vs 외부 명령어

| 느림 | 빠름 | 설명 |
|------|------|------|
| `$(cat file)` | `$(<file)` | 직접 읽기 |
| `$(basename $f)` | `${f##*/}` | 매개변수 확장 |
| `$(expr $a + $b)` | `$((a + b))` | 산술 연산 |
| `$(echo $var)` | `"$var"` | 직접 사용 |

---

## 17.3 `for` 대신 `while read` 사용

```bash
# 느림: for + 명령어 치환
for line in $(cat file.txt); do
    process "$line"
done

# 빠름: while read
while IFS= read -r line; do
    process "$line"
done < file.txt
```

---

## 17.4 병렬 처리

### `&`와 `wait` 사용

```bash
#!/bin/bash

task1 &
task2 &
task3 &

wait

echo "All tasks complete"
```

### `xargs -P` 사용

```bash
# 순차 처리
cat files.txt | xargs -I {} process {}

# 병렬 처리 (4개 동시)
cat files.txt | xargs -P 4 -I {} process {}
```

---

## 17.5 서브셸 피하기

```bash
# 느림: 반복마다 서브셸
for f in *.txt; do
    content=$(cat "$f")
    echo "$content" | wc -l
done

# 빠름: 단일 서브셸
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 빠른 참조

| 최적화 | 느림 | 빠름 |
|--------|------|------|
| 파일 읽기 | `$(cat file)` | `$(<file)` 또는 `while read` |
| 경로 | `$(basename $f)` | `${f##*/}` |
| 수학 | `$(expr $a + $b)` | `$((a + b))` |
| 병렬 | 순차 처리 | `&` + `wait` 또는 `xargs -P` |

---

## 17.7 연습 문제

1. `time`을 사용하여 1000개 파일을 처리하는 루프의 소요 시간을 측정하세요
2. 순차 처리 스크립트를 병렬 처리로 변환하세요
3. `$(cat file)` vs `while read`의 성능을 비교하세요
4. `xargs -P`를 사용하여 일괄 이미지 처리를 가속화하세요
