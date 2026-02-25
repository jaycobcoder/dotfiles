#!/bin/bash

# 현재 install.sh가 있는 이 폴더의 절대 경로를 가져옵니다.
CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)

# 1. Homebrew 설치 확인
if ! command -v brew &> /dev/null; then
    echo "🍺 Homebrew를 설치합니다..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Brewfile 설치 (현재 폴더의 Brewfile 사용)
echo "📦 필요한 도구들을 설치합니다 ($CURRENT_DIR/Brewfile 사용)..."
brew bundle --file="$CURRENT_DIR/Brewfile"

# 3. dev.sh를 ~/.local/bin/dev 로 연결
mkdir -p ~/.local/bin

# 실제 파일명이 dev.sh 인지 dev 인지 확인해서 연결합니다.
if [ -f "$CURRENT_DIR/dev.sh" ]; then
    ln -sf "$CURRENT_DIR/dev.sh" ~/.local/bin/dev
    chmod +x ~/.local/bin/dev
    echo "🔗 dev.sh -> ~/.local/bin/dev 연결 완료!"
elif [ -f "$CURRENT_DIR/dev" ]; then
    ln -sf "$CURRENT_DIR/dev" ~/.local/bin/dev
    chmod +x ~/.local/bin/dev
    echo "🔗 dev -> ~/.local/bin/dev 연결 완료!"
else
    echo "❌ 에러: 실행할 dev 파일을 찾을 수 없습니다."
fi

echo "--------------------------------------------------------"
echo "✅ 모든 작업이 완료되었습니다."
echo "⚠️  아직 안 하셨다면 .zshrc에 아래 줄을 추가해 주세요:"
echo 'export PATH="$HOME/.local/bin:$PATH"'
echo "--------------------------------------------------------"
