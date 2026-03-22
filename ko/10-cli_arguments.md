# 10. 인수 분석 및 CLI 도구

---

## 10.1 명령줄 인수 기초

```bash
#!/bin/bash

echo "스크립트: $0"
echo "첫 번째 인수: $1"
echo "두 번째 인수: $2"
echo "세 번째 인수: ${3:-기본값}"  # 기본값
echo "인수 개수: $#"
echo "모든 인수: $@"
```

### 실행

```bash
./script.sh foo bar
# 출력:
# 스크립트: ./script.sh
# 첫 번째 인수: foo
# 두 번째 인수: bar
# 세 번째 인수: 기본값
# 인수 개수: 2
# 모든 인수: foo bar
```

---

## 10.2 간단한 인수 분석

### 위치 매개변수

```bash
#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "사용법: $0 <파일>"
    exit 1
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
    echo "오류: 파일이 존재하지 않습니다"
    exit 1
fi

echo "$FILE 처리 중..."
```

### 선택적 인수 처리

```bash
#!/bin/bash

VERBOSE=false
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "알 수 없는 옵션: $1"
            exit 1
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

$VERBOSE && echo "상세 모드 켜짐"
[[ -n "$OUTPUT" ]] && echo "출력 위치: $OUTPUT"
```

---

## 10.3 `getopts`: 표준 옵션 분석

```bash
#!/bin/bash

while getopts "hv:o:" opt; do
    case $opt in
        h)
            echo "도움말 정보"
            exit 0
            ;;
        v)
            echo "상세 모드: $OPTARG"
            ;;
        o)
            echo "출력 파일: $OPTARG"
            ;;
        \?)
            echo "잘못된 옵션: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "남은 인수: $@"
```

### 옵션 형식 참조

| 형식 | 의미 |
|------|------|
| `getopts "hv:"` | `-h` 인자 없음, `-v` 인자 필요 |
| `OPTARG` | 현재 옵션의 인자 값 |
| `OPTIND` | 다음 인수 인덱스 |

---

## 10.4 대화형 입력

### `read`: 사용자 입력 읽기

```bash
#!/bin/bash

# 기본 읽기
read -p "이름을 입력하세요: " name
echo "안녕하세요, $name"

# 비밀번호 (숨김)
read -sp "비밀번호를 입력하세요: " password
echo

# 여러 값 읽기
read -p "이름과 나이를 입력하세요: " name age
echo "$name님의 나이는 $age살입니다"

# 시간 초과
read -t 5 -p "5초 내에 입력하세요: " value
```

### 확인 프롬프트

```bash
confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

if confirm "이 파일을 삭제하시겠습니까?"; then
    echo "삭제 중..."
fi
```

---

## 10.5 메뉴 인터페이스

```bash
#!/bin/bash

PS3="작업을 선택하세요: "

select choice in "프로젝트 생성" "프로젝트 삭제" "종료"; do
    case $choice in
        "프로젝트 생성")
            echo "생성 중..."
            ;;
        "프로젝트 삭제")
            echo "삭제 중..."
            ;;
        "종료")
            echo "안녕히 가세요!"
            exit 0
            ;;
        *)
            echo "잘못된 선택입니다"
            ;;
    esac
done
```

---

## 10.6 빠른 참조

| 구문 | 설명 |
|------|------|
| `$0` | 스크립트 이름 |
| `$1`, `$2`... | 위치 매개변수 |
| `$#` | 인수 개수 |
| `${var:-default}` | 기본값 |
| `getopts "hv:" opt` | 옵션 분석 |
| `$OPTARG` | 현재 옵션의 인자 |
| `read -p "프롬프트:" var` | 입력 읽기 |
| `read -s var` | 숨김 입력 (비밀번호) |
| `read -t 5 var` | 5초 시간 초과 |
| `select` | 메뉴 인터페이스 |

---

## 10.7 연습문제

1. `-n`으로 개수, `-v`로 상세 모드를 지정할 수 있는 CLI 도구를 작성하세요
2. `getopts`를 사용하여 `-h` (도움말), `-o` (출력 파일) 옵션을 분석하세요
3. y 응답에서만 진행하는 확인 함수를 작성하세요
4. `select`를 사용하여 간단한 계산기 메뉴를 만드세요
