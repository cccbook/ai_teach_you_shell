# 12. 일괄 파일 처리

---

## 12.1 일괄 이름 변경

### 간단한 확장자 변경

```bash
# 모든 .txt를 .md로 변경
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

### 접두사 추가

```bash
# 모든 이미지에 thumb_ 접두사 추가
for f in *.jpg *.png *.gif; do
    [[ -f "$f" ]] || continue
    mv "$f" "thumb_$f"
done
```

### 공백 제거

```bash
# 파일명의 공백을 밑줄로 변경
for f in *\ *; do
    [[ -f "$f" ]] || continue
    mv "$f" "${f// /_}"
done
```

### 번호 추가

```bash
# 파일을 001, 002, 003...으로 번호 매기기
i=1
for f in *.jpg; do
    [[ -f "$f" ]] || continue
    mv "$f" "$(printf '%03d.jpg' $i)"
    ((i++))
done
```

---

## 12.2 일괄 이미지 처리

```bash
#!/bin/bash
set -euo pipefail

SIZE=${1:-800}

for img in *.jpg *.png; do
    [[ -f "$img" ]] || continue
    
    echo "처리 중: $img"
    
    if command -v convert &>/dev/null; then
        # 썸네일 생성
        convert "$img" -resize "${SIZE}x${SIZE}>" "thumb_$img"
        
        # 큰 버전 생성
        convert "$img" -resize 1920x1080 "large_$img"
        
        echo "✓ 완료: thumb_$img, large_$img"
    fi
done
```

---

## 12.3 일괄 찾기 및 바꾸기

```bash
#!/bin/bash

# 모든 .txt 파일에서 "foo"를 "bar"로 변경
for f in *.txt; do
    [[ -f "$f" ]] || continue
    sed -i.bak 's/foo/bar/g' "$f"
done
```

---

## 12.4 일괄 압축

```bash
#!/bin/bash

# 각 파일 압축
for f in *.txt; do
    [[ -f "$f" ]] || continue
    gzip "$f"
done

# 모두 압축 해제
gunzip *.gz
```

---

## 12.5 일괄 다운로드

```bash
#!/bin/bash
set -euo pipefail

while read -r url; do
    filename=$(basename "$url")
    echo "다운로드 중: $url"
    curl -L -o "$filename" "$url"
done < urls.txt
```

---

## 12.6 빠른 참조

| 작업 | 명령어 |
|------|--------|
| 확장자 변경 | `mv "$f" "${f%.old}.new"` |
| 접두사 추가 | `mv "$f" "prefix_$f"` |
| 공백 제거 | `mv "$f" "${f// /_}"` |
| 번호 추가 | `mv "$f" "$(printf '%03d' $i)"` |
| 일괄 바꾸기 | `for f in *.txt; do sed -i 's/a/b/g' "$f"; done` |
| 일괄 압축 | `for f in *.txt; do gzip "$f"; done` |
| 일괄 다운로드 | `while read url; do curl -LO "$url"; done < urls.txt` |

---

## 12.7 연습문제

1. 10개의 파일을 일괄적으로 `.txt`에서 `.md`로 이름 변경하세요
2. 모든 이미지에 `thumb_` 접두사를 추가하고 썸네일을 만드세요
3. 모든 `.html` 파일에서 `old-site.com`을 `new-site.com`으로 변경하세요
4. 모든 `__pycache__`, `.pyc`, `.log` 파일을 삭제하는 정리 스크립트를 만드세요
