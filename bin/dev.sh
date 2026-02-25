#!/bin/bash
# 1. 기본 설정
WORKTREE_BASE_DIR="$PWD/../.worktrees"
REPO_NAME=$(basename "$PWD")

if [ -n "$1" ]; then
    BRANCH_NAME=$1
    TARGET_PATH="$WORKTREE_BASE_DIR/$REPO_NAME/$BRANCH_NAME"
    SESSION_NAME="${REPO_NAME}_${BRANCH_NAME}"
    if [ ! -d "$TARGET_PATH" ]; then
        echo "🌿 워크트리 생성 중: $TARGET_PATH"
        git worktree add -b "$BRANCH_NAME" "$TARGET_PATH"
    fi
    cd "$TARGET_PATH"
else
    SESSION_NAME=$(basename "$PWD" | tr ' ./' '_')
    TARGET_PATH="$PWD"
fi

_tmux_go() {
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$1"
    else
        tmux attach-session -t "$1"
    fi
}

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    _tmux_go "$SESSION_NAME"
    exit 0
fi

echo "🚀 세션 시작: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME" -n "code" -c "$TARGET_PATH"
sleep 0.5
tmux send-keys -t "$SESSION_NAME:code" "opencode" Enter
tmux new-window -t "$SESSION_NAME" -n "git" -c "$TARGET_PATH"
tmux send-keys -t "$SESSION_NAME:git" "lazygit" Enter
tmux new-window -t "$SESSION_NAME" -n "term" -c "$TARGET_PATH"
tmux select-window -t "$SESSION_NAME:code"
_tmux_go "$SESSION_NAME"
