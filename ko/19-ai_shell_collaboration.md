# 19. AI + Shell 협업

---

## 19.1 인간-머신 협업의 새로운 형태

전통적 프로그래밍:
- 인간이 키보드로 입력
- 인간이 마우스로 IDE 조작
- 인간이 실행 및 테스트

AI 시대의 프로그래밍:
- 인간이 요구사항을 설명
- AI가 Shell 명령어와 스크립트 생성
- 인간이 검토 및 실행
- 인간과 AI가 함께 디버깅

---

## 19.2 AI에게 요구사항 설명하기

### 좋은 설명

```bash
# 명확한 작업
"/var/log에서 100MB 이상인 모든 .log 파일 찾기"

# 예상 출력 형식 포함
"라인 수 파일명 형식으로 모든 .py 파일 나열"

# 제약 조건 명시
"모든 .txt 파일 압축하되 'test'가 포함된 파일은 건너뛰기"
```

### 나쁜 설명

```bash
# 너무 모호함
"로그 처리 도와줘"

# 비현실적
"운영체제 만들어줘"
```

---

## 19.3 AI가 생성한 Shell 명령어 패턴

### 패턴 1: 단일 명령어

```bash
# 인간 요청: 줄 수가 가장 많은 Python 파일 10개 찾기
find . -name "*.py" -exec wc -l {} + | sort -rn | head -10
```

### 패턴 2: Shell 스크립트

```bash
# 인간 요청: 이미지 일괄 처리
cat > process_images.sh << 'EOF'
#!/bin/bash
for img in *.jpg; do
    convert "$img" -resize 800x600 "thumb_$img"
done
EOF
```

---

## 19.4 반복적 개발

### 라운드 1: 초기 버전 생성

```bash
# 인간: 백업 스크립트 작성
# AI가 초기 버전 생성, 인간이 테스트 후 이슈 제기:

# 인간: 좋지만 --dry-run 모드 필요
```

### 라운드 2: 기능 추가

```bash
# 인간: 에러 처리와 로깅도 추가해줘
```

### 라운드 3: 디버깅

```bash
# 인간: 실행 후 'Permission denied' 오류 발생
# AI: 문제 해결...
```

---

## 19.5 AI에게 디버깅 도움 받기

```bash
# 인간: 이 명령어 실행 후 오류 발생
$ ./deploy.sh
# 출력: /bin/bash^M: bad interpreter: No such file or directory

# AI: 이것은 Windows 줄 끝 문제입니다. 다음을 실행하세요:
sed -i 's/\r$//' deploy.sh
```

---

## 19.6 권장 협업 도구

### 터미널 멀티플렉서

```bash
# tmux: 창 분할
tmux new -s mysession
# Ctrl+b %  # 수직 분할
# Ctrl+b "  # 수평 분할
```

---

## 19.7 연습 문제

1. 복잡한 작업을 설명하고 AI에게 Shell 명령어를 생성하게 하세요
2. AI에게 기존 스크립트의 보안 이슈를 검토하게 하세요
3. 반복을 사용하여 AI에게 실용적인 도구를 작성하도록 하세요
4. AI에게 이해하지 못하는 Shell 코드를 설명하게 하세요
