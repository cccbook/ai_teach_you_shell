# 16. 디버깅 기법

---

## 16.1 AI의 디버깅 사고방식

인간이 오류를 만났을 때: 패닉, 온라인 검색, 복사-붙여넣기
AI가 오류를 만났을 때: 메시지 분석, 원인 추론, 수정 실행

AI의 디버깅 흐름:
```
오류 출력 관찰 → 오류 유형 이해 → 문제 위치 파악 → 수정 → 검증
```

---

## 16.2 `bash -x`: 실행 추적

가장 간단한 디버깅: `-x` 플래그 추가

```bash
bash -x script.sh
```

각 실행 줄을 `+` 접두사와 함께 출력:

```bash
+ mkdir -p test
+ cd test
+ echo 'Hello'
Hello
```

### 특정 섹션만 디버깅

```bash
#!/bin/bash

echo "This won't show"
set -x
# 여기서부터 디버깅 시작
name="Alice"
echo "Hello, $name"
set +x
# 여기서까지 디버깅 종료
echo "This won't show"
```

---

## 16.3 일반적인 오류 및 해결책

### 오류 1: 권한 거부

```bash
# 오류
./script.sh
# 출력: Permission denied

# 해결
chmod +x script.sh
./script.sh
```

### 오류 2: 명령어를 찾을 수 없음

```bash
# 오류
python script.py
# 출력: command not found: python

# 해결: 전체 경로 사용
/usr/bin/python3 script.py
```

### 오류 3: 정의되지 않은 변수

```bash
#!/bin/bash
set -u

echo $undefined_var
# 출력: bash: undefined_var: unbound variable

# 해결: 기본값 제공
echo ${undefined_var:-default}
```

---

## 16.4 `echo` 디버깅

`-x`만으로 부족할 때, 수동으로 `echo` 추가:

```bash
#!/bin/bash

echo "DEBUG: Entering function"
echo "DEBUG: Parameter = $@"

process() {
    echo "DEBUG: In process"
    local result=$(expensive_command)
    echo "DEBUG: result = $result"
}
```

---

## 16.5 빠른 참조

| 명령어 | 설명 |
|--------|------|
| `bash -n script.sh` | 문법만 확인 |
| `bash -x script.sh` | 실행 추적 |
| `set -x` | 디버그 모드 활성화 |
| `set +x` | 디버그 모드 비활성화 |
| `trap 'echo cmd' DEBUG` | 모든 명령어 추적 |

---

## 16.6 연습 문제

1. 스크립트를 `bash -x`로 실행하고 출력 형식을 관찰하세요
2. 스크립트에서 특정 함수만 디버깅하기 위해 `set -x`를 사용하세요
3. 실패하는 명령어를 찾아 오류 메시지를 분석하고 수정하세요
4. `trap`을 사용하여 우아한 오류 처리를 만드세요
