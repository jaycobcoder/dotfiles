#!/bin/bash
# 1. 기본 설정
WORKTREE_BASE_DIR="$(cd "$PWD/.." && pwd)/.worktrees"

REPO_NAME=$(basename "$PWD")
# 2. 인자가 있으면 워크트리 모드로 작동
if [ -n "$1" ]; then
    BRANCH_NAME=$1
    TARGET_PATH="$WORKTREE_BASE_DIR/$REPO_NAME/$BRANCH_NAME"
    SESSION_NAME="${REPO_NAME}_${BRANCH_NAME}"
    # 워크트리가 없으면 생성 (브랜치도 함께 생성)
    if [ ! -d "$TARGET_PATH" ]; then
        echo "🌿 워크트리 생성 중: $TARGET_PATH"
        if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
            git worktree add "$TARGET_PATH" "$BRANCH_NAME"
        else
            git worktree add -b "$BRANCH_NAME" "$TARGET_PATH"
        fi
    fi
    cd "$TARGET_PATH"
else
    # 인자가 없으면 현재 폴더명 사용
    SESSION_NAME=$(basename "$PWD" | tr ' ./' '_')
    TARGET_PATH="$PWD"
fi
# 3. 이미 세션이 있으면 연결하고 종료
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi
# 4. 새 tmux 세션 생성 및 윈도우 구성
echo "🚀 세션 시작: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME" -n "code" -c "$TARGET_PATH"
sleep 0.5
# 1번 창: AI 에이전트 실행 (opencode는 본인이 사용하는 에이전트 명령어로 변경 가능)
tmux send-keys -t "$SESSION_NAME:code" "opencode" Enter
# 2번 창: lazygit 실행
tmux new-window -t "$SESSION_NAME" -n "git" -c "$TARGET_PATH"
tmux send-keys -t "$SESSION_NAME:git" "lazygit" Enter
# 3번 창: 일반 터미널
tmux new-window -t "$SESSION_NAME" -n "term" -c "$TARGET_PATH"
# 첫 번째 창으로 포커스 후 접속
tmux select-window -t "$SESSION_NAME:code"
tmux attach-session -t "$SESSION_NAME"

