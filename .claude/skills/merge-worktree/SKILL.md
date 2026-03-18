---
description: 현재 워크트리 브랜치를 메인 브랜치에 squash-merge합니다. git 히스토리와 소스 코드를 분석하여 체계적인 커밋 메시지를 작성합니다.
argument-hint: "[target-branch]"
---

# Merge Worktree

현재 워크트리 브랜치를 타겟 브랜치에 squash-merge하고, 체계적인 커밋 메시지를 작성합니다.

## Current context

- Git dir: `!git rev-parse --git-dir`
- Current branch: `!git branch --show-current`
- Recent commits: `!git log --oneline -20`
- Working tree status: `!git status --short`

## Instructions

아래 Phase를 순서대로 따르세요. 절대 건너뛰지 마세요.

---

### Phase 1: Validation

1. **워크트리 확인**: `git rev-parse --git-dir` 출력에 `/worktrees/`가 포함되어야 합니다. 아니면 중단하고 안내하세요.

2. **현재 브랜치 확인**: `git branch --show-current`

3. **타겟 브랜치 결정**:
   - 인수가 있으면 해당 브랜치 사용
   - 없으면 `main` → `master` 순서로 탐지

4. **원본 레포 경로 확인**: `git rev-parse --git-common-dir`에서 원본 레포 경로를 추출

5. **워킹 트리 클린 확인**: `git status --porcelain`에 결과가 있으면 커밋/스태시 먼저 하도록 안내

---

### Phase 2: Research

1. **커밋 히스토리**: `git log --oneline <target>..HEAD`
2. **파일 변경 요약**: `git diff <target>...HEAD --stat`
3. **전체 diff**: `git diff <target>...HEAD`
4. **핵심 파일 읽기**: 가장 크게 변경된 파일들을 Read로 전체 컨텍스트 파악
5. **변경 분류**: Features / Fixes / Refactors / Tests / Docs / Config
6. **주요 타입 결정**: `feat`, `fix`, `refactor`, `docs`, `chore`, `test` 중 선택

---

### Phase 3: Target branch preparation

1. 원본 레포에서 타겟 브랜치 최근 커밋 확인
2. **WIP 커밋 탐지**: 타겟 브랜치에 `wip:`, `WIP`, `auto-commit` 같은 커밋이 있으면 사용자에게 경고하고 리셋 여부 확인
3. 리모트가 있으면 fetch

---

### Phase 4: Squash merge

1. 원본 레포에서 타겟 브랜치 checkout
2. squash merge 실행:
   ```
   git -C <original-repo-path> merge --squash <worktree-branch>
   ```
3. **충돌 발생 시**: 충돌 파일 목록과 마커를 보여주고 중단. 자동 해결하지 않음.

---

### Phase 5: Commit message & commit

Phase 2의 분석을 바탕으로 커밋 메시지를 작성합니다:

```
<type>: <간결한 요약, 명령형, 72자 이내, 마침표 없음>

<2-4문장으로 무엇을 했고 왜 했는지 설명>

Changes:
- <그룹별 bullet points>
- <세부 사항은 sub-bullet>
```

**규칙:**
- `<type>`은 `feat`, `fix`, `refactor`, `docs`, `chore`, `test` 중 하나
- 여러 타입이 섞이면 주요 타입 사용
- Summary는 명령형, 마침표 없음, 72자 이내

커밋 실행:
```bash
git -C <original-repo-path> commit -m "$(cat <<'EOF'
<커밋 메시지>
EOF
)"
```

---

### Phase 6: Verification

1. `git -C <original-repo-path> log --oneline -3` 결과 표시
2. 사용자에게 보고:
   - 최종 커밋 해시
   - 커밋 요약
   - 머지된 브랜치
   - 워크트리 삭제 방법: `git worktree remove <path>`
   - 푸시 안내: `git push`

---

## Important notes

- 사용자 확인 없이 force-push나 destructive git 명령 사용 금지
- pre-commit hook 건너뛰기(`--no-verify`) 금지
- 예상치 못한 상황에서는 추측하지 말고 중단 후 설명
- 커밋 메시지 품질이 가장 중요 — Phase 2에서 변경 내용을 충분히 이해하세요
