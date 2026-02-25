#!/bin/bash
CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)

mkdir -p ~/.local/bin

if [ -f "$CURRENT_DIR/devc.sh" ]; then
    ln -sf "$CURRENT_DIR/devc.sh" ~/.local/bin/devc
    chmod +x ~/.local/bin/devc
    echo "🔗 devc.sh -> ~/.local/bin/devc 연결 완료!"
elif [ -f "$CURRENT_DIR/devc" ]; then
    ln -sf "$CURRENT_DIR/devc" ~/.local/bin/devc
    chmod +x ~/.local/bin/devc
    echo "🔗 devc -> ~/.local/bin/devc 연결 완료!"
else
    echo "❌ 에러: 실행할 devc 파일을 찾을 수 없습니다."
fi

echo "✅ 완료!"
