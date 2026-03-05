# Architecture & Design

This document explains the structural decisions behind the dotfiles repository — how files are organized, how they reach their system locations, how dependencies are managed, and why certain patterns were chosen.

---

## Directory Structure

```
dotfiles/
├── .git/                          # Git repository
├── .gitignore                     # Ignores .worktrees/
├── .worktrees/                    # Runtime: git worktrees (gitignored)
├── README.md                      # Quick-start documentation (Korean)
├── install.sh                     # Master install script (entry point)
│
├── zsh/
│   └── .zshrc                     # Zsh shell configuration
│
├── tmux/
│   └── .tmux.conf                 # Tmux multiplexer configuration
│
├── ghostty/
│   └── config                     # Ghostty terminal emulator configuration
│
├── opencode/
│   ├── opencode.json              # OpenCode runtime configuration
│   └── tui.json                   # OpenCode TUI theme/keybind settings
│
├── bin/
│   ├── dev/
│   │   ├── dev.sh                 # Dev session launcher
│   │   ├── install.sh             # Dev command installer
│   │   └── Brewfile               # Homebrew dependencies for dev
│   └── devc/
│       ├── devc.sh                # Dev session cleanup
│       └── install.sh             # Devc command installer
│
└── docs/
    ├── overview.md                # Project overview and philosophy
    ├── installation.md            # Installation guide
    ├── configuration.md           # Configuration file reference
    ├── commands.md                # dev/devc command reference
    └── architecture.md            # This file
```

### Naming Conventions

- **Config directories** are named after their tool: `zsh/`, `tmux/`, `ghostty/`
- **Config files** keep their original names (including leading dots): `.zshrc`, `.tmux.conf`
- **Custom commands** live under `bin/<command-name>/` with the script, its installer, and any dependencies (like Brewfile) co-located

---

## Symlink Strategy

The core mechanism of this dotfiles repo is **symbolic links**. Config files live in the git repository, and symlinks connect them to the locations where tools expect them.

### Symlink Map

| Source (in repository) | Target (on system) | Created by |
|------------------------|-------------------|------------|
| `zsh/.zshrc` | `~/.zshrc` | `install.sh` |
| `tmux/.tmux.conf` | `~/.tmux.conf` | `install.sh` |
| `ghostty/config` | `~/.config/ghostty/config` | `install.sh` |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` | `install.sh` |
| `opencode/tui.json` | `~/.config/opencode/tui.json` | `install.sh` |
| `bin/dev/dev.sh` | `~/.local/bin/dev` | `bin/dev/install.sh` |
| `bin/devc/devc.sh` | `~/.local/bin/devc` | `bin/devc/install.sh` |

### How It Works

```
~/company/dotfiles/zsh/.zshrc    ← Actual file (git-tracked)
         ↑
         │  ln -sf
         │
~/.zshrc                          ← Symlink (what Zsh reads)
```

All symlinks are created with `ln -sf` (symbolic, force):
- **`-s`**: Creates a symbolic link (not a hard link), so it works across filesystems
- **`-f`**: Overwrites any existing file or symlink at the target path

This means:
- Editing `~/.zshrc` directly edits the file in the repo (they're the same file via symlink)
- `git diff` in the repo shows changes made through either path
- Running `install.sh` again safely re-creates all symlinks (idempotent)

### Why Symlinks (Not Copies)

Alternatives considered:
- **Copying files**: Changes in the system location wouldn't be reflected in the repo, requiring manual sync
- **GNU Stow**: A tool that automates symlink management. Adds a dependency for a small number of links. The current approach keeps things simple with explicit `ln -sf` commands.
- **Direct home directory repo**: Using `$HOME` as the git repo. This clutters `git status` with every file in the home directory and requires extensive `.gitignore` rules.

Symlinks provide the best balance: the repo stays clean, edits propagate instantly, and the mechanism is transparent.

---

## Dependency Management

### Homebrew Packages

Dependencies are installed at two levels:

#### Level 1: `install.sh` (Global)

The master install script installs packages needed by the shell environment:

```bash
brew install zsh-syntax-highlighting  # Shell syntax coloring
brew install zsh-autosuggestions       # Command suggestions
brew install neofetch                  # System info display
brew install tmux                      # Terminal multiplexer
brew install lazygit                   # Git TUI
```

#### Level 2: `bin/dev/Brewfile` (Dev Command)

The `dev` command has its own Brewfile for additional tooling:

```ruby
brew "tmux"       # Session and window management
brew "lazygit"    # Git TUI
brew "fzf"        # Fuzzy finder
brew "git-delta"  # Enhanced diff viewer
brew "ripgrep"    # Fast search
```

This is installed via `brew bundle --file=bin/dev/Brewfile` during `bin/dev/install.sh`.

Some packages (tmux, lazygit) appear in both — this is intentional. Each installer is self-contained and can be run independently.

### Why Not a Single Brewfile?

The two-level approach exists because:
1. The global `install.sh` handles the minimal set needed for shell configuration
2. The dev Brewfile adds tools specific to the development workflow
3. Either can be run independently without the other

---

## The `.zshrc.local` Pattern

### Problem

Some settings are machine-specific and should never be committed to git:
- API keys and secrets
- Company-internal environment variables
- Paths that differ between machines (e.g., SDK locations)
- User-specific preferences (like `DEFAULT_USER`)

### Solution

The `.zshrc` ends with:

```bash
# Last line of .zshrc
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

This conditionally sources `~/.zshrc.local` **if it exists**. The file:
- Lives only on the local machine
- Is never created or managed by the dotfiles repo
- Is not listed in `.gitignore` (it doesn't need to be — it's outside the repo directory)
- Runs last, so it can override any setting from `.zshrc`

### Execution Order

```
Shell starts
  └── sources ~/.zshrc (symlink → dotfiles/zsh/.zshrc)
        ├── Ghostty terminfo fix
        ├── oh-my-zsh setup
        ├── prompt_context override
        ├── syntax highlighting & autosuggestions
        ├── neofetch
        ├── JAVA_HOME, PATH
        └── sources ~/.zshrc.local (if exists)
              └── Machine-specific overrides
```

### Example `.zshrc.local`

```bash
# Company machine
export DEFAULT_USER="kiwooso"
export COMPANY_PROXY="http://proxy.internal:8080"
export ARTIFACTORY_TOKEN="eyJ..."

# Personal machine
export DEFAULT_USER="jaycob"
export GOPATH="$HOME/go"
```

---

## Git Worktree Architecture

### What Are Git Worktrees?

A git worktree is an additional working directory attached to the same repository. Unlike `git clone`, worktrees share the same `.git` data — branches, history, and objects are shared. This means:
- No duplicate downloads or disk space for repository data
- Branch operations (create, delete, merge) affect the same repo
- Each worktree has its own working directory and index (staging area)

### Worktree Layout

When `dev feature/auth` is run from `~/workspaces/my-project`:

```
~/workspaces/
├── my-project/                         ← Main working tree (main branch)
│   ├── .git/                           ← Repository data (shared)
│   ├── src/
│   └── ...
│
└── .worktrees/                         ← Worktree root (gitignored)
    └── my-project/
        ├── feature/auth/               ← Worktree (feature/auth branch)
        │   ├── .git                    ← File (pointer to main .git)
        │   ├── src/
        │   └── ...
        └── bugfix/login/              ← Another worktree
            ├── .git
            ├── src/
            └── ...
```

Key points:
- Worktrees are created one level up from the project: `../.worktrees/<repo>/<branch>`
- This keeps worktrees outside the main project directory
- `.worktrees/` is in `.gitignore` so it's never committed
- Each worktree's `.git` is a file (not a directory) that points back to the main `.git` directory

### Why This Location?

The worktree base is `../.worktrees/` (sibling to the project), not inside the project itself. This avoids:
- Cluttering the project directory with worktree folders
- Accidentally including worktree files in searches or builds
- Conflicts with tools that scan the project root

### Session-Worktree Mapping

Each `dev` session maps 1:1 to a worktree:

```
dev feature/auth
  → Worktree: ../.worktrees/my-project/feature/auth
  → Session:  my-project_feature/auth
  → Windows:  code | git | term  (all in worktree directory)

dev bugfix/login
  → Worktree: ../.worktrees/my-project/bugfix/login
  → Session:  my-project_bugfix/login
  → Windows:  code | git | term  (all in worktree directory)
```

This 1:1 mapping means:
- Each AI agent works in a completely isolated directory
- Git operations in one session don't affect another
- `devc` can cleanly remove the session, worktree, and branch together

---

## Install Script Design

### Idempotency

Every operation in `install.sh` is safe to run multiple times:

| Operation | Idempotency mechanism |
|-----------|----------------------|
| Homebrew install | `command -v brew` check — skips if present |
| `brew install` | Homebrew no-ops for already-installed packages |
| `ln -sf` | Force flag overwrites existing symlinks |
| `mkdir -p` | No-op if directory exists |
| oh-my-zsh install | `[ ! -d "$HOME/.oh-my-zsh" ]` check |

### Execution Flow

```
install.sh
├── 1. Check/install Homebrew
├── 2. brew install (5 packages)
├── 3. Symlink .zshrc, .tmux.conf, ghostty/config
├── 4. Run bin/dev/install.sh
│     ├── Check Homebrew
│     ├── brew bundle (Brewfile)
│     └── Symlink dev.sh → ~/.local/bin/dev
├── 5. Run bin/devc/install.sh
│     └── Symlink devc.sh → ~/.local/bin/devc
└── 6. Install oh-my-zsh (if missing)
```

### Sub-Installer Independence

`bin/dev/install.sh` and `bin/devc/install.sh` can be run independently:

```bash
# Only install the dev command
bash bin/dev/install.sh

# Only install the devc command
bash bin/devc/install.sh
```

This modular design means individual components can be updated or reinstalled without running the entire setup.

---

## Design Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Config deployment | Symlinks (`ln -sf`) | Instant propagation, transparent, no sync needed |
| Package manager | Homebrew | De facto standard on macOS, declarative via Brewfile |
| Shell framework | oh-my-zsh | Rich plugin ecosystem, widely supported themes |
| Local overrides | `.zshrc.local` pattern | Clean separation of shared vs machine-specific config |
| Worktree location | `../.worktrees/` | Outside project tree, avoids pollution |
| Custom commands | Symlinks in `~/.local/bin` | Standard Unix convention, no PATH hacks needed |
| Install approach | Single entry point (`install.sh`) | One command to set up everything |
| Idempotency | Check-before-act pattern | Safe to re-run anytime |
| OpenCode theme | `system` (terminal-adaptive) | Auto-adapts to Ghostty's Catppuccin Mocha, no manual color config |
