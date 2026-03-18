# Automated Architecture for Parallel AI Agent Development

AI 에이전트의 3대 약점 — **기억 상실, 충돌 위험, 품질 불안정** — 을 Git 인프라 + 자동 Hook + 자기진화 검증으로 해결하는 Claude Code 개발 자동화 아키텍처

## Quick Start

### 방법 1: `/setup` 스킬로 자동 설치

```bash
git clone https://github.com/NoelYoon96/claude-code-parallel-agent.git
cd claude-code-parallel-agent
# Claude Code에서 /setup 실행
```

`/setup` 스킬이 글로벌(`~/.claude/`) 또는 프로젝트(`./.claude/`) 중 선택하여 설치합니다.

### 방법 2: 수동 설치

```bash
git clone https://github.com/NoelYoon96/claude-code-parallel-agent.git
cd claude-code-parallel-agent

# hooks 복사
mkdir -p ~/.claude/hooks
cp .claude/hooks/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# skills 복사
cp -r .claude/skills/* ~/.claude/skills/

# settings.json은 기존 설정에 hooks 섹션을 수동으로 머지하세요
```

## 구성 요소

### Hooks (자동 실행)

| Hook | 트리거 | 동작 |
|------|--------|------|
| `load-recent-changes.sh` | 세션 시작 | 최근 git log 10개 + CHANGELOG를 컨텍스트에 자동 주입 |
| `commit-session.sh` | 세션 종료 | 미커밋 변경사항을 `WIP(<scope>): <요약>` 형식으로 자동 커밋 |

### Skills (슬래시 커맨드)

| 커맨드 | 용도 |
|--------|------|
| `/commit` | 변경사항 분석 → 컨벤셔널 커밋 메시지 생성 → 커밋 실행 |
| `/manage-skills` | 세션 변경사항 분석 → verify 스킬 자동 생성/업데이트 |
| `/verify-skill` | 프로젝트의 verify 스킬 전체 실행 → 통합 검증 보고서 |
| `/merge-worktree` | 워크트리 브랜치를 squash-merge → 체계적 커밋 메시지 생성 |
| `/setup` | 글로벌 또는 프로젝트에 hooks + skills 자동 설치 |

## 워크플로우

```
세션 시작 → 컨텍스트 자동 로드 → 병렬 워크트리에서 개발
    → /manage-skills로 검증 스킬 생성
    → /verify-skill로 품질 체크
    → /commit으로 컨벤셔널 커밋
    → 세션 종료 시 미커밋 변경 WIP 자동 저장
    → 다음 세션이 이전 작업을 자동으로 이어받음
```

### 자동화 수준

| 단계 | 자동화 | 개발자가 할 일 |
|------|--------|----------------|
| 컨텍스트 로드 | **완전 자동** | 없음 |
| 병렬 격리 | **자동** | worktree 생성만 실행 |
| 검증 스킬 생성 | **반자동** | `/manage-skills` 실행 |
| 품질 검증 | **반자동** | `/verify-skill` 실행 |
| 커밋 | **반자동** | `/commit` 실행 |
| WIP 저장 | **완전 자동** | 없음 |

## 핵심 메커니즘

### 1. Self-Healing Context
git log를 AI의 장기 기억으로 활용. 세션이 끊겨도 다음 세션에서 자동으로 이전 작업을 파악합니다.

### 2. Isolated Parallel Agents
git worktree로 에이전트별 격리된 작업 환경을 제공. 충돌 없이 N개 에이전트가 동시 작업 가능합니다.

### 3. Self-Evolving Verification
프로젝트 고유의 코드 규칙을 AI가 자동으로 탐지하고 verify 스킬로 축적합니다. 시간이 지날수록 검증이 정교해집니다.

### 4. Dual Commit Strategy
작업 중에는 `/commit`으로 정식 커밋, 세션 종료 시에는 Stop Hook이 WIP 자동 커밋. squash-merge로 깔끔한 히스토리를 유지합니다.

### 5. Session Safety Net
세션이 갑자기 종료되어도 Stop Hook이 tracked 파일을 WIP 커밋으로 자동 저장합니다. 작업이 유실되지 않습니다.

## 커밋 컨벤션

| Type | 설명 |
|------|------|
| **Feat** | 새로운 기능 추가 |
| **Fix** | 버그 수정 |
| **Refactor** | 코드 구조 개선 |
| **Style** | 코드 포맷, 린트 설정 변경 |
| **Docs** | 문서 추가/수정 |
| **Test** | 테스트 추가/수정 |
| **Chore** | 빌드, 의존성, 설정 파일 변경 |
| **Perf** | 성능 개선 |
| **Design** | UI 디자인 변경 |
| **Rename** | 파일/폴더명 수정 |
| **Remove** | 파일 삭제 |
| **WIP** | 작업 중 임시 저장 (세션 종료 시 자동) |
