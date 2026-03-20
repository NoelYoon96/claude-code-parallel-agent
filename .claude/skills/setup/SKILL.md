---
allowed-tools: Bash(ls:*), Bash(cp:*), Bash(mkdir:*), Bash(chmod:*), Bash(find:*), Read, Write, Edit
description: 병렬 AI 에이전트 개발 자동화 아키텍처를 설치합니다. 글로벌 또는 프로젝트 레벨 선택 가능.
---

# Setup Parallel Agent Architecture

hooks와 skills를 설치합니다. 사용자에게 설치 범위를 먼저 확인합니다.

## 워크플로우

### Step 1: 소스 파일 확인

현재 디렉토리에 설치할 파일들이 있는지 확인합니다.

```bash
ls .claude/hooks/load-recent-changes.sh .claude/hooks/commit-session.sh .claude/skills/commit/SKILL.md 2>/dev/null
```

파일이 없으면 중단하고 레포 루트에서 실행하도록 안내하세요.

### Step 2: 설치 범위 선택

`AskUserQuestion`으로 사용자에게 확인합니다:

```markdown
**어디에 설치할까요?**

1. **글로벌** (`~/.claude/`) — 모든 프로젝트에서 사용 가능
2. **현재 프로젝트** (`./.claude/`) — 이 프로젝트에서만 사용, 팀원과 git으로 공유 가능
```

### Step 3: 설치 경로 결정

- **글로벌 선택 시**: `TARGET=~/.claude`, hook 경로는 `$HOME/.claude/hooks/`
- **프로젝트 선택 시**: `TARGET=./.claude`, hook 경로는 `$CLAUDE_PROJECT_DIR/.claude/hooks/`

### Step 4: 기존 설정 확인

타겟 경로에 기존 파일이 있는지 확인합니다:

```bash
ls $TARGET/hooks/ $TARGET/skills/ $TARGET/settings.json 2>/dev/null
```

기존 파일이 있으면 사용자에게 **덮어쓸지, 건너뛸지** 확인합니다.

### Step 5: hooks 설치

```bash
mkdir -p $TARGET/hooks
cp .claude/hooks/load-recent-changes.sh $TARGET/hooks/
cp .claude/hooks/commit-session.sh $TARGET/hooks/
chmod +x $TARGET/hooks/*.sh
```

### Step 6: skills 설치

```bash
for skill in commit manage-skills verify-skill merge-worktree; do
  mkdir -p $TARGET/skills/$skill
  cp .claude/skills/$skill/SKILL.md $TARGET/skills/$skill/
done
```

setup 스킬 자체는 설치하지 않습니다 (설치용이므로).

### Step 7: settings.json 설정

타겟 경로의 `settings.json`에 hooks 섹션을 추가합니다.

**기존 settings.json이 있으면 hooks 섹션만 머지합니다. 기존 설정을 절대 덮어쓰지 마세요.**

글로벌 설치 시 hook command 경로:
```json
"command": "\"$HOME/.claude/hooks/load-recent-changes.sh\""
"command": "\"$HOME/.claude/hooks/commit-session.sh\""
```

프로젝트 설치 시 hook command 경로:
```json
"command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/load-recent-changes.sh"
"command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/commit-session.sh"
```

### Step 8: 설치 확인

```bash
find $TARGET/hooks -type f | sort
find $TARGET/skills -type f | sort
```

### Step 9: 완료 보고

설치 범위에 따라 보고합니다:

```markdown
## 설치 완료

### 설치 위치: [글로벌 ~/.claude/ | 프로젝트 ./.claude/]

### Hooks (자동 실행)
- ✅ load-recent-changes.sh (세션 시작 시 컨텍스트 자동 로드)
- ✅ commit-session.sh (세션 종료 시 WIP 자동 커밋)

### Skills (슬래시 커맨드)
- ✅ /commit — 컨벤셔널 커밋
- ✅ /manage-skills — 검증 스킬 자동 관리
- ✅ /verify-skill — 통합 검증 실행
- ✅ /merge-worktree — 워크트리 squash-merge

### 다음 세션부터 자동 적용됩니다.
```

프로젝트 설치의 경우 추가 안내:
```markdown
팀원과 공유하려면 `.claude/` 디렉토리를 git에 커밋하세요.
`.gitignore`에 `.claude/`가 포함되어 있지 않은지 확인하세요.
```
