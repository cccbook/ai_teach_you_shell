# 8. 변수와 함수

---

## 8.1 변수 기초

### 기본 할당

```bash
# 문자열
name="Alice"
greeting="안녕하세요, 세계!"

# 숫자
age=25
count=0

# 빈 값
empty=
empty2=""
```

### 변수 읽기

```bash
echo $name
echo ${name}    # 권장 형식, 더 명확함

# 큰따옴표 안에서
echo "제 이름은 ${name}입니다"
```

### 일반적인 실수

```bash
# 잘못됨: = 양쪽에 공백
name = "Alice"   # 명령어로 해석됨

# 잘못됨: 따옴표 없음
greeting=Hello World  # "Hello"만 출력됨

# 올바름:
name="Alice"
greeting="Hello World"
```

---

## 8.2 따옴표의 기술

### 큰따옴표 `"`
변수와 명령어 치환을 확장함

```bash
name="Alice"
echo "안녕하세요, $name"           # 안녕하세요, Alice
echo "오늘은 $(date +%Y)년입니다"     # 오늘은 2026년입니다
```

### 작은따옴표 `'`
있는 그대로 출력, 아무것도 확장하지 않음

```bash
name="Alice"
echo '안녕하세요, $name'           # 안녕하세요, $name
echo '오늘은 $(date +%Y)년입니다'     # 오늘은 $(date +%Y)년입니다
```

### 따옴표 없음
변수에 공백이 포함되지 않을 경우에만 사용

---

## 8.3 특수 변수

```bash
$0          # 스크립트 이름
$1, $2...   # 위치 매개변수
$#          # 인수 개수
$@          # 모든 인수 (개별)
$*          # 모든 인수 (하나의 문자열로)
$?          # 마지막 명령어의 종료 코드
$$          # 현재 프로세스 PID
$!          # 마지막 백그라운드 프로세스 PID
$-          # 현재 셸 옵션
```

---

## 8.4 배열

### 기본 사용법

```bash
# 배열 정의
colors=("빨강" "초록" "파랑")

# 요소 읽기
echo ${colors[0]}    # 빨강
echo ${colors[1]}    # 초록

# 모두 읽기
echo ${colors[@]}    # 빨강 초록 파랑

# 배열 길이
echo ${#colors[@]}   # 3
```

### 연관 배열 (Bash 4+)

```bash
declare -A user
user["name"]="Alice"
user["email"]="alice@example.com"

echo ${user["name"]}    # Alice
```

---

## 8.5 함수 기초

### 함수 정의

```bash
# 방법 1: function 키워드
function greet {
    echo "안녕하세요!"
}

# 방법 2: 직접 정의 (권장)
greet() {
    echo "안녕하세요!"
}
```

### 함수 매개변수

```bash
greet() {
    echo "안녕하세요, $1!"
}

greet "Alice"    # 안녕하세요, Alice!
```

### 반환 값

```bash
# return: 종료 코드를 위해 (0-255)
check() {
    if [[ $1 -gt 10 ]]; then
        return 0  # 성공
    else
        return 1  # 실패
    fi
}

if check 15; then
    echo "10보다 큼"
fi
```

---

## 8.6 지역 변수

```bash
counter() {
    local count=0
    ((count++))
    echo $count
}
```

---

## 8.7 함수 라이브러리

### 라이브러리 생성

```bash
cat > lib.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date +%H:%M:%S)] $@"
}

error() {
    echo "[$(date +%H:%M:%S)] 오류: $@" >&2
}

confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}
EOF
```

### 라이브러리 사용

```bash
#!/bin/bash

source lib.sh

log "프로세스 시작"
error "문제가 발생했습니다"
confirm "계속하시겠습니까?" && echo "계속 진행"
```

---

## 8.8 빠른 참조

| 항목 | 구문 | 설명 |
|------|------|------|
| 할당 | `var=value` | = 양쪽에 공백 없음 |
| 읽기 | `$var` 또는 `${var}` | `${var}` 사용 |
| 큰따옴표 | `"..."` | 변수 확장 |
| 작은따옴표 | `'...'` | 확장 없음 |
| 인수 | `$1`, `$2`, `$@` | 매개변수 가져오기 |
| 함수 | `name() { }` | 권장 정의 방법 |
| 지역 변수 | `local var=value` | 함수 내에서만 |
| 배열 | `arr=(a b c)` | 인덱스 및 연관 배열 |
| source | `source file.sh` | 라이브러리 로드 |

---

## 8.9 연습문제

1. 이름과 나이를 매개변수로 받아 "안녕하세요, Y님. 나이가 X살입니다!"를 출력하는 스크립트를 작성하세요
2. `log`와 `error` 함수가 있는 라이브러리를 만들고 다른 스크립트에서 사용하세요
3. 피보나치 수를 계산하는 재귀 함수를 작성하세요
4. `mapfile`을 사용하여 파일을 줄별로 배열에 읽고, 역순으로 출력하세요
