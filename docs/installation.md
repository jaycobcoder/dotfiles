# 설치 가이드

## 사전 요구사항

| 요구사항 | 설명 |
|-------------|-------|
| **macOS** | Apple Silicon(M 시리즈)에서 검증했다. Intel Mac에서도 동작하겠지만 검증하지 않았다. |
| **Git** | Xcode Command Line Tools를 통해 macOS에 기본 설치되어 있다. 없다면 `xcode-select --install`을 실행한다. |
| **인터넷 연결** | Homebrew와 oh-my-zsh 설치에 필요하다. |

## 빠른 시작

```bash
git clone https://github.com/jaycobcoder/dotfiles.git ~/company/dotfiles
cd ~/company/dotfiles
bash install.sh
```

이게 전부다. 스크립트 하나가 모든 것을 처리한다.

## `install.sh`가 하는 일

설치 스크립트는 다음 단계를 순서대로 수행한다.

### 1단계: Homebrew

`brew` 사용 가능 여부를 확인한다. 없으면 [Homebrew](https://brew.sh/)를 자동으로 설치한다.

```bash
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
```

### 2단계: 의존성 패키지

Homebrew로 다음 패키지를 설치한다.

| 패키지 | 용도 |
|---------|------|
| `zsh-syntax-highlighting` | 셸에서 실시간 구문 색상 표시 |
| `zsh-autosuggestions` | Fish 스타일 명령어 자동완성 |
| `neofetch` | 셸 시작 시 시스템 정보 표시 |
| `tmux` | 세션 관리를 위한 터미널 멀티플렉서 |
| `lazygit` | git 작업을 위한 터미널 UI |
| `node` | Node.js 런타임 (Claude Code 설치에 필요) |

### 3단계: Claude Code 설치/업그레이드

npm으로 Claude Code를 설치한다. 이미 설치되어 있으면 최신 버전으로 업그레이드한다.

```bash
if command -v claude &>/dev/null; then
    npm update -g @anthropic-ai/claude-code
else
    npm install -g @anthropic-ai/claude-code
fi
```

### 4단계: 심볼릭 링크

저장소의 설정 파일을 시스템이 기대하는 위치로 심볼릭 링크한다.

| 원본 (저장소 내부) | 대상 (시스템) |
|------------------|--------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `ghostty/config` | `~/.config/ghostty/config` |

모든 심볼릭 링크는 `ln -sf`(강제 모드)를 사용하므로 기존 파일을 덮어쓴다. 필요하면 실행 전에 기존 설정을 백업한다.

### 5단계: AI 코딩 도구 공통 지침 (SSOT)

지침 원본을 `ai/AGENTS.md` 한 곳에만 두고, 각 도구(Claude, Codex 등)가 읽는 위치·파일명으로 심볼릭 링크한다. 컨벤션 지식은 `ai/skills/`에 한 벌만 두며, 지침 파일 옆에 함께 링크되어 문서 맵의 상대 경로가 풀리도록 한다.

`link_ai_config <대상디렉토리> <지침파일명>` 함수가 지침 파일과 `skills/`를 함께 링크한다.

| 원본 (저장소 내부) | 대상 (시스템) | 도구 |
|------------------|--------------|------|
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md` | Claude Code |
| `ai/skills` | `~/.claude/skills` | Claude Code |
| `ai/AGENTS.md` | `~/.codex/AGENTS.md` | Codex CLI |
| `ai/skills` | `~/.codex/skills` | Codex CLI |
| `ai/AGENTS.md` | `~/.gemini/GEMINI.md` | Antigravity (agy) |
| `ai/skills` | `~/.gemini/skills` | Antigravity (agy) |

내용은 한 곳에서만 관리하므로, 도구가 늘어나도 `install.sh`에 `link_ai_config <디렉토리> <파일명>` 한 줄만 추가하면 된다.

```bash
# Claude Code
link_ai_config ~/.claude CLAUDE.md

# Codex CLI
link_ai_config ~/.codex AGENTS.md

# Antigravity CLI (agy)
link_ai_config ~/.gemini GEMINI.md
```

### 6단계: oh-my-zsh

`~/.oh-my-zsh`가 존재하지 않으면 [oh-my-zsh](https://ohmyz.sh/)를 무인(unattended) 모드로 설치한다.

## 설치 이후

### 설치 검증

```bash
# 심볼릭 링크 확인
ls -la ~/.zshrc ~/.tmux.conf ~/.config/ghostty/config ~/.claude/CLAUDE.md ~/.claude/skills

# 설치된 패키지 확인
brew list | grep -E "tmux|lazygit|neofetch|zsh-syntax|zsh-auto|node"
```

### 로컬 설정

머신마다 다르고 git에 커밋해서는 안 되는 설정은 `~/.zshrc.local`에 작성한다.

```bash
# 예시: ~/.zshrc.local

# 회사 전용 환경변수
export COMPANY_API_KEY="your-api-key-here"

# 머신별 경로
export ANDROID_HOME="$HOME/Library/Android/sdk"

# 기본 설정 재정의
export DEFAULT_USER="kiwooso"
```

이 파일은 존재하면 `.zshrc`가 자동으로 source한다.

### Ghostty 호환 터미널 설치

이 dotfiles의 Ghostty 키바인딩은 터미널 에뮬레이터로 [Ghostty](https://ghostty.org/)를 사용할 때만 동작한다. 다른 터미널을 사용하면 `Cmd+1/2/3` 창 전환은 동작하지 않는다(그 외 나머지는 정상 동작한다).

## 트러블슈팅

### `brew: command not found`

Homebrew가 아직 PATH에 없을 수 있다. 다음을 실행한다.

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

이후 `bash install.sh`를 다시 실행한다.

### 심볼릭 링크 충돌

심볼릭 링크가 아닌 기존 설정 파일이 있으면 `ln -sf`가 덮어쓴다. 기존 설정을 보존하려면 설치 전에 백업한다.

```bash
# 설치 전 백업
cp ~/.zshrc ~/.zshrc.backup
cp ~/.tmux.conf ~/.tmux.conf.backup
```

### oh-my-zsh 이미 설치됨

`~/.oh-my-zsh`에 oh-my-zsh가 이미 있으면 설치 스크립트는 이 단계를 건너뛴다. 별도 조치는 필요 없다.

### Ghostty terminfo 문제

Ghostty에서 렌더링 깨짐이 보이면, `.zshrc`가 이미 이를 처리한다.

```bash
if [[ "$TERM" == "xterm-ghostty" ]]; then
  export TERM=xterm-256color
fi
```

Ghostty 안에서 실행될 때 TERM 값을 `xterm-256color`로 강제하여, `xterm-ghostty` terminfo 항목을 인식하지 못하는 도구와의 호환성 문제를 피한다.

## 재설치 / 업데이트 (멱등성)

설치 스크립트는 **멱등적**이다. 다시 실행하면 다음과 같이 동작한다.

- 이미 설치되어 있으면 Homebrew 설치를 건너뛴다
- brew 패키지를 재설치/업그레이드한다
- Claude Code를 최신 버전으로 업그레이드한다
- 심볼릭 링크를 덮어쓴다(같은 저장소 파일을 가리킴)
- 이미 설치되어 있으면 oh-my-zsh를 건너뛴다

새 변경 사항을 받은 뒤 업데이트하려면 다음을 실행한다.

```bash
cd ~/company/dotfiles
git pull
bash install.sh
```
