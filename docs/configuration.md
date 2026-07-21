# 설정 레퍼런스

이 문서는 저장소의 모든 설정 파일과 각 설정의 역할, 커스터마이징 방법을 설명한다.

---

## Zsh — `zsh/.zshrc`

**심볼릭 링크 대상**: `~/.zshrc`

새 Zsh 세션이 시작될 때마다 소싱되는 셸 설정 파일이다.

### Ghostty Terminfo 호환 처리

```bash
if [[ "$TERM" == "xterm-ghostty" ]]; then
  export TERM=xterm-256color
fi
```

Ghostty는 `TERM=xterm-ghostty`를 설정하지만, 많은 CLI 도구(예: 구버전 ncurses 기반 프로그램)가 이 terminfo 항목을 인식하지 못한다. 이 오버라이드는 어디서나 지원되는 `xterm-256color`를 강제해 렌더링 문제를 방지한다.

### oh-my-zsh 설정

```bash
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git)
source $ZSH/oh-my-zsh.sh
```

| 설정 | 값 | 설명 |
|---------|-------|-------------|
| `ZSH_THEME` | `agnoster` | Powerline 스타일 프롬프트 테마. 올바르게 표시되려면 [Nerd Font](https://www.nerdfonts.com/) 또는 Powerline 패치 폰트가 필요하다. |
| `plugins` | `(git)` | git 별칭과 프롬프트 통합(브랜치명 표시, 변경 상태 표시 등)을 활성화한다. |

### 커스텀 프롬프트 컨텍스트

```bash
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}
```

agnoster 테마의 기본 프롬프트 컨텍스트 동작을 오버라이드한다.
- 로컬 머신에서 기본 사용자로 접속했을 때는 `user@hostname` 세그먼트를 **숨긴다**(프롬프트 잡음 감소).
- 다른 사용자로 로그인했거나 SSH로 접속했을 때는 사용자명을 **표시한다**.
- 이를 활성화하려면 `~/.zshrc.local`에서 `DEFAULT_USER`를 설정한다.
  ```bash
  export DEFAULT_USER="kiwooso"
  ```

### 셸 플러그인

```bash
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

| 플러그인 | 효과 |
|--------|--------|
| **zsh-syntax-highlighting** | 입력하는 동안 명령을 색으로 표시한다 — 유효한 명령은 초록색, 잘못된 명령은 빨간색. Enter를 누르기 전에 오타를 잡는 데 도움이 된다. |
| **zsh-autosuggestions** | 히스토리에서 명령을 회색 흐린 텍스트로 제안한다. `→`(오른쪽 화살표)를 눌러 수락한다. |

둘 다 oh-my-zsh 플러그인이 아니라 Homebrew로 설치되며 `/opt/homebrew/share/`에서 소싱된다.

### 시작 시 neofetch 실행

```bash
/opt/homebrew/bin/neofetch
```

새 터미널 세션이 시작될 때마다 시스템 정보(OS, 커널, 셸, CPU, 메모리 등)를 표시한다. 순전히 장식용이다. 셸 시작 속도를 높이고 싶다면 이 줄을 삭제한다.

### 환경 변수

```bash
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export PATH=/opt/homebrew/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
```

| 변수 | 값 | 용도 |
|----------|-------|---------|
| `JAVA_HOME` | Zulu JDK 17 경로 | 기본 Java 런타임을 지정한다. Java/Kotlin/Android 빌드 도구가 사용한다. |
| `PATH` 추가 | `/opt/homebrew/bin`, `~/.local/bin` | Homebrew 바이너리와 커스텀 명령을 찾을 수 있도록 한다. |

### 로컬 설정 훅

```bash
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

**이 줄은 의도적으로 `.zshrc`의 마지막 줄에 둔다.** `~/.zshrc.local` 파일이 존재하면 소싱한다. 가장 마지막에 실행되므로, 로컬 설정이 위에 정의된 모든 설정을 오버라이드할 수 있다.

`~/.zshrc.local`의 활용 예시:
- 회사별 환경 변수나 API 키
- 머신별 `JAVA_HOME`이나 SDK 경로
- 프롬프트 커스터마이징을 위한 `DEFAULT_USER`
- git에 커밋하고 싶지 않은 모든 설정

---

## Tmux — `tmux/.tmux.conf`

**심볼릭 링크 대상**: `~/.tmux.conf`

사용 편의성에 초점을 맞춘 최소 tmux 설정이다.

### 1-기반 윈도우 인덱싱

```
set -g base-index 1
```

기본적으로 tmux는 윈도우 번호를 0부터 매긴다. 이 설정은 1부터 시작하도록 바꿔, 윈도우 번호가 키보드 배열과 일치하게 한다: `Cmd+1`은 윈도우 1로, `Cmd+2`는 윈도우 2로 이동한다. 아래 Ghostty 키바인딩과 정렬된다.

### 프리픽스 키 재매핑

```
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

| 기본값 | 커스텀 | 이유 |
|---------|--------|--------|
| `Ctrl-B` | `Ctrl-A` | `Ctrl-A`가 손이 더 편하다 — `A` 키는 홈 로우에 있다. tmux 프리픽스는 하루에 수백 번 사용하므로 손 편의성 이점이 크다. |

`bind C-a send-prefix`는 `Ctrl-A`를 두 번 눌러 tmux 내부 프로그램에 리터럴 `Ctrl-A`를 보낼 수 있게 한다(예: GNU screen이나 readline의 줄 맨 앞 이동).

---

## Ghostty — `ghostty/config`

**심볼릭 링크 대상**: `~/.config/ghostty/config`

[Ghostty](https://ghostty.org/) 터미널 에뮬레이터 설정이다.

### 키바인딩 — Cmd+숫자로 Tmux 윈도우 전환

```
keybind = super+digit_1=text:\x01\x31
keybind = super+digit_2=text:\x01\x32
keybind = super+digit_3=text:\x01\x33
```

이 dotfiles 전체에서 가장 중요한 설정이다. 동작 방식은 다음과 같다.

| 키 입력 | Ghostty가 보내는 값 | 디코딩 결과 | Tmux가 해석하는 결과 |
|----------|---------------|------------|---------------------|
| `Cmd+1` | `\x01\x31` | `Ctrl-A` + `1` | 윈도우 1로 전환 (`code`) |
| `Cmd+2` | `\x01\x32` | `Ctrl-A` + `2` | 윈도우 2로 전환 (`git`) |
| `Cmd+3` | `\x01\x33` | `Ctrl-A` + `3` | 윈도우 3으로 전환 (`term`) |

- `\x01` = `Ctrl-A`(tmux 프리픽스)의 ASCII 코드
- `\x31` = `1`의 ASCII 코드, `\x32` = `2`, `\x33` = `3`

이를 통해 tmux 윈도우 전환이 브라우저 탭 전환처럼 느껴진다 — `Ctrl-A` 다음 `숫자`라는 2단계 대신 한 번의 `Cmd+숫자` 입력으로 끝난다.

**전제 조건**: tmux 프리픽스가 `Ctrl-A`로 설정되어 있어야 한다(위 tmux 설정 참고). 기본 `Ctrl-B` 프리픽스를 쓴다면 `\x01`을 `\x02`로 바꾼다.

### 테마

```
theme=catppuccin mocha
```

[Catppuccin Mocha](https://github.com/catppuccin/catppuccin) 색 구성표를 사용한다 — 파스텔 강조색이 들어간 따뜻한 다크 테마다. Ghostty는 Catppuccin 테마를 기본 내장한다.

### 폰트

```
font-family = IBM Plex Mono
font-size = 13
font-thicken=true
font-feature=-liga
```

| 설정 | 값 | 설명 |
|---------|-------|-------------|
| `font-family` | `IBM Plex Mono` | IBM의 고정폭 폰트. 깔끔하고 읽기 좋으며 유니코드 커버리지가 좋다. [별도로 설치](https://github.com/IBM/plex)해야 한다. |
| `font-size` | `13` | 폰트 크기(포인트). |
| `font-thicken` | `true` | 글리프를 약간 굵게 만들어 고해상도 화면에서 가독성을 높인다. |
| `font-feature` | `-liga` | 리거처를 비활성화한다. `!=`, `=>`, `->`를 하나의 글리프로 합치지 않고 별개 문자로 유지한다. |

### 윈도우 패딩

```
window-padding-x = 10
window-padding-y = 10
```

터미널 내용과 윈도우 가장자리 사이에 모든 방향으로 10픽셀의 패딩을 추가한다. 텍스트가 윈도우 테두리에 닿지 않게 해 가독성을 높인다.

---

## AI 지침 (SSOT) — `ai/AGENTS.md` & `ai/skills/`

**심볼릭 링크 대상**: `~/.claude/CLAUDE.md`, `~/.claude/skills`, `~/.codex/AGENTS.md`, `~/.codex/skills`

여러 AI 코딩 도구를 함께 사용하는데, 도구마다 읽는 지침 파일명이 다르다.

| 도구 | 읽는 지침 파일명 |
|---|---|
| Claude Code | `CLAUDE.md` |
| Codex | `AGENTS.md` |
| Antigravity (agy) / Gemini | `GEMINI.md` |

파일명이 제각각이지만 내용은 동일해야 하므로, 지침 원본을 `ai/AGENTS.md` **한 곳**에만 두고 각 도구가 읽는 위치·파일명으로 심볼릭 링크한다. 내용을 수정할 때는 이 한 곳만 고치면 모든 도구에 반영된다. 이것이 이 디렉토리를 SSOT(Single Source of Truth, 단일 진실 공급원)로 두는 이유다.

### `ai/AGENTS.md` 구성

- **프로젝트 개요** — 주력 스택, Spring Boot 버전, 팀 규모, 아키텍처 방향.
- **핵심 금지 사항** — 지나친 추상화 금지, 이벤트 기반 개발 금지 등.
- **문서 맵** — 아래 스킬들로 향하는 링크 표.

### 스킬 — `ai/skills/`

컨벤션 지식은 `ai/skills/`에 스킬 3종으로 **한 벌만** 둔다.

| 스킬 | 설명 |
|---|---|
| `coding-convention` | 백엔드 코딩 컨벤션 — 클래스/DTO 네이밍, 레이어 아키텍처, 복잡도·분리·Javadoc 등 코드 품질 |
| `writing-test-code` | 테스트 코드 작성 컨벤션 — JUnit 5, 상태 기반(classical) 스타일, `@Nested` 구조, CUD 테스트 |
| `preventing-duplicate-requests` | 동시 중복 요청("따닥") 방지 — 인메모리 키 락 + 트랜잭션 + 멱등 제약 처리 |

각 스킬은 `SKILL.md`(요약 + 트리거)와 `reference/`(상세 내용)로 구성된다.

### 도구별 로딩 방식 차이

- **Claude Code**는 `~/.claude/skills`를 자동으로 로드한다. `SKILL.md`의 frontmatter `description`을 보고 필요할 때 해당 스킬을 자동 호출한다.
- **그 외 도구**(Codex 등)는 자동 스킬 로더가 없다. 이들은 `AGENTS.md` 하나만 읽고, 그 안의 문서 맵에 있는 `skills/*/SKILL.md` 링크를 명시적으로 참조한다.
- 문서 맵의 상대 경로가 풀리도록, `install.sh`는 지침 파일 옆에 `skills/`도 함께 링크한다.

### install.sh의 링크 함수

`install.sh`의 `link_ai_config <디렉토리> <지침파일명>` 함수가 `AGENTS.md`를 해당 파일명으로, 그리고 `skills/`를 각 도구 위치로 링크한다.

```bash
# link_ai_config <대상디렉토리> <지침파일명>
link_ai_config ~/.claude CLAUDE.md   # → ~/.claude/CLAUDE.md, ~/.claude/skills
link_ai_config ~/.codex AGENTS.md    # → ~/.codex/AGENTS.md,  ~/.codex/skills
```

도구를 추가하려면 이 함수 호출을 한 줄 더하면 된다. 결과적으로 다음 심볼릭 링크가 생성된다.

| 원본 | 링크 위치 |
|---|---|
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md` |
| `ai/skills` | `~/.claude/skills` |
| `ai/AGENTS.md` | `~/.codex/AGENTS.md` |
| `ai/skills` | `~/.codex/skills` |

---

## 커스터마이징 팁

### AI 도구 추가하기

새 AI 코딩 도구를 추가하려면, 그 도구가 지침을 읽는 경로와 파일명을 확인한 뒤 `install.sh`에 `link_ai_config` 호출을 한 줄 추가한다.

```bash
# 예시
link_ai_config ~/.config/<경로> AGENTS.md
link_ai_config ~/.<경로> GEMINI.md
```

지침 원본(`ai/AGENTS.md`)과 스킬(`ai/skills/`)은 그대로 두고, 링크 대상만 늘리면 된다.

### Tmux 프리픽스 변경하기

다른 프리픽스(예: `Ctrl-Space`)를 선호한다면 두 파일을 모두 수정한다.

**`tmux/.tmux.conf`:**
```
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix
```

**`ghostty/config`** — 새 프리픽스에 맞춰 hex 코드를 변경한다. `Ctrl-Space`는 `\x00`이다.
```
keybind = super+digit_1=text:\x00\x31
keybind = super+digit_2=text:\x00\x32
keybind = super+digit_3=text:\x00\x33
```
