---
allowed-tools: Bash(ls:*), Bash(git diff:*), Bash(git log:*), Bash(git status:*), Glob, Grep, Read, Write, Edit
description: 세션 변경사항을 분석하여 검증 스킬 누락을 탐지하고, 새 스킬을 생성하거나 기존 스킬을 업데이트합니다
argument-hint: "[선택사항: 특정 스킬 이름 또는 집중할 영역]"
---

# 세션 기반 스킬 유지보수

## 목적

현재 세션에서 변경된 내용을 분석하여 검증 스킬의 드리프트를 탐지하고 수정합니다:

1. **커버리지 누락** — 어떤 verify 스킬에서도 참조하지 않는 변경된 파일
2. **유효하지 않은 참조** — 삭제되거나 이동된 파일을 참조하는 스킬
3. **누락된 검사** — 기존 검사에서 다루지 않는 새로운 패턴/규칙
4. **오래된 값** — 더 이상 일치하지 않는 설정값 또는 탐지 명령어

## 워크플로우

### Step 1: 등록된 검증 스킬 동적 탐색

```bash
ls .claude/skills/verify-*/SKILL.md 2>/dev/null
```

### Step 2: 세션 변경사항 분석

```bash
git diff HEAD --name-only
git log --oneline main..HEAD 2>/dev/null
git diff main...HEAD --name-only 2>/dev/null
```

### Step 3: 등록된 스킬과 변경 파일 매핑

탐색된 스킬이 0개인 경우 → Step 5로 이동. 1개 이상인 경우 각 SKILL.md를 읽고 파일-스킬 매핑을 구축합니다.

### Step 4: 영향받은 스킬의 커버리지 갭 분석

1. 누락된 파일 참조
2. 오래된 탐지 명령어
3. 커버되지 않은 새 패턴
4. 삭제된 파일의 잔여 참조
5. 변경된 값

### Step 5: CREATE vs UPDATE 결정

```
커버되지 않은 각 파일 그룹에 대해:
    IF 기존 스킬의 도메인과 관련 → UPDATE
    ELSE IF 3개 이상의 관련 파일이 공통 패턴 공유 → CREATE
    ELSE → 면제
```

### Step 6: 기존 스킬 업데이트

추가/수정만 — 작동하는 기존 검사는 절대 제거하지 않음

### Step 7: 새 스킬 생성

- 반드시 사용자에게 스킬 이름 확인
- `verify-` 접두사, kebab-case
- `.claude/skills/verify-<name>/SKILL.md` 생성
- CLAUDE.md Skills 테이블 업데이트

### Step 8: 검증

수정된 SKILL.md 파일 재확인, 깨진 파일 참조 확인, 탐지 명령어 드라이런

### Step 9: 요약 보고서 출력

## 품질 기준

- 코드베이스의 실제 파일 경로 (`ls`로 검증)
- 작동하는 탐지 명령어
- PASS/FAIL 기준
- 최소 2-3개의 현실적인 예외

## 예외사항

1. Lock 파일 및 생성된 파일
2. 일회성 설정 변경
3. 문서 파일
4. 테스트 픽스처 파일
5. 벤더/서드파티 코드
6. CI/CD 설정
