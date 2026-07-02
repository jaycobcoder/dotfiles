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

# opencode
mkdir -p ~/.config/opencode
ln -sf "$DOTFILES_DIR/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sf "$DOTFILES_DIR/opencode/tui.json" ~/.config/opencode/tui.json

# claude
# claude/ 최상위 항목(파일/디렉토리)을 ~/.claude로 심볼릭 링크한다.
# 디렉토리를 통째로 링크하므로 skills/, docs/ 안에 파일이 추가돼도
# 새 심볼릭 링크가 필요 없다. claude/ 바로 아래에 새 항목을 추가하면
# install.sh를 다시 실행하기만 하면 자동으로 링크된다.
mkdir -p ~/.claude
for entry in "$DOTFILES_DIR"/claude/*; do
    name="$(basename "$entry")"
    # docs/는 skills/로 이관됨 — 사람이 읽는 아카이브로만 남기고 링크하지 않는다.
    [ "$name" = "docs" ] && continue
    ln -sfn "$entry" ~/.claude/"$name"
done

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
