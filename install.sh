#!/bin/bash
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "📦 Homebrew 설치 확인..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "📦 의존성 설치..."
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions
brew install neofetch
brew install tmux
brew install lazygit
brew install node

echo "📦 Claude Code 설치/업그레이드..."
if command -v claude &>/dev/null; then
    npm update -g @anthropic-ai/claude-code
else
    npm install -g @anthropic-ai/claude-code
fi

echo "🔗 심볼릭 링크 생성..."
# zshrc
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

# tmux
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf

# ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

# ---------- AI 코딩 도구 공통 지침 (SSOT) ----------
# ai/AGENTS.md 를 유일한 원본으로 두고, 각 도구가 읽는 위치·파일명으로 심볼릭 링크한다.
# 내용은 한 곳에서만 관리하며, 도구가 늘어나도 link_ai_config 한 줄만 추가하면 된다.
AI_SRC="$DOTFILES_DIR/ai"

# link_ai_config <대상디렉토리> <지침파일명>
#   예) link_ai_config ~/.claude CLAUDE.md  →  ~/.claude/CLAUDE.md, ~/.claude/skills
# 지식 원본은 ai/skills 한 곳뿐이다. Claude는 skills/ 를 자동 로드하고,
# 그 외 도구는 AGENTS.md 문서 맵의 skills/*/SKILL.md 링크로 참조한다.
# (문서 맵의 상대 경로가 풀리도록 skills/ 를 지침 파일 옆에 함께 링크한다.)
link_ai_config() {
    local target_dir="$1"
    local instruction_name="$2"
    mkdir -p "$target_dir"
    # 지침 파일: 도구가 요구하는 파일명으로 링크 (CLAUDE.md / AGENTS.md / GEMINI.md ...)
    ln -sfn "$AI_SRC/AGENTS.md" "$target_dir/$instruction_name"
    # 지식 원본 skills/ 를 지침 파일 옆에 링크
    [ -L "$target_dir/skills" ] && rm -f "$target_dir/skills"
    ln -sfn "$AI_SRC/skills" "$target_dir/skills"
}

# Claude Code
link_ai_config ~/.claude CLAUDE.md

# Codex CLI
link_ai_config ~/.codex AGENTS.md

# 추가 도구는 읽는 경로를 확인한 뒤 아래 형식으로 한 줄 추가:
#   Antigravity  →  link_ai_config ~/.config/<경로> AGENTS.md
#   Kimi / Gemini →  link_ai_config ~/.<경로> {AGENTS.md|GEMINI.md}

# ---------- 커스텀 명령어 ----------
# dev 명령어
bash "$DOTFILES_DIR/bin/dev/install.sh"

# devc 명령어
bash "$DOTFILES_DIR/bin/devc/install.sh"


# oh-my-zsh 설치
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 oh-my-zsh 설치..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "✅ 완료! ~/.zshrc.local에 로컬 환경변수를 설정하세요."
