# 20. Shell과 다른 언어의 연결

---

## 20.1 어떤 작업에 Shell을 사용해야 하는가

Shell이擅长的 작업:
- 파일 조작
- 시스템 관리
- 자동화 워크플로우
- 파이프라인 구성
- 빠른 프로토타이핑

다른 언어가 더 적합한 작업:
- 복잡한 데이터 처리 (Python, AWK)
- 웹 프로그래밍 (JavaScript, Go)
- 수치 계산 (Python, R, Julia)
- 시스템 프로그래밍 (C, Rust)

---

## 20.2 Shell에서 Python 호출

### 간단한 호출

```bash
#!/bin/bash

# Python 스크립트 호출
python3 process_data.py input.csv

# 인자 전달
python3 script.py arg1 arg2

# 출력 가져오기
result=$(python3 -c "print('hello from python')")
echo "$result"
```

### Shell에 Python 내장

```bash
#!/bin/bash

python3 << 'PYEOF'
import csv

with open('data.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['amount']) for row in reader)
    print(f"Total: {total}")
PYEOF
```

---

## 20.3 Python에서 Shell 호출

### `subprocess` 사용

```python
import subprocess

# 간단한 명령어 실행
result = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(result.stdout)

# 복잡한 명령어 실행
result = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
```

---

## 20.4 Shell에서 JavaScript/Node.js 호출

```bash
#!/bin/bash

# Node.js 명령어 실행
node -e "console.log('hello from node')"

# Node.js 스크립트 실행
node process-json.js data.json
```

---

## 20.5 연결 도구

### `jq`: JSON 처리

```bash
# JSON 파싱
echo '{"name": "Alice", "age": 25}' | jq '.name'

# 파일에서 읽기
jq '.users[] | select(.age > 18)' data.json
```

### `yq`: YAML 처리

```bash
# YAML 파싱
yq '.database.host' config.yaml

# YAML을 JSON으로 변환
yq -o=json config.yaml
```

---

## 20.6 빠른 참조

| 연결 | 문법 |
|------|------|
| Shell→Python | `python3 script.py` 또는 `python3 << PYEOF` |
| Python→Shell | `subprocess.run(['ls'])` |
| Shell→Node | `node script.js` 또는 `node << JSEOF` |
| JSON 파싱 | `jq '.key' file.json` |
| YAML 파싱 | `yq '.key' file.yaml` |
| 오케스트레이션 | `make` |

---

## 20.7 연습 문제

1. Shell에서 Python을 호출하여 CSV 파일을 처리하세요
2. Python의 `subprocess`로 Shell 명령어를 실행하세요
3. `jq`로 JSON API 응답을 파싱하세요
4. Makefile로 Shell, Python, Node.js 작업을 오케스트레이션하세요
