#!/usr/bin/env bash
# 변경사항이 10개 이상일 때 자동으로 pull → push → PR 생성
# 사용: ./scripts/auto-pr-on-10-changes.sh
# post-commit 훅에서도 호출됨 (커밋 10개 이상 쌓이면 push + PR)

set -e
THRESHOLD=10
# 기본 브랜치: 환경변수 또는 origin 기본 브랜치 (main/flutter 등)
DEFAULT_BRANCH="${GIT_DEFAULT_BRANCH:-$(git remote show origin 2>/dev/null | sed -n 's/ *HEAD branch: //p' | tr -d ' ')}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# 현재 브랜치
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# 변경된 파일 수 (추적된 파일만: 수정/추가/삭제)
count_changed_files() {
  git status --short | wc -l | tr -d ' '
}

# origin/main 대비 앞선 커밋 수 (main이 없으면 origin 기본 브랜치 사용)
count_commits_ahead() {
  git rev-list --count "origin/${DEFAULT_BRANCH}..HEAD" 2>/dev/null || echo "0"
}

# 조건 충족 여부: 변경 파일 10개 이상 또는 커밋 10개 이상
run_flow() {
  local changed
  changed=$(count_changed_files)
  local ahead
  ahead=$(count_commits_ahead)

  if [ "$changed" -lt "$THRESHOLD" ] && [ "$ahead" -lt "$THRESHOLD" ]; then
    echo "[auto-pr] 변경 파일 ${changed}개, main 대비 커밋 ${ahead}개 (기준: ${THRESHOLD}개) → 스킵"
    return 1
  fi

  echo "[auto-pr] 변경 파일 ${changed}개, main 대비 커밋 ${ahead}개 → pull / push / PR 진행"

  # 1) Pull (기본 브랜치 최신화)
  echo "[auto-pr] git pull origin $DEFAULT_BRANCH"
  git pull origin "$DEFAULT_BRANCH" --no-edit || true

  # 2) uncommitted 변경이 10개 이상이면 커밋
  if [ "$(count_changed_files)" -ge "$THRESHOLD" ]; then
    echo "[auto-pr] 변경사항 커밋"
    git add -A
    git commit -m "chore: auto commit (${changed} changes)" || true
  fi

  # 3) main이면 브랜치 생성 후 push (PR용)
  if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
    BRANCH_NAME="auto-pr/$(date +%Y%m%d-%H%M%S)"
    echo "[auto-pr] main 브랜치이므로 작업 브랜치 생성: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"
    CURRENT_BRANCH="$BRANCH_NAME"
  fi

  # 4) Push
  echo "[auto-pr] git push origin $CURRENT_BRANCH"
  git push -u origin "$CURRENT_BRANCH"

  # 5) PR 생성 (gh 있으면)
  if command -v gh >/dev/null 2>&1; then
    echo "[auto-pr] gh pr create"
    gh pr create --base "$DEFAULT_BRANCH" --head "$CURRENT_BRANCH" --fill --title "Auto PR: ${CURRENT_BRANCH}" || true
  else
    echo "[auto-pr] GitHub CLI(gh)가 없어 PR은 수동으로 생성해주세요."
  fi

  return 0
}

run_flow
