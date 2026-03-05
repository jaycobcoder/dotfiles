# Command Reference

## `dev` — Create Development Session

**Location**: `bin/dev/dev.sh` (symlinked to `~/.local/bin/dev`)

Creates a tmux session with three windows (code, git, term) for a project. Optionally creates a git worktree for branch-based parallel development.

### Synopsis

```
dev [branch-name]
```

### Usage

#### Basic — Current Directory Session

```bash
cd ~/workspaces/my-project
dev
```

Creates a tmux session named `my-project` (derived from the current directory name) with three windows, all rooted in the current directory.

#### With Branch — Worktree + Session

```bash
cd ~/workspaces/my-project
dev feature/auth
```

Creates a git worktree at `../.worktrees/my-project/feature/auth`, then creates a tmux session named `my-project_feature/auth` with three windows rooted in the worktree directory.

### Session Layout

| Window | Name | Command | Description |
|--------|------|---------|-------------|
| 1 | `code` | `opencode` | AI coding agent (auto-launched) |
| 2 | `git` | `lazygit` | Git TUI for reviewing changes (auto-launched) |
| 3 | `term` | — | Empty terminal for builds, tests, debugging |

The first window (`code`) is automatically focused after session creation.

### Behavior Details

#### Session Naming

| Invocation | Session Name |
|------------|-------------|
| `dev` (no args) | Current directory name with ` ./` replaced by `_` |
| `dev feature/auth` | `<repo-name>_feature/auth` |

#### Worktree Creation Logic

When a branch name is provided, the following logic applies:

```
Is the branch name the same as the current branch?
├── YES → Use current directory (no worktree created)
└── NO
    └── Does the worktree directory already exist?
        ├── YES → Reuse existing worktree
        └── NO
            └── Does a local branch with this name exist?
                ├── YES → git worktree add <path> <branch>
                └── NO  → git worktree add -b <branch> <path>
```

- **Worktree path**: `../.worktrees/<repo-name>/<branch-name>`
  - Example: If you're in `~/workspaces/my-project` and run `dev feature/auth`, the worktree is created at `~/workspaces/.worktrees/my-project/feature/auth`
- The `.worktrees/` directory is listed in `.gitignore` so it's never committed.

#### Existing Session Handling

If a tmux session with the same name already exists, `dev` simply attaches to it instead of creating a new one. This is safe to run repeatedly.

### Examples

```bash
# Start a session for the current project
dev

# Start a session with a new feature branch (branch + worktree auto-created)
dev feature/login

# Start a session for an existing branch (worktree created, branch checked out)
dev bugfix/header-crash

# Re-attach to an existing session
dev feature/login    # If session exists, just attaches

# Run multiple sessions in parallel
dev feature/auth     # In one terminal
dev feature/payments # In another terminal
dev bugfix/ui-glitch # In yet another terminal
```

---

## `devc` — Clean Up Development Session

**Location**: `bin/devc/devc.sh` (symlinked to `~/.local/bin/devc`)

Removes tmux sessions and optionally git worktrees/branches created by `dev`. The name stands for "dev clear" or "dev clean."

### Synopsis

```
devc [-f] [branch-name]
```

### Usage

#### Basic — Kill Current Directory Session

```bash
cd ~/workspaces/my-project
devc
```

Kills only the tmux session associated with the current directory. Does not touch any worktrees or branches.

#### With Branch — Full Cleanup

```bash
cd ~/workspaces/my-project
devc feature/auth
```

Performs a three-step cleanup:
1. Kills the tmux session `my-project_feature/auth`
2. Removes the git worktree at `../.worktrees/my-project/feature/auth`
3. Deletes the local branch `feature/auth` (safe delete — only if merged)

#### Force Mode

```bash
devc -f feature/auth
```

Same as above, but uses force operations:
- `git worktree remove --force` (removes even with uncommitted changes)
- `git branch -D` (deletes even if not merged)

### Options

| Option | Effect on worktree | Effect on branch |
|--------|-------------------|-----------------|
| (none) | `git worktree remove` | `git branch -d` (safe — refuses if unmerged) |
| `-f` | `git worktree remove --force` | `git branch -D` (force — deletes regardless) |

The `-f` flag can appear anywhere in the arguments:

```bash
devc -f feature/auth   # OK
devc feature/auth -f   # Also OK
```

### Behavior Details

#### Without Branch Name

Only the tmux session is affected. The session name is derived from the current directory name (same logic as `dev`). No worktrees or branches are touched.

#### With Branch Name

All three resources are cleaned up:

```
1. tmux session  →  tmux kill-session -t "<repo>_<branch>"
2. git worktree  →  git worktree remove <path>
3. git branch    →  git branch -d <branch>  (or -D with -f)
```

If any resource doesn't exist, a warning is printed but execution continues. This makes `devc` safe to run even if some cleanup was already done manually.

### Examples

```bash
# Kill the tmux session for the current project (no worktree cleanup)
devc

# Full cleanup: kill session + remove worktree + delete branch
devc feature/login

# Force cleanup: even if branch has unmerged changes
devc -f experimental/risky-refactor

# Clean up multiple sessions
devc feature/auth
devc feature/payments
devc bugfix/ui-glitch
```

---

## Workflow: Complete Session Lifecycle

Here's the typical workflow for a parallel development task:

```
┌─────────────────────────────────────────────────────────┐
│  1. CREATE                                              │
│                                                         │
│  $ cd ~/workspaces/my-project                           │
│  $ dev feature/auth                                     │
│                                                         │
│  → Worktree created at ../.worktrees/my-project/feature/auth  │
│  → Tmux session "my-project_feature/auth" started       │
│  → Window 1: OpenCode running                           │
│  → Window 2: lazygit running                            │
│  → Window 3: empty terminal                             │
├─────────────────────────────────────────────────────────┤
│  2. WORK                                                │
│                                                         │
│  Cmd+1 → Give instructions to AI agent (OpenCode)       │
│  Cmd+2 → Review changes in lazygit                      │
│  Cmd+3 → Run tests, builds, or debug commands           │
│                                                         │
│  Meanwhile, in another terminal:                        │
│  $ dev feature/payments  ← another parallel session     │
├─────────────────────────────────────────────────────────┤
│  3. DETACH (optional)                                   │
│                                                         │
│  Ctrl-A, d → Detach from tmux session                   │
│  Session keeps running in the background.               │
│  $ dev feature/auth → Re-attach later                   │
├─────────────────────────────────────────────────────────┤
│  4. CLEANUP                                             │
│                                                         │
│  $ cd ~/workspaces/my-project                           │
│  $ devc feature/auth                                    │
│                                                         │
│  → Tmux session killed                                  │
│  → Worktree removed                                     │
│  → Branch deleted (if merged)                           │
│                                                         │
│  Or force cleanup if branch was experimental:           │
│  $ devc -f feature/auth                                 │
└─────────────────────────────────────────────────────────┘
```

## Dependencies

Both commands require the following tools (installed via `bin/dev/Brewfile`):

| Tool | Required by | Purpose |
|------|------------|---------|
| `tmux` | `dev`, `devc` | Session and window management |
| `lazygit` | `dev` | Auto-launched in the `git` window |
| `git` | `dev`, `devc` | Worktree operations, branch management |
| `opencode` | `dev` | Auto-launched in the `code` window (replaceable) |
