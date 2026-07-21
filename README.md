# dotfiles

개인 개발 환경 설정 모음입니다. macOS 개발 환경을 코드로 관리하고, 여러 AI 코딩 도구의 지침을 **단일 원본(SSOT)** 으로 관리합니다.

## 설치

```bash
git clone <repo-url> ~/company/dotfiles
cd ~/company/dotfiles
bash install.sh
```

`install.sh` 한 번 실행하면 아래 모든 설정이 자동으로 적용됩니다.

### 설치 항목

- Homebrew 및 의존성 패키지 (`zsh-syntax-highlighting`, `zsh-autosuggestions`, `neofetch`, `tmux`, `lazygit`, `node`)
- Claude Code (npm으로 설치/업그레이드)
- oh-my-zsh
- 심볼릭 링크: `.zshrc`, `.tmux.conf`, ghostty config
- AI 지침(SSOT): `ai/AGENTS.md`·`ai/skills`를 각 AI 도구가 읽는 위치로 링크
  - Claude Code → `~/.claude/CLAUDE.md`, `~/.claude/skills`
  - Codex CLI → `~/.codex/AGENTS.md`, `~/.codex/skills`
  - Antigravity (agy) → `~/.gemini/GEMINI.md`, `~/.gemini/skills`

---

## AI 지침 단일 원본(SSOT)

여러 AI 코딩 도구(Claude Code, Codex 등)를 함께 쓰는데, 도구마다 읽는 지침 파일명이 다릅니다(Claude는 `CLAUDE.md`, Codex는 `AGENTS.md`, Gemini는 `GEMINI.md`). 도구마다 지침을 따로 관리하면 내용이 어긋나기 쉽습니다.

그래서 지침 원본을 `ai/` 한 곳에만 두고, 각 도구가 읽는 위치·파일명으로 심볼릭 링크합니다. **내용은 `ai/` 한 곳만 고치면 모든 도구에 반영됩니다.**

- `ai/AGENTS.md` — 지침 원본 (프로젝트 개요 + 핵심 금지사항 + 문서 맵)
- `ai/skills/` — 컨벤션 지식 (스킬 3종). Claude Code는 자동 로드하고, 그 외 도구는 `AGENTS.md` 문서 맵의 `skills/*/SKILL.md` 링크로 참조합니다.

도구를 추가하려면 `install.sh`의 `link_ai_config <디렉토리> <지침파일명>` 호출 한 줄만 더하면 됩니다.

---

## 디렉토리 구조

```
dotfiles/
├── install.sh
├── zsh/
│   └── .zshrc
├── tmux/
│   └── .tmux.conf
├── ghostty/
│   └── config
├── ai/                     # AI 코딩 도구 공통 지침 (SSOT)
│   ├── AGENTS.md
│   └── skills/
│       ├── coding-convention/
│       ├── writing-test-code/
│       └── preventing-duplicate-requests/
└── docs/
    ├── overview.md
    ├── installation.md
    ├── configuration.md
    └── architecture.md
```

---

## Documentation

자세한 문서는 `docs/` 디렉토리를 참고하세요.

- [프로젝트 개요](docs/overview.md) — 프로젝트 목적, 설계 철학, 핵심 구성 요소
- [설치 가이드](docs/installation.md) — 상세 설치 가이드, 트러블슈팅
- [설정 레퍼런스](docs/configuration.md) — 각 설정 파일(zsh, tmux, ghostty)과 AI 지침(SSOT) 상세 명세
- [아키텍처 및 설계](docs/architecture.md) — 심볼릭 링크 전략, 의존성 관리, AI 지침 SSOT 설계
