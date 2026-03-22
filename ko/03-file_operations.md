# 3. 파일 작업

---

## 3.1 AI의 파일 시스템 멘탈 모델

각 명령을 깊이 파고들기 전에, AI가 파일 시스템을 어떻게 보는지 이해하세요.

인간 엔지니어들은 일반적으로 파일 시스템을 **시각적으로** 봅니다—Windows 탐색기나 macOS Finder처럼, 아이콘과 폴더 모양을 통해 이해합니다.

AI의 관점은 완전히 다릅니다:

```
path          = 절대 위치 /home/user/project/src/main.py
relative      = 현재 위치에서 아래로 이동
nodes         = 모든 파일이나 디렉토리는 "노드"
attributes    = 권한, 크기, 타임스탬프, 소유자
type          = 일반 파일(-), 디렉토리(d), 링크(l), 장치(b/c)
```

AI가 `ls -la`를 실행하면, 이것을 봅니다:

```
drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
-rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
-rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
-rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json
```

AI는 이것에서 즉시 읽을 수 있습니다:
- 어느 것이 디렉토리인지 (`d`)
- 어느 것이 숨김 파일인지 (`.`으로 시작)
- 누가 어떤 권한을 가지고 있는지
- 파일 크기 (큰 파일 판단)
- 마지막 수정 시간

---

## 3.2 `ls`: AI가 가장 많이 사용하는 첫 번째 명령

거의 모든 작업 전에, AI는 `ls`를 실행하여 현재 상태를 확인합니다.

### AI의 일반적인 `ls` 조합

```bash
# 기본 목록
ls

# 숨김 파일 표시 (매우 중요!)
ls -a

# 긴 형식 (상세 정보)
ls -l

# 긴 형식 + 숨김 파일 (가장 일반적)
ls -la

# 수정 시간순 정렬 (최신 먼저)
ls -lt

# 수정 시간순 정렬 (오래된 것 먼저)
ls -ltr

# 사람이 읽기 쉬운 크기 (K, M, G)
ls -lh

# 디렉토리만 표시
ls -d */

# 모든 파일 재귀적으로 표시
ls -R

# inode 번호 표시 (하드 링크에 유용)
ls -li
```

### AI의 실제 워크플로우

```bash
cd ~/project && ls -la

# 결과:
# drwxr-xr-x  5 ai  staff  170 Mar 22 10:30 .
# drwxr-xr-x  3 ai  staff  102 Mar 22 09:00 ..
# -rw-r--r--  1 ai  staff  4096 Mar 22 10:30 .env
# -rw-r--r--  1 ai  staff  8192 Mar 22 10:31 README.md
# drwxr-xr-x  3 ai  staff   96 Mar 22 10:30 src
# drwxr-xr-x  2 ai  staff   64 Mar 22 10:30 tests
# -rw-r--r--  1 ai  staff  2048 Mar 22 10:32 package.json

# AI 분석: .env 파일이 있고, src와 tests 디렉토리가 있고, package.json이 있음
# 이것은 Node.js 프로젝트
```

---

## 3.3 `cd`: AI가 절대 잊지 않는 디렉토리

### AI의 `cd` 습관

```bash
# 홈 디렉토리로 이동
cd ~

# 이전 디렉토리로 이동 (매우 유용!)
cd -

# 상위 디렉토리로 이동
cd ..

# 하위 디렉토리로 이동
cd src

# 깊은 경로 탐색 (Tab 자동완성의功劳)
cd ~/project/backend/api/v2/routes
```

### AI의 `cd` + `&&` 패턴

이것은 AI의 가장 일반적인 패턴 중 하나입니다:

```bash
# 먼저 cd하고, 성공 확인 후에만 다음 명령 실행
cd ~/project && ls -la
```

### 일반적인 오류

```bash
# 오류: 디렉토리 존재 확인 안 함
cd nonexistent
# 출력: bash: cd: nonexistent: No such file or directory

# AI의 접근: 먼저 확인
[ -d "nonexistent" ] && cd nonexistent || echo "Directory does not exist"
```

---

## 3.4 `mkdir`: 디렉토리 생성의 기술

### 기본 사용법

```bash
# 단일 디렉토리 생성
mkdir myproject

# 여러 디렉토리 생성
mkdir src tests docs

# 중첩 디렉토리 생성 (-p가 핵심!)
mkdir -p project/src/components project/tests
```

### 왜 AI는 거의 항상 `-p`를 사용하는가

`-p` (parents) 플래그는 다음을 의미합니다:
1. 디렉토리가 이미 있으면 **오류 없음**
2. 부모가 없으면 **자동으로 생성**

### AI의 일반적인 프로젝트 생성 패턴

```bash
# 표준 프로젝트 구조 생성
mkdir -p project/{src,tests,docs,scripts,config}
```

---

## 3.5 `rm`: 삭제의 기술

**경고**: 이것은 Shell에서 가장 위험한 명령 중 하나입니다.

### 기본 사용법

```bash
# 파일 삭제
rm file.txt

# 디렉토리 삭제 (-r 필요)
rm -r directory/

# 디렉토리와 모든 내용 삭제 (위험!)
rm -rf directory/
```

### `rm -rf`의 위험성

```bash
# rootとして 절대 실행하지 마세요!
# rm -rf /

# 실수로 공백을 하나 더 추가하면:
rm -rf * 
# (공백) = rm -rf가 현재 디렉토리의 모든 것을 삭제
```

---

## 3.6 `cp`: 파일과 디렉토리 복사

### 기본 사용법

```bash
# 파일 복사
cp source.txt destination.txt

# 디렉토리 복사 (-r 필요)
cp -r source_directory/ destination_directory/

# 복사 중 진행률 표시 (-v verbose)
cp -v large_file.iso /backup/

# 대화형 모드 (덮어쓰기 전 확인)
cp -i *.py src/
```

### 와일드카드 파워

```bash
# 모든 .txt 파일 복사
cp *.txt backup/

# 모든 이미지 파일 복사
cp *.{jpg,png,gif,webp} images/
```

---

## 3.7 `mv`: 이동과 이름 변경

### 기본 사용법

```bash
# 파일 이동
mv file.txt backup/

# 이동과 동시에 이름 변경
mv oldname.txt newname.txt

# 일괄 이름 변경
for f in *.txt; do
    mv "$f" "${f%.txt}.md"
done
```

---

## 3.8 빠른 참조

| 명령 | 기본 사용법 | 일반적인 플래그 | AI 노트 |
|------|------------|----------------|---------|
| `ls` | `ls [path]` | `-l` 긴 형식, `-a` 숨김, `-h` 사람이 읽기 | `ls -la`가 항상 좋음 |
| `cd` | `cd [path]` | `-` 이전, `..` 상위 | `cd xxx &&`가 좋은 습관 |
| `mkdir` | `mkdir [dir]` | `-p` 중첩 | 거의 항상 `-p` 사용 |
| `rm` | `rm [file]` | `-r` 재귀, `-f` 강제 | `rm -rf /*` 조심 |
| `cp` | `cp [src] [dst]` | `-r` 디렉토리, `-i` 확인, `-p` 보존 | 안전을 위해 `-i` 사용 |
| `mv` | `mv [src] [dst]` | `-i` 확인, `-n` 덮어쓰기 안 함 | 이름 변경임 |

---

## 3.9 연습 문제

1. `mkdir -p`를 사용하여 3단계 중첩 디렉토리를 생성한 다음, `tree` 또는 `find`로 확인하세요
2. `cp -v`로 큰 파일을 복사하고 출력을 확인하세요
3. `mv`로 10개의 `.txt` 파일을 `.md`로 일괄 이름 변경하세요
4. `rm -i`로 테스트 파일을 삭제하여 프롬프트를 경험하세요
