# 18. 다른 사람의 스크립트 읽기 및 수정

---

## 18.1 왜 다른 사람의 스크립트를 읽는가

- 프로젝트 유지보수 인계
- 오픈소스 도구 사용
- 이슈 디버깅
- 새로운 기술 학습

AI는 매일 익숙하지 않은 스크립트를 만나므로, 다른 사람이 작성한 Shell 스크립트를 빠르게 이해하는 능력을 갖추는 것이 필수적입니다.

---

## 18.2 초기 관찰

### 단계 1: shebang 확인

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # bash 사용
#!/bin/sh        # POSIX sh 사용 (더 호환성 좋음)
```

### 단계 2: 권한과 크기 확인

```bash
ls -la script.sh
wc -l script.sh
```

### 단계 3: 빠른 문법 검사

```bash
bash -n script.sh  # 문법만 확인, 실행하지 않음
```

---

## 18.3 구조 이해

### 일반적인 구조

```bash
#!/bin/bash
# 주석: 스크립트 설명

# 설정
set -euo pipefail
VAR="value"

# 함수 정의
function help() { ... }

# 메인 흐름
main() { ... }

# 실행
main "$@"
```

### 메인 흐름 찾기

```bash
# 마지막 줄 확인
tail -20 script.sh

# 함수 정의 찾기
grep -n "^function\|^[[:space:]]*[a-z_]*\(" script.sh
```

---

## 18.4 일반적인 분석 명령어

```bash
# 모든 함수 정의 찾기
grep -n "^[[:space:]]*function" script.sh

# 모든 조건문 찾기
grep -n "if\|\[\[" script.sh

# 모든 루프 찾기
grep -n "for\|while\|do\|done" script.sh

# 명령어 치환 찾기
grep -n '\$(' script.sh

# 모든 종료 찾기
grep -n "exit" script.sh
```

---

## 18.5 보안 검사

```bash
# 위험한 명령어 찾기
grep -n "rm -rf" script.sh
grep -n "sudo" script.sh
grep -n "eval" script.sh

# 변수 주입 위험 확인
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh
```

---

## 18.6 연습 문제

1. `grep`과 `awk`로 기존 Shell 스크립트를 분석하세요
2. 스크립트의 모든 변수를 찾아 그 목적을 이해하세요
3. `bash -n`으로 스크립트의 문법을 확인하세요
4. 각 섹션을 설명하는 주석을 없는 스크립트에 추가하세요
