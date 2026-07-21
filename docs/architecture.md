# 아키텍처 및 설계

이 문서는 dotfiles 저장소의 구조적 결정을 설명한다 — 파일을 어떻게 조직하고, 어떻게 시스템 위치로 배치하며, 의존성을 어떻게 관리하고, 특정 패턴을 왜 선택했는지 다룬다.

---

## 디렉토리 구조

```
dotfiles/
├── .git/                          # Git 저장소
├── .gitignore                     # .worktrees/ 무시
├── README.md                      # 빠른 시작 문서 (한글)
├── install.sh                     # 마스터 설치 스크립트 (진입점)
│
├── zsh/
│   └── .zshrc                     # Zsh 셸 설정
│
├── tmux/
│   └── .tmux.conf                 # tmux 멀티플렉서 설정
│
├── ghostty/
│   └── config                     # Ghostty 터미널 설정
│
├── ai/                            # AI 코딩 도구 공통 지침 (SSOT)
│   ├── AGENTS.md                  # 지침 원본
│   └── skills/                    # 지식 원본 (스킬 3종)
│       ├── coding-convention/     # SKILL.md + reference/
│       ├── writing-test-code/     # SKILL.md + reference/
│       └── preventing-duplicate-requests/  # SKILL.md
│
└── docs/
    ├── overview.md                # 프로젝트 개요와 철학
    ├── installation.md            # 설치 가이드
    ├── configuration.md           # 설정 파일 레퍼런스
    └── architecture.md            # 이 파일
```

### 네이밍 컨벤션

- **설정 디렉토리**는 해당 도구 이름을 따른다: `zsh/`, `tmux/`, `ghostty/`
- **설정 파일**은 원래 이름(선행 점 포함)을 유지한다: `.zshrc`, `.tmux.conf`
- **AI 공통 지침**은 `ai/` 아래에 원본을 한 벌만 둔다: 지침 문서 `AGENTS.md`, 지식 원본 `skills/`

---

## 심볼릭 링크 전략

이 dotfiles 저장소의 핵심 메커니즘은 **심볼릭 링크**다. 설정 파일은 git 저장소 안에 두고, 심볼릭 링크로 각 도구가 기대하는 위치와 연결한다.

### 심볼릭 링크 맵

| 원본(저장소) | 대상(시스템) | 생성 주체 |
|------------------------|-------------------|------------|
| `zsh/.zshrc` | `~/.zshrc` | `install.sh` |
| `tmux/.tmux.conf` | `~/.tmux.conf` | `install.sh` |
| `ghostty/config` | `~/.config/ghostty/config` | `install.sh` |
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md` | `install.sh` (`link_ai_config`) |
| `ai/skills` | `~/.claude/skills` | `install.sh` (`link_ai_config`) |
| `ai/AGENTS.md` | `~/.codex/AGENTS.md` | `install.sh` (`link_ai_config`) |
| `ai/skills` | `~/.codex/skills` | `install.sh` (`link_ai_config`) |

### 동작 원리

```
~/company/dotfiles/zsh/.zshrc    ← 실제 파일 (git 추적 대상)
         ↑
         │  ln -sf
         │
~/.zshrc                          ← 심볼릭 링크 (Zsh가 읽는 대상)
```

일반 설정 파일 링크는 `ln -sf`(symbolic, force)로 생성한다:
- **`-s`**: 심볼릭 링크를 만든다(하드 링크가 아니므로 파일시스템을 넘나들어도 동작한다)
- **`-f`**: 대상 경로에 이미 파일이나 링크가 있으면 덮어쓴다

디렉토리를 가리키는 링크(예: `skills/`)나 이미 존재하는 심볼릭 링크를 갱신할 때는 `ln -sfn`을 사용한다:
- **`-n`**: 대상이 이미 디렉토리를 가리키는 심볼릭 링크일 때, 그 안으로 들어가 링크를 생성하지 않고 링크 자체를 교체한다

이 방식은 다음을 의미한다:
- `~/.zshrc`를 직접 편집하는 것은 저장소 안의 파일을 편집하는 것과 같다(심볼릭 링크로 동일 파일이다)
- 저장소에서 `git diff`는 어느 경로로 편집했든 변경을 보여준다
- `install.sh`를 다시 실행해도 모든 심볼릭 링크가 안전하게 재생성된다(멱등)

### 왜 심볼릭 링크인가(복사가 아니라)

검토한 대안:
- **파일 복사**: 시스템 위치의 변경이 저장소에 반영되지 않아 수동 동기화가 필요하다
- **GNU Stow**: 심볼릭 링크 관리를 자동화하는 도구다. 링크 수가 적은데도 의존성을 하나 추가하게 된다. 현재 방식은 명시적인 `ln -sf` 명령으로 단순함을 유지한다
- **홈 디렉토리 자체를 저장소로**: `$HOME`을 git 저장소로 쓰는 방식이다. 홈의 모든 파일이 `git status`를 어지럽히고 방대한 `.gitignore` 규칙이 필요하다

심볼릭 링크는 최적의 균형을 제공한다: 저장소는 깔끔하게 유지되고, 편집이 즉시 반영되며, 메커니즘이 투명하다.

### `link_ai_config` 헬퍼로 여러 도구에 지침 링크하기

AI 지침은 도구마다 읽는 파일명과 위치가 다르다(자세한 배경은 아래 "AI 지침 SSOT 설계" 참고). 이를 위해 `install.sh`는 `link_ai_config` 헬퍼 함수를 둔다.

```bash
# link_ai_config <대상디렉토리> <지침파일명>
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

link_ai_config ~/.claude CLAUDE.md
link_ai_config ~/.codex AGENTS.md
```

함수는 두 가지를 한다:
1. 원본 `ai/AGENTS.md`를 도구가 요구하는 파일명(`CLAUDE.md`, `AGENTS.md` 등)으로 링크한다
2. 지식 원본 `ai/skills/`를 지침 파일 바로 옆에 링크한다. 문서 맵의 `skills/*/SKILL.md` 상대 경로가 풀리도록 하기 위함이다

도구를 추가할 때는 읽는 경로를 확인한 뒤 `link_ai_config` 호출을 **한 줄** 더하기만 하면 된다.

---

## 의존성 관리

### Homebrew 패키지

의존성은 단일 진입점인 `install.sh`에서 설치한다. 마스터 설치 스크립트가 셸 환경과 개발 도구에 필요한 패키지를 설치한다:

```bash
brew install zsh-syntax-highlighting  # 셸 구문 색상
brew install zsh-autosuggestions       # 명령 자동 제안
brew install neofetch                  # 시스템 정보 표시
brew install tmux                      # 터미널 멀티플렉서
brew install lazygit                   # Git TUI
brew install node                      # Node.js (Claude Code npm 설치용)
```

Homebrew 패키지 설치에 이어 Claude Code CLI를 npm으로 설치하거나 업그레이드한다:

```bash
if command -v claude &>/dev/null; then
    npm update -g @anthropic-ai/claude-code
else
    npm install -g @anthropic-ai/claude-code
fi
```

모든 의존성을 하나의 스크립트에서 관리하므로 별도 Brewfile이나 하위 설치 스크립트 없이 명령 한 번으로 환경 전체를 구성한다.

---

## `.zshrc.local` 패턴

### 문제

일부 설정은 머신마다 다르며 git에 커밋해서는 안 된다:
- API 키와 시크릿
- 회사 내부 환경변수
- 머신마다 다른 경로(예: SDK 위치)
- 사용자별 선호 설정(예: `DEFAULT_USER`)

### 해결

`.zshrc`는 다음 줄로 끝난다:

```bash
# .zshrc의 마지막 줄
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

이는 `~/.zshrc.local`이 **존재할 때만** 조건부로 source 한다. 이 파일은:
- 로컬 머신에만 존재한다
- dotfiles 저장소가 생성하거나 관리하지 않는다
- `.gitignore`에 넣을 필요가 없다(저장소 디렉토리 바깥에 있으므로 애초에 추적되지 않는다)
- 가장 마지막에 실행되므로 `.zshrc`의 어떤 설정이든 덮어쓸 수 있다

### 실행 순서

```
셸 시작
  └── ~/.zshrc source (심볼릭 링크 → dotfiles/zsh/.zshrc)
        ├── Ghostty terminfo 보정
        ├── oh-my-zsh 설정
        ├── prompt_context 재정의
        ├── 구문 강조 & 자동 제안
        ├── neofetch
        ├── JAVA_HOME, PATH
        └── ~/.zshrc.local source (존재할 때)
              └── 머신별 재정의
```

### `.zshrc.local` 예시

```bash
# 회사 머신
export DEFAULT_USER="kiwooso"
export COMPANY_PROXY="http://proxy.internal:8080"
export ARTIFACTORY_TOKEN="eyJ..."

# 개인 머신
export DEFAULT_USER="jaycob"
export GOPATH="$HOME/go"
```

---

## AI 지침 SSOT 설계

### 문제

Claude Code, Codex 등 여러 AI 코딩 도구를 함께 쓰는데, 도구마다 읽는 지침 파일명이 다르다(`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`). 도구별로 지침을 복제해서 관리하면 시간이 지날수록 내용이 서로 갈라진다(drift).

### 해결

지침 원본을 `ai/AGENTS.md` **한 곳**에만 둔다. 그리고 각 도구가 읽는 위치·파일명으로 심볼릭 링크한다(SSOT, Single Source of Truth). 컨벤션·테스트 등 지식도 `ai/skills/`에 한 벌만 둔다.

- `link_ai_config <디렉토리> <지침파일명>` 함수가 `AGENTS.md`를 해당 파일명으로 링크하고, `skills/`를 그 옆에 함께 링크한다
- 도구 추가는 함수 호출 한 줄로 끝난다
- **로딩 차이**: Claude는 `skills/`를 자동으로 로드한다. 그 외 도구는 `AGENTS.md` 문서 맵에 있는 `skills/*/SKILL.md` 링크를 참조하는 방식으로 지식에 접근한다. 이 때문에 지침 파일 옆에 `skills/` 링크를 함께 두어 문서 맵의 상대 경로가 풀리도록 한다

이 설계로 내용은 한 곳에서만 수정하면 되고, 도구가 늘어나도 원본이 갈라지지 않는다.

---

## 설치 스크립트 설계

### 멱등성

`install.sh`의 모든 작업은 여러 번 실행해도 안전하다:

| 작업 | 멱등성 수단 |
|-----------|----------------------|
| Homebrew 설치 | `command -v brew` 체크 — 이미 있으면 건너뜀 |
| `brew install` | 이미 설치된 패키지는 Homebrew가 no-op 처리 |
| Claude Code 설치 | `command -v claude` 체크로 install/update 분기 |
| `ln -sf` / `ln -sfn` | force 플래그로 기존 링크 덮어쓰기 |
| `mkdir -p` | 디렉토리가 있으면 no-op |
| oh-my-zsh 설치 | `[ ! -d "$HOME/.oh-my-zsh" ]` 체크 |

### 실행 흐름

```
install.sh
├── 1. Homebrew 확인/설치
├── 2. brew install (zsh-syntax-highlighting, zsh-autosuggestions,
│                    neofetch, tmux, lazygit, node)
├── 3. Claude Code npm 설치/업그레이드
├── 4. 심볼릭 링크 (.zshrc, .tmux.conf, ghostty/config)
├── 5. AI 지침 SSOT 링크 (link_ai_config)
│     ├── ~/.claude   (CLAUDE.md, skills)
│     └── ~/.codex    (AGENTS.md, skills)
└── 6. oh-my-zsh 설치 (없을 때만)
```

---

## 설계 결정 요약

| 결정 | 선택 | 근거 |
|----------|--------|-----------|
| 설정 배포 | 심볼릭 링크(`ln -sf` / `ln -sfn`) | 즉시 반영, 투명함, 동기화 불필요 |
| 패키지 관리자 | Homebrew | macOS의 사실상 표준 |
| 셸 프레임워크 | oh-my-zsh | 풍부한 플러그인 생태계, 널리 지원되는 테마 |
| 로컬 재정의 | `.zshrc.local` 패턴 | 공용 설정과 머신별 설정의 깔끔한 분리 |
| AI 지침 관리 | SSOT (단일 원본 + 심볼릭 링크) | 원본을 한 곳에 두고 도구별 위치로 링크, drift 방지 |
| 설치 방식 | 단일 진입점(`install.sh`) | 명령 한 번으로 전체 구성 |
| 멱등성 | check-before-act 패턴 | 언제든 안전하게 재실행 |
