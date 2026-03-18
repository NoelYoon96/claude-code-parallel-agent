---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*)
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

- Summary: 50자 이내, 명령형 사용 (add, fix, refactor), 마침표 없음
- Body: 무엇을 & 왜 변경했는지 설명 (선택)
- Footer: 관련 Issue 번호 (선택) - `Fixes #123`, `Closes #456`

## Current Status

### Staged Changes
!`git status --short`

### Diff (Staged)
!`git diff --cached --stat`

### Recent Commits (스타일 참고)
!`git log --oneline -5`

## Commit Workflow

1. Run `git status` and `git diff` to review all changes
2. Confirm with user which files to include (never auto-include pre-existing uncommitted changes)
3. Run the build command and verify it passes
4. Stage only the approved files
5. Write a conventional commit message (feat/fix/refactor/docs)
6. Push to the current branch

## Task

1. 위 변경사항을 분석하여 적절한 Type과 Scope 결정
2. Summary를 한국어로 간결하게 작성 (50자 이내)
3. 필요시 Body에 상세 설명 추가
4. 커밋 실행 (HEREDOC 형식 사용)

예시:
```bash
git commit -m "$(cat <<'EOF'
Feat(admin): 거래 상세 페이지에서 토큰 주소 표시

- 토큰 주소가 있는 경우에만 표시하도록 조건 추가
- 송금 수수료 포맷 수정

EOF
)"
```
