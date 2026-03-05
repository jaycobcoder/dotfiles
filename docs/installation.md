# Installation Guide

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| **macOS** | Tested on Apple Silicon (M-series). Intel Macs should work but are untested. |
| **Git** | Pre-installed on macOS via Xcode Command Line Tools. Run `xcode-select --install` if missing. |
| **Internet connection** | Required for Homebrew and oh-my-zsh installation. |

## Quick Start

```bash
git clone https://github.com/jaycobcoder/dotfiles.git ~/company/dotfiles
cd ~/company/dotfiles
bash install.sh
```

That's it. One script handles everything.

## What `install.sh` Does

The install script performs the following steps in order:

### Step 1: Homebrew

Checks if `brew` is available. If not, installs [Homebrew](https://brew.sh/) automatically.

```bash
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
```

### Step 2: Dependency Packages

Installs the following packages via Homebrew:

| Package | Purpose |
|---------|---------|
| `zsh-syntax-highlighting` | Real-time syntax coloring in the shell |
| `zsh-autosuggestions` | Fish-like command autocompletion |
| `neofetch` | System info display on shell startup |
| `tmux` | Terminal multiplexer for session management |
| `lazygit` | Terminal UI for git operations |

### Step 3: Symlinks

Creates symbolic links from the repository to their expected system locations:

| Source (in repo) | Target (on system) |
|------------------|--------------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` |
| `opencode/tui.json` | `~/.config/opencode/tui.json` |

All symlinks use `ln -sf` (force mode), so existing files are overwritten. Back up any existing configs before running if needed.

### Step 4: Custom Commands (`dev` & `devc`)

Delegates to sub-installers:

**`bin/dev/install.sh`:**
1. Verifies Homebrew is available
2. Runs `brew bundle` with `bin/dev/Brewfile` (installs tmux, lazygit, fzf, git-delta, ripgrep)
3. Symlinks `bin/dev/dev.sh` to `~/.local/bin/dev`
4. Makes it executable

**`bin/devc/install.sh`:**
1. Symlinks `bin/devc/devc.sh` to `~/.local/bin/devc`
2. Makes it executable

### Step 5: oh-my-zsh

If `~/.oh-my-zsh` does not exist, installs [oh-my-zsh](https://ohmyz.sh/) in unattended mode.

## Post-Installation

### Verify the Installation

```bash
# Check symlinks
ls -la ~/.zshrc ~/.tmux.conf ~/.config/ghostty/config

# Check custom commands
which dev    # Should output: ~/.local/bin/dev
which devc   # Should output: ~/.local/bin/devc

# Check installed packages
brew list | grep -E "tmux|lazygit|neofetch|zsh-syntax|zsh-auto"
```

### Set Up Local Configuration

Create `~/.zshrc.local` for machine-specific settings that should NOT be committed to git:

```bash
# Example: ~/.zshrc.local

# Company-specific environment variables
export COMPANY_API_KEY="your-api-key-here"

# Machine-specific paths
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Override default settings
export DEFAULT_USER="kiwooso"
```

This file is automatically sourced by `.zshrc` if it exists.

### Install a Ghostty-Compatible Terminal

The Ghostty keybindings in this dotfiles only work if you use [Ghostty](https://ghostty.org/) as your terminal emulator. If you use a different terminal, the `Cmd+1/2/3` window switching will not work (but everything else will).

## Troubleshooting

### `brew: command not found`

Homebrew may not be in your PATH yet. Run:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then re-run `bash install.sh`.

### `dev: command not found`

Ensure `~/.local/bin` is in your PATH. This should already be set by `.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

If you're in a new shell session, restart your terminal or run `source ~/.zshrc`.

### Symlink conflicts

If you have existing config files (not symlinks), `ln -sf` will overwrite them. To preserve your existing configs:

```bash
# Back up before installing
cp ~/.zshrc ~/.zshrc.backup
cp ~/.tmux.conf ~/.tmux.conf.backup
```

### oh-my-zsh already installed

If oh-my-zsh is already present at `~/.oh-my-zsh`, the installer skips this step. No action needed.

### Ghostty terminfo issues

If you see rendering glitches in Ghostty, the `.zshrc` already handles this:

```bash
if [[ "$TERM" == "xterm-ghostty" ]]; then
  export TERM=xterm-256color
fi
```

This forces `xterm-256color` as the TERM value when running inside Ghostty, avoiding compatibility issues with tools that don't recognize the `xterm-ghostty` terminfo entry.

## Reinstallation / Updating

The install script is **idempotent** — running it again will:
- Skip Homebrew installation if already present
- Reinstall/upgrade brew packages
- Overwrite symlinks (pointing to the same repo files)
- Skip oh-my-zsh if already installed

To update after pulling new changes:

```bash
cd ~/company/dotfiles
git pull
bash install.sh
```
