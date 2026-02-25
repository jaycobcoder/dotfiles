# Ghostty terminfo 호환 문제 해결
if [[ "$TERM" == "xterm-ghostty" ]]; then
  export TERM=xterm-256color
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git)
source $ZSH/oh-my-zsh.sh

prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

/opt/homebrew/bin/neofetch

export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export PATH=/opt/homebrew/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# 로컬 환경별 설정 (git에 안 올라감)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
