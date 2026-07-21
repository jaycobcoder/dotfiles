# 프로젝트 개요

## 이 저장소는 무엇인가

이 저장소는 macOS 개발 환경 설정을 **코드로 관리하는 개인 dotfiles**다. 모든 설정을 하나의 Git 저장소에 담고 심볼릭 링크로 배포하여, 여러 대의 머신(예: 회사용과 개인용)에서 동일한 환경을 그대로 재현한다.

핵심 정체성은 두 가지다.

1. **환경을 코드로** — 셸, 터미널 에뮬레이터, 멀티플렉서 등 개발 환경을 코드로 관리한다.
2. **AI 지침 SSOT** — 여러 AI 코딩 도구의 지침을 **단일 원본(Single Source of Truth)**으로 관리한다.

**Repository**: [github.com/jaycobcoder/dotfiles](https://github.com/jaycobcoder/dotfiles)

## 설계 철학

### 환경을 코드로 (Environment as Code)

셸, 터미널 에뮬레이터, 멀티플렉서 등 모든 설정 파일이 이 저장소 안에 있다. `install.sh` 스크립트 하나가 저장소의 파일을 각자의 기대 위치(`~/.zshrc`, `~/.tmux.conf`, `~/.config/ghostty/config` 등)로 심볼릭 링크한다. 이렇게 하면 다음 이점을 얻는다.

- **버전 관리** — 모든 변경이 git 히스토리에 기록된다.
- **재현 가능** — 어떤 Mac에서든 clone 후 `install.sh`만 실행하면 동일한 환경이 만들어진다.
- **공유 가능** — 전체 설정을 그대로 리뷰하거나 fork하거나 응용할 수 있다.

### AI 지침 SSOT (단일 원본 지침)

Claude Code, Codex 등 여러 AI 코딩 도구를 함께 사용하는데, 도구마다 읽는 지침 파일명이 다르다(Claude는 `CLAUDE.md`, Codex는 `AGENTS.md`, Gemini는 `GEMINI.md`). 도구마다 지침을 따로 관리하면 내용이 어긋나기 쉽다.

그래서 지침 원본을 `ai/AGENTS.md` **한 곳에만 두고**, 각 도구가 읽는 위치·파일명으로 심볼릭 링크한다. 내용은 한 곳만 고치면 모든 도구에 반영된다.

컨벤션 지식은 `ai/skills/`에 스킬 형태로 **한 벌만** 둔다. Claude는 skills를 자동으로 로드하고, 그 외 도구는 `AGENTS.md` 문서 맵의 `skills/*/SKILL.md` 링크로 참조한다.

### 공유 설정과 로컬 설정의 분리

`.zshrc`는 다음 줄로 끝난다.

```bash
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

이 패턴은 **공유 설정**(git에 커밋됨)과 **머신별 설정**(커밋하지 않음)을 분리한다. 회사 내부 환경변수, API 키, 머신 고유 경로 등은 git으로 추적하지 않는 `~/.zshrc.local`에 넣는다.

## 디렉토리 구조

```
dotfiles/
├── .gitignore
├── README.md               # 한글 빠른 시작 문서
├── install.sh              # 진입점: 전체 설치 스크립트
├── zsh/.zshrc              # Zsh 설정
├── tmux/.tmux.conf         # tmux 설정
├── ghostty/config          # Ghostty 터미널 설정
├── ai/                     # AI 코딩 도구 공통 지침 (SSOT)
│   ├── AGENTS.md           # 지침 원본 (프로젝트 개요 + 핵심 금지사항 + 문서맵)
│   └── skills/             # 지식 원본 (스킬 3종, 한글)
└── docs/                   # 이 저장소 사용 설명서 (한글)
```

## 관리 대상

| 도구 | 설정 위치 | 설명 |
|------|----------|------|
| **Zsh** (oh-my-zsh) | `zsh/.zshrc` | agnoster 테마, git 플러그인, 구문 강조, 자동완성 |
| **Tmux** | `tmux/.tmux.conf` | `Ctrl-A` 프리픽스, 1-기반 윈도우 인덱싱 |
| **Ghostty** | `ghostty/config` | Catppuccin Mocha 테마, Cmd+숫자 tmux 연동 |
| **AI 지침 (SSOT)** | `ai/AGENTS.md`, `ai/skills/` | 여러 AI 코딩 도구가 공유하는 단일 원본 지침·컨벤션 |
| **Homebrew** | `install.sh` | CLI 도구 패키지 관리 |
| **Claude Code** | `install.sh` | npm으로 설치/업그레이드 |

## 심볼릭 링크 맵

`install.sh`가 아래 링크를 모두 생성한다.

| 원본 | 링크 위치 |
|------|-----------|
| `zsh/.zshrc` | `~/.zshrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md` |
| `ai/skills` | `~/.claude/skills` |
| `ai/AGENTS.md` | `~/.codex/AGENTS.md` |
| `ai/skills` | `~/.codex/skills` |

AI 지침 원본(`ai/AGENTS.md`)과 지식 원본(`ai/skills`)은 이렇게 여러 도구의 경로로 링크되지만 실제 파일은 한 벌뿐이다. 도구가 늘어나도 `install.sh`의 `link_ai_config` 한 줄만 추가하면 된다.

## Quick Links

- [설치 가이드 (installation.md)](installation.md)
- [설정 레퍼런스 (configuration.md)](configuration.md)
- [아키텍처 & 설계 (architecture.md)](architecture.md)
