# 9. 오류 처리

---

## 9.1 왜 오류 처리가 중요한가

오류 처리 없이:
- 하나의 명령어가 실패해도 잘못된 작업을 계속함
- 잘못된 파일을 삭제할 수 있음
- 중요한 데이터를 덮어쓸 수 있음
- 시스템을 일관성 없는 상태로 남겨둘 수 있음

오류 처리를 하면:
- 오류 발생 시 즉시 중지
- 의미 있는 오류 메시지 제공
- 종료 전 정리 작업 수행

---

## 9.2 종료 코드

모든 명령어는 실행 후 종료 코드를 반환함:

- `0`: 성공
- `0이 아님`: 실패

```bash
# 마지막 명령어의 종료 코드 확인
ls /tmp
echo $?  # 출력: 0 (성공 시)

ls /nonexistent
echo $?  # 출력: 2 (실패 시)
```

---

## 9.3 `set -e`: 오류 시 중지

```bash
#!/bin/bash
set -e

mkdir -p backup
cp important.txt backup/  # 이것이 실패하면 스크립트가 여기서 중지됨
rm important.txt          # 여기까지 도달하지 않음
```

### 사용 시기

거의 모든 스크립트에서 `set -e`를 사용해야 함:
- 초기화 스크립트
- 배포 스크립트
- 자동화 테스트 스크립트

---

## 9.4 `set -u`: 정의되지 않은 변수에 대한 오류

```bash
#!/bin/bash
set -u

echo $undefined_var
# 출력: bash: undefined_var: 정의되지 않은 변수
```

### 함께 사용

```bash
#!/bin/bash
set -euo pipefail

# -e: 오류 시 중지
# -u: 정의되지 않은 변수에 대한 오류
# -o pipefail: 파이프의 모든 명령어가 실패하면 파이프 실패
```

**이것이 AI의 표준 스크립트 헤더입니다!**

---

## 9.5 `trap`: 우아한 오류 처리

### 기본 사용

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "정리 중..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

# 메인 프로그램
echo "프로세스 시작..."
```

### 오류 캡처

```bash
#!/bin/bash
set -euo pipefail

error_handler() {
    local exit_code=$?
    echo "❌ 스크립트가 $1번째 줄에서 실패했습니다, 종료 코드: $exit_code"
    exit $exit_code
}

trap 'error_handler $LINENO' ERR
```

---

## 9.6 사용자 정의 오류 함수

```bash
#!/bin/bash
set -euo pipefail

die() {
    echo "❌ $@" >&2
    exit 1
}

warn() {
    echo "⚠️ $@"
}

need_command() {
    command -v "$1" &>/dev/null || die "필요한 명령어: $1"
}

need_file() {
    [[ -f "$1" ]] || die "필요한 파일: $1"
}
```

---

## 9.7 빠른 참조

| 명령어 | 설명 |
|--------|------|
| `$?` | 마지막 명령어의 종료 코드 |
| `set -e` | 오류 시 중지 |
| `set -u` | 정의되지 않은 변수에 대한 오류 |
| `set -o pipefail` | 파이프의 명령어가 실패하면 파이프 실패 |
| `set -euo pipefail` | 결합 (권장) |
| `trap 'func' EXIT` | 종료 시 실행 |
| `trap 'func' ERR` | 오류 시 실행 |
| `trap 'func' INT` | Ctrl+C 시 실행 |
| `exit 1` | 종료 코드 1로 종료 |

---

## 9.8 연습문제

1. `set -euo pipefail`을 사용하고 실패 시 "오류 발생"을 출력하는 스크립트를 작성하세요
2. 메시지를 출력하고 종료하는 `die()` 함수를 만드세요
3. `trap`을 사용하여 스크립트 종료 시 "안녕히"을 표시하세요
4. 실패 시 자동 롤백이 있는 배포 스크립트를 작성하세요
