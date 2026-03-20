---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git push:*)
description: Git 커밋 메시지를 컨벤션에 맞게 생성하고 커밋 실행
---

# Git Commit Helper

staged 변경사항을 분석하여 컨벤션에 맞는 커밋 메시지를 생성하고 커밋을 실행합니다.

## Commit Format

```
<Type>(<Scope>): <Summary>

<Body>

<Footer>
```

## Type (필수)

- **Feat**: 새로운 기능 추가
- **Fix**: 버그 수정
- **Refactor**: 코드 구조 개선 (기능 변화 없음)
- **Style**: 코드 포맷, Prettier, 린트 설정 변경
- **Docs**: 문서 추가/수정
- **Test**: 테스트 추가/수정
- **Chore**: 빌드, 의존성, 설정 파일 변경
- **Perf**: 성능 개선
- **Design**: 사용자 UI 디자인 변경
- **Rename**: 파일/폴더명 수정
- **Remove**: 파일 삭제
- **WIP**: 작업 중인 변경사항 임시 저장 (세션 종료 시 자동 커밋용)

## Scope (권장)

변경된 앱/패키지명을 사용 (예: admin, web, mobile, ui, api-client 등)

## Rules

- Summary: 한국어로 변경 내용을 최대한 구체적이고 자세하게 작성, 마침표 없음
- Body: 변경의 배경, 동기, 구현 세부사항, 영향 범위 등을 상세히 기술 (적극 권장)
- Footer: 관련 Issue 번호 (선택) - `Fixes #123`, `Closes #456`

## Current Status

### Staged Changes
!`git status --short`

### Diff (Staged)
!`git diff --cached --stat`

### Recent Commits (스타일 참고)
!`git log --oneline -5`

## Commit Workflow

1. `git status`와 `git diff`로 모든 변경사항 확인
2. 사용자에게 포함할 파일 확인 (기존 미커밋 변경사항은 자동 포함하지 않음)
3. 빌드 명령어 실행 및 통과 확인
4. 승인된 파일만 스테이징
5. 컨벤셔널 커밋 메시지 작성 (Feat/Fix/Refactor/Docs 등)
6. 현재 브랜치에 푸시

## Task

1. 위 변경사항을 분석하여 적절한 Type과 Scope 결정
2. Summary를 한국어로 변경 내용이 명확히 드러나도록 자세하게 작성
3. Body에 변경 배경, 구현 세부사항, 영향 범위를 상세히 기술
4. 커밋 실행 (HEREDOC 형식 사용)

예시:
```bash
git commit -m "$(cat <<'EOF'
Feat(admin): 거래 상세 페이지에 토큰 컨트랙트 주소 필드를 추가하고 송금 수수료 표시 포맷을 소수점 6자리로 통일

- 토큰 주소가 존재하는 경우에만 조건부 렌더링하여 불필요한 빈 필드 노출 방지
- 송금 수수료 포맷을 기존 정수 표시에서 소수점 6자리 고정 표기로 변경하여 정밀한 금액 확인 가능
- TransactionDetail 컴포넌트의 props 타입에 tokenAddress 옵셔널 필드 추가

EOF
)"
```
