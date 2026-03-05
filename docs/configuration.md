# Configuration Reference

This document explains every configuration file in the repository, what each setting does, and how to customize it.

---

## Zsh — `zsh/.zshrc`

**Symlinked to**: `~/.zshrc`

The shell configuration file, sourced every time a new Zsh session starts.

### Ghostty Terminfo Compatibility

```bash
if [[ "$TERM" == "xterm-ghostty" ]]; then
  export TERM=xterm-256color
fi
```

Ghostty sets `TERM=xterm-ghostty`, but many CLI tools (e.g., older versions of ncurses-based programs) don't recognize this terminfo entry. This override forces `xterm-256color`, which is universally supported, preventing rendering issues.

### oh-my-zsh Setup

```bash
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git)
source $ZSH/oh-my-zsh.sh
```

| Setting | Value | Description |
|---------|-------|-------------|
| `ZSH_THEME` | `agnoster` | Powerline-style prompt theme. Requires a [Nerd Font](https://www.nerdfonts.com/) or Powerline-patched font to render correctly. |
| `plugins` | `(git)` | Enables git aliases and prompt integration (e.g., branch name display, dirty state indicators). |

### Custom Prompt Context

```bash
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}
```

Overrides the agnoster theme's default prompt context behavior:
- **Hides** the `user@hostname` segment when you're the default user on a local machine (reduces prompt clutter).
- **Shows** the username when logged in as a different user or via SSH.
- To activate this, set `DEFAULT_USER` in `~/.zshrc.local`:
  ```bash
  export DEFAULT_USER="kiwooso"
  ```

### Shell Plugins

```bash
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

| Plugin | Effect |
|--------|--------|
| **zsh-syntax-highlighting** | Colors commands as you type — valid commands turn green, invalid turn red. Helps catch typos before hitting Enter. |
| **zsh-autosuggestions** | Suggests commands from your history as faded gray text. Press `→` (right arrow) to accept. |

Both are installed via Homebrew (not as oh-my-zsh plugins) and sourced from `/opt/homebrew/share/`.

### Neofetch on Startup

```bash
/opt/homebrew/bin/neofetch
```

Displays system information (OS, kernel, shell, CPU, memory, etc.) every time a new terminal session starts. This is purely cosmetic. Remove this line if you want faster shell startup.

### Environment Variables

```bash
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export PATH=/opt/homebrew/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
```

| Variable | Value | Purpose |
|----------|-------|---------|
| `JAVA_HOME` | Zulu JDK 17 path | Sets the default Java runtime. Used by Java/Kotlin/Android build tools. |
| `PATH` additions | `/opt/homebrew/bin`, `~/.local/bin` | Ensures Homebrew binaries and custom commands (`dev`, `devc`) are found. |

### Local Configuration Hook

```bash
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

**This is the last line in `.zshrc` by design.** It sources `~/.zshrc.local` if the file exists. Because it runs last, local settings can override anything defined above.

Use cases for `~/.zshrc.local`:
- Company-specific environment variables or API keys
- Machine-specific `JAVA_HOME` or SDK paths
- `DEFAULT_USER` for prompt customization
- Any setting you don't want committed to git

---

## Tmux — `tmux/.tmux.conf`

**Symlinked to**: `~/.tmux.conf`

A minimal tmux configuration focused on ergonomics.

### 1-Based Window Indexing

```
set -g base-index 1
```

By default, tmux numbers windows starting from 0. This changes it to start from 1, so window numbering matches keyboard layout: `Cmd+1` goes to window 1, `Cmd+2` to window 2, etc. This aligns with the Ghostty keybindings below.

### Prefix Key Remap

```
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

| Default | Custom | Reason |
|---------|--------|--------|
| `Ctrl-B` | `Ctrl-A` | `Ctrl-A` is easier to reach — the `A` key is on the home row. Since tmux prefix is used hundreds of times a day, the ergonomic benefit is significant. |

`bind C-a send-prefix` allows sending a literal `Ctrl-A` to programs inside tmux by pressing `Ctrl-A` twice (e.g., for GNU screen or readline beginning-of-line).

---

## Ghostty — `ghostty/config`

**Symlinked to**: `~/.config/ghostty/config`

Configuration for the [Ghostty](https://ghostty.org/) terminal emulator.

### Keybindings — Cmd+Number to Switch Tmux Windows

```
keybind = super+digit_1=text:\x01\x31
keybind = super+digit_2=text:\x01\x32
keybind = super+digit_3=text:\x01\x33
```

This is the most important configuration in the entire dotfiles. Here's how it works:

| Keypress | Ghostty sends | Decoded as | Tmux interprets as |
|----------|---------------|------------|---------------------|
| `Cmd+1` | `\x01\x31` | `Ctrl-A` + `1` | Switch to window 1 (`code`) |
| `Cmd+2` | `\x01\x32` | `Ctrl-A` + `2` | Switch to window 2 (`git`) |
| `Cmd+3` | `\x01\x33` | `Ctrl-A` + `3` | Switch to window 3 (`term`) |

- `\x01` = ASCII code for `Ctrl-A` (the tmux prefix)
- `\x31` = ASCII code for `1`, `\x32` = `2`, `\x33` = `3`

This makes tmux window switching feel like browser tab switching — a single `Cmd+number` keystroke instead of the two-step `Ctrl-A` then `number`.

**Prerequisite**: The tmux prefix must be set to `Ctrl-A` (see tmux config above). If you use the default `Ctrl-B` prefix, change `\x01` to `\x02`.

### Theme

```
theme=catppuccin mocha
```

Uses the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) color scheme — a warm dark theme with pastel accents. Ghostty ships with Catppuccin themes built-in.

### Font

```
font-family = IBM Plex Mono
font-size = 13
font-thicken=true
font-feature=-liga
```

| Setting | Value | Description |
|---------|-------|-------------|
| `font-family` | `IBM Plex Mono` | Monospace font by IBM. Clean, readable, and good Unicode coverage. Must be [installed separately](https://github.com/IBM/plex). |
| `font-size` | `13` | Font size in points. |
| `font-thicken` | `true` | Makes glyphs slightly bolder for better readability on high-DPI screens. |
| `font-feature` | `-liga` | Disables ligatures. Keeps `!=`, `=>`, `->` as separate characters instead of merging them into single glyphs. |

### Window Padding

```
window-padding-x = 10
window-padding-y = 10
```

Adds 10 pixels of padding on all sides between the terminal content and the window edge. Prevents text from touching the window border, improving readability.

---

## OpenCode — `opencode/opencode.json` & `opencode/tui.json`

**Symlinked to**: `~/.config/opencode/opencode.json` and `~/.config/opencode/tui.json`

Configuration for [OpenCode](https://opencode.ai/) — the AI coding agent launched in the `code` window of `dev` sessions.

### Runtime Configuration — `opencode.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": true
}
```

This is a minimal runtime configuration. OpenCode supports a [rich configuration schema](https://opencode.ai/docs/config/) including:
- `model` — Default LLM model (e.g., `"anthropic/claude-sonnet-4-5"`)
- `provider` — Provider-specific options (timeout, API keys, etc.)
- `tools` — Enable/disable specific tools (write, bash, etc.)
- `permission` — Control whether tools require user approval
- `agent` — Define specialized agents for specific tasks
- `mcp` — Configure Model Context Protocol servers
- `formatter` — Code formatting tools (prettier, etc.)

The config file is merged across multiple locations with this priority (later overrides earlier):
1. Remote config (`.well-known/opencode`) — organization defaults
2. **Global config** (`~/.config/opencode/opencode.json`) — this dotfiles config
3. Project config (`<project-root>/opencode.json`) — per-project overrides
4. `.opencode/` directories — agents, commands, themes, plugins

This means the global config in the dotfiles provides user-wide defaults, while individual projects can override settings by adding their own `opencode.json`.

### TUI Configuration — `tui.json`

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "system"
}
```

The `system` theme is a special adaptive theme that:
- **Generates a custom grayscale** based on your terminal's background color, ensuring optimal contrast
- **Uses standard ANSI colors** (0-15) for syntax highlighting and UI elements, respecting your terminal's color palette
- **Preserves terminal defaults** by using `"none"` for text and background colors, maintaining your terminal's appearance

This is ideal when you want OpenCode to match your terminal's look. Since this dotfiles uses Ghostty with the Catppuccin Mocha theme, the `system` theme automatically adapts to those colors without any additional configuration.

Other available themes include `tokyonight`, `catppuccin`, `gruvbox`, `nord`, and more. See the [full theme list](https://opencode.ai/docs/themes/).

The `tui.json` also supports:
- `keybinds` — Custom keyboard shortcuts
- `scroll_speed` — Scrolling behavior
- `diff_style` — How diffs are displayed (`"auto"`, `"side-by-side"`, `"unified"`)

**Note**: The older `theme` and `keybinds` keys in `opencode.json` are deprecated. Use `tui.json` instead.

---

## Customization Tips

### Changing the AI Agent

If you use a different AI coding agent (e.g., Claude Code, Cursor), edit `bin/dev/dev.sh` line 39:

```bash
# Change this:
tmux send-keys -t "$SESSION_NAME:code" "opencode" Enter

# To your preferred agent:
tmux send-keys -t "$SESSION_NAME:code" "claude" Enter
```

### Adding More Tmux Windows

To add a 4th window (e.g., for running a dev server), edit `bin/dev/dev.sh` before the `select-window` line:

```bash
tmux new-window -t "$SESSION_NAME" -n "server" -c "$TARGET_PATH"
tmux send-keys -t "$SESSION_NAME:server" "npm run dev" Enter
```

Then add a corresponding Ghostty keybinding in `ghostty/config`:

```
keybind = super+digit_4=text:\x01\x34
```

### Changing the Tmux Prefix

If you prefer a different prefix (e.g., `Ctrl-Space`), update both files:

**`tmux/.tmux.conf`:**
```
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix
```

**`ghostty/config`** — Update the hex codes to match the new prefix. `Ctrl-Space` is `\x00`:
```
keybind = super+digit_1=text:\x00\x31
keybind = super+digit_2=text:\x00\x32
keybind = super+digit_3=text:\x00\x33
```
