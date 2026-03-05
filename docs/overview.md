# Project Overview

## What is this?

This is a **personal dotfiles repository** that manages macOS development environment configurations as code. By storing all settings in a single Git repository and deploying them via symlinks, the same environment is reproduced identically across multiple machines (e.g., work and personal).

**Repository**: [github.com/jaycobcoder/dotfiles](https://github.com/jaycobcoder/dotfiles)

## Inspiration

This project is inspired by [Effy's Vibe Coding newsletter](https://maily.so/effy/posts/8mo54q84z9p) — "Parallel Agent Coding: This is How I Set It Up." The core ideas adopted from the article:

- **Session isolation** — Each task runs in its own tmux session with a dedicated git worktree, so parallel work never conflicts.
- **Minimal switching cost** — `Cmd+1/2/3` switches between windows instantly (like browser tabs), thanks to Ghostty keybindings forwarding to tmux.
- **One-command automation** — `dev` creates the entire workspace; `devc` tears it down. No manual setup.

## Design Philosophy

### Environment as Code

Every configuration file — shell, terminal emulator, multiplexer — lives in this repository. A single `install.sh` script creates symlinks from the repo to their expected locations (`~/.zshrc`, `~/.tmux.conf`, `~/.config/ghostty/config`). This means:

- **Version-controlled** — All changes are tracked in git history.
- **Reproducible** — Clone + run `install.sh` on any Mac, and the environment is identical.
- **Shareable** — The full setup can be reviewed, forked, or adapted by others.

### Separation of Shared and Local Config

The `.zshrc` ends with:

```bash
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

This pattern separates **shared configuration** (committed to git) from **machine-specific settings** (never committed). Things like company-internal environment variables, API keys, or machine-specific paths go into `~/.zshrc.local`, which is not tracked by git.

### Three-Window Workflow

Every development session consists of exactly three tmux windows:

| Window | Tool | Purpose |
|--------|------|---------|
| `code` (1) | [OpenCode](https://github.com/opencode-ai/opencode) | AI agent that writes code |
| `git` (2) | [lazygit](https://github.com/jesseduffield/lazygit) | Review changes, stage, commit |
| `term` (3) | Plain terminal | Build, test, debug, run commands |

This reflects a shift in the developer's role: the AI agent handles code generation, while the developer focuses on **planning, directing, and verifying**. The three windows map directly to this workflow.

### Git Worktree-Based Parallel Development

The `dev` command integrates git worktrees with tmux sessions. Running `dev feature-auth` will:

1. Create a git worktree at `../.worktrees/<repo>/feature-auth`
2. Create a tmux session named `<repo>_feature-auth`
3. Launch OpenCode, lazygit, and a terminal — all pointing at the worktree directory

Multiple `dev` sessions can run simultaneously, each on a different branch, fully isolated from one another. This enables true parallel agent coding — multiple AI agents working on different features at the same time.

## What's Managed

| Tool | Config Location | Description |
|------|----------------|-------------|
| **Zsh** (oh-my-zsh) | `zsh/.zshrc` | Shell with agnoster theme, git plugin, syntax highlighting, autosuggestions |
| **Tmux** | `tmux/.tmux.conf` | Terminal multiplexer with `Ctrl-A` prefix, 1-based window indexing |
| **Ghostty** | `ghostty/config` | Terminal emulator with Catppuccin Mocha theme, Cmd+number tmux integration |
| **Homebrew** | `install.sh`, `bin/dev/Brewfile` | Package manager for CLI tools |
| **dev** | `bin/dev/dev.sh` | Tmux session + worktree creation command |
| **devc** | `bin/devc/devc.sh` | Tmux session + worktree cleanup command |

## Quick Links

- [Installation Guide](installation.md)
- [Configuration Reference](configuration.md)
- [Command Reference (`dev` & `devc`)](commands.md)
- [Architecture & Design](architecture.md)
