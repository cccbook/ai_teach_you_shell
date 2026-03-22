# 11. 로그 및 출력

---

## 11.1 왜 로깅이 중요한가

로깅 없이:
- 스크립트가 어디까지 진행되었는지 알 수 없음
- 왜 실패했는지 알 수 없음
- 성공 시 무엇을 했는지 알 수 없음

로깅으로:
- 진행 상황 추적 가능
- 실패 디버깅에 충분한 정보 보유
- 실행 이력 감사 가능

---

## 11.2 기본 로그 레벨

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

log $DEBUG "디버그 메시지"
log $INFO "정보 메시지"
log $WARN "경고 메시지"
log $ERROR "오류 메시지"
```

---

## 11.3 색상 출력

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

log_info "설치 완료"
log_warn "기본값 사용"
log_error "연결 실패"
```

---

## 11.4 파일 출력

```bash
#!/bin/bash

LOG_FILE="/var/log/myapp.log"

log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $@"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

log "애플리케이션 시작됨"
```

---

## 11.5 `tee`: 화면과 파일에 동시에 출력

```bash
# 동시에 표시하고 저장
echo "안녕하세요" | tee output.txt

# 추가 모드
echo "세계" | tee -a output.txt

# stderr도 캡처
./script.sh 2>&1 | tee output.log
```

---

## 11.6 진행률 표시기

### 간단한 점

```bash
echo -n "처리 중"
for i in {1..10}; do
    echo -n "."
    sleep 0.2
done
echo " 완료"
```

### 진행률 막대

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

## 11.7 `2>&1` 설명

```bash
# 1 = stdout, 2 = stderr

# stderr를 stdout로 리다이렉션
command 2>&1

# stdout를 파일로, stderr는 화면으로
command > output.txt

# 둘 다 파일로
command > output.txt 2>&1

# 둘 다 /dev/null로 (숨기기)
command > /dev/null 2>&1
```

---

## 11.8 빠른 참조

| 구문 | 설명 |
|------|------|
| `echo "텍스트"` | 기본 출력 |
| `echo -e "\033[31m"` | 색상 출력 |
| `2>&1` | stderr를 stdout로 리다이렉션 |
| `> file` | 파일 덮어쓰기 |
| `>> file` | 파일에 추가 |
| `tee file` | 출력 및 저장 |
| `tee -a file` | 추가 모드 |
| `/dev/null` | 출력 버리기 |

---

## 11.9 연습문제

1. INFO, WARN, ERROR 메시지를 다른 색상으로 표시하는 스크립트를 작성하세요
2. `tee`를 사용하여 출력을 화면에 표시하고 로그 파일에 동시에 저장하세요
3. 진행률 막대가 있는 파일 처리 스크립트를 만드세요
4. 파일 출력과 로그 레벨을 지원하는 로깅 유틸리티 라이브러리를 만드세요
