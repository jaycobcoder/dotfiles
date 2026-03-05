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
