#!/bin/bash
# devc - dev로 만든 tmux 세션과 git worktree를 제거

WORKTREE_BASE_DIR="$(cd "$PWD/.." && pwd)/.worktrees"
REPO_NAME=$(basename "$PWD")

FORCE=false
BRANCH_NAME=""

# 인자 파싱
for arg in "$@"; do
    if [ "$arg" = "-f" ]; then
        FORCE=true
    else
        BRANCH_NAME="$arg"
    fi
done

# 브랜치명 없으면 현재 디렉토리 기준 (세션만 제거)
if [ -z "$BRANCH_NAME" ]; then
    SESSION_NAME=$(basename "$PWD" | tr ' ./' '_')
    echo "🗑️  tmux 세션 제거: $SESSION_NAME"
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
    else
        echo "⚠️  tmux 세션 없음: $SESSION_NAME"
    fi
    echo "✅ 완료"
    exit 0
fi

TARGET_PATH="$WORKTREE_BASE_DIR/$REPO_NAME/$BRANCH_NAME"
SESSION_NAME="${REPO_NAME}_${BRANCH_NAME}"

# 1. tmux 세션 제거
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "🗑️  tmux 세션 제거: $SESSION_NAME"
    tmux kill-session -t "$SESSION_NAME"
else
    echo "⚠️  tmux 세션 없음: $SESSION_NAME"
fi

# 2. git worktree 제거
if [ -d "$TARGET_PATH" ]; then
    echo "🌿 워크트리 제거: $TARGET_PATH"
    if [ "$FORCE" = true ]; then
        git worktree remove --force "$TARGET_PATH"
        git branch -D "$BRANCH_NAME"
    else
        git worktree remove "$TARGET_PATH"
        git branch -d "$BRANCH_NAME"
    fi
else
    echo "⚠️  워크트리 없음: $TARGET_PATH"
fi

echo "✅ 완료"
