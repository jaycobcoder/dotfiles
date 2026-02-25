# dotfiles

개인 개발 환경 설정 및 유틸리티 스크립트 모음입니다.

## 설치

```bash
git clone <repo-url> ~/company/dotfiles
cd ~/company/dotfiles
bash install.sh
```

`install.sh` 한 번 실행하면 아래 모든 설정이 자동으로 적용됩니다.

### 설치 항목

- Homebrew 및 의존성 패키지 (`tmux`, `lazygit`, `zsh-syntax-highlighting`, `zsh-autosuggestions`, `neofetch`)
- oh-my-zsh
- 심볼릭 링크: `.zshrc`, `.tmux.conf`, ghostty config
- `dev`, `devc` 명령어 → `~/.local/bin`

> `.zshrc`에 아래 줄이 있어야 명령어가 인식됩니다.
> ```bash
> export PATH="$HOME/.local/bin:$PATH"
> ```

---

## 명령어

### `dev [브랜치명]`

tmux 세션을 생성하고 개발 환경을 세팅합니다.

**브랜치명 없이 실행** — 현재 디렉토리 기준으로 세션 생성

```bash
dev
```

**브랜치명과 함께 실행** — git worktree + 브랜치 생성 후 세션 시작

```bash
dev feature/login
```

워크트리는 `../.worktrees/<repo명>/<브랜치명>`에 생성됩니다.

세션 구성:
- `code` 창 — `opencode` (AI 에이전트) 실행
- `git` 창 — `lazygit` 실행
- `term` 창 — 일반 터미널

이미 세션이 존재하면 새로 만들지 않고 attach합니다.

---

### `devc [-f] [브랜치명]`

`dev`로 만든 tmux 세션과 git worktree를 제거합니다. (`devclear` / `devclean`의 약자)

**브랜치명 없이 실행** — 현재 디렉토리 기준 tmux 세션만 제거

```bash
devc
```

**브랜치명과 함께 실행** — tmux 세션 + worktree + 브랜치 제거

```bash
devc feature/login
```

**`-f` 옵션** — 미머지 브랜치도 강제 삭제 (`branch -D`, `worktree remove --force`)

```bash
devc -f feature/login
```

| 옵션 | worktree remove | branch 삭제 |
|------|----------------|-------------|
| 기본 | 일반 제거 | `-d` (머지된 것만) |
| `-f` | `--force` | `-D` (강제) |

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
└── bin/
    ├── dev/
    │   └── dev.sh
    └── devc/
        └── devc.sh
```
