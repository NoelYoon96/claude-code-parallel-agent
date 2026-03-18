#!/usr/bin/env bash
# Hook: Stop
# On session end: stages tracked changes, generates a WIP commit message
# via Claude headless mode (claude -p), commits.
# Falls back to a generic WIP message if claude -p fails.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || REPO_ROOT="$CLAUDE_PROJECT_DIR"
cd "$REPO_ROOT" || exit 0

# Stage tracked files only (avoid accidentally staging sensitive files)
git add -u 2>/dev/null || true

# Exit if nothing to commit
if git diff-index --quiet HEAD 2>/dev/null; then
  exit 0
fi

# Extract diff for commit message generation (truncated to 2000 lines)
DIFF=$(git diff --cached 2>/dev/null | head -2000)

# Generate commit message via Claude headless mode
COMMIT_MSG=""
if command -v claude &>/dev/null; then
  COMMIT_MSG=$(echo "$DIFF" | claude -p \
    "You are a commit message generator. Based on the following git diff, write a single commit message.
Rules:
- Format: WIP(<scope>): <한국어 요약> (max 50 chars)
- scope는 변경된 앱/패키지명 (예: admin, web, mobile, ui, api-client)
- 요약은 한국어, 명령형, 마침표 없음
- 필요시 빈 줄 후 bullet point로 상세 내용 추가
- Output ONLY the commit message, nothing else" 2>/dev/null) || true
fi

# Fallback if claude -p failed or returned empty
if [ -z "$COMMIT_MSG" ]; then
  FILE_COUNT=$(git diff --cached --name-only | wc -l | tr -d ' ')
  COMMIT_MSG="WIP: ${FILE_COUNT}개 파일 임시 저장"
fi

# Commit using -F - to safely handle special characters
echo "$COMMIT_MSG" | git commit -F - 2>/dev/null || true
