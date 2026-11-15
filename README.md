# Dotfiles

Personal configuration for my development environment: **NeoVim**, **zsh**, **tmux**, **git**, **ssh**, **opencode**, plus terminal ([alacritty](#terminals)) and [PrusaSlicer](#3d-printing) profiles.

> Root-level dotfiles link straight into `$HOME`; everything under `.config/` links into `~/.config/`.

## Installation

Deployment is handled with [GNU Stow](https://www.gnu.org/software/stow/). Stow symlinks each config into place and **merges** into existing directories, so it safely layers `.config/{nvim,tmux,opencode,alacritty,foot,PrusaSlicer}` into a `~/.config` that already holds other apps. Non-config repo files (`.git`, `README.md`, `.gitignore`), the git-tracked-but-not-deployed `AGENTS.md`, and generated `node_modules/` trees (opencode's plugin deps — they would collide with the copies npm already installed in `~/.config/opencode`) are skipped via the repo-root `.stow-local-ignore`. Stow uses that file *instead of* its built-in defaults, so it re-lists them.

```sh
cd ~/dotfiles   # wherever you cloned the repo
stow .
```

Re-running is safe. To undo, run `stow -D .` (add `-n -v2` for a dry run first). Then install the [tools](#tools-configured) below; NeoVim bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and its plugins automatically on first launch.

## Tools

| Tool                      | Needed for                                                                                                          |
|---------------------------|---------------------------------------------------------------------------------------------------------------------|
| `stow`                    | deploying the dotfiles (see [Installation](#installation))                                                          |
| `zsh`                     | the shell (config is zsh-only)                                                                                      |
| `zsh-autosuggestions`     | history-based suggestions (searched in `/usr/share/...`, `/usr/share/zsh-contrib/...` and `~/.local/share/zsh/...`) |
| `zsh-syntax-highlighting` | command highlighting (searched in `/usr/share/...` and `~/.local/share/zsh/...`)                                    |
| `tmux`                    | terminal multiplexer; `.zshrc` auto-starts it for interactive shells                                                |
| `neovim`                  | editor                                                                                                              |
| `git`                     | version control (see [Personalize](#personalize-before-use))                                                        |
| `ssh`                     | OpenSSH client; host aliases in `.ssh/config` (see [SSH](#ssh))                                                     |
| `ripgrep`                 | Telescope live-grep                                                                                                 |
| `direnv`                  | the prompt reacts to `.envrc`; optional, guarded                                                                    |
| language servers          | see [NeoVim → LSP](#lsp)                                                                                            |
| `node` / `npx`            | opencode plugins and the npx-backed MCP servers                                                                     |

Anything not installed is skipped rather than erroring: optional integrations (`direnv`, `ng`, `wt`, `nvm`, `cargo`, `go`) are behind `command -v` guards in `.zshrc`, so the same file works on a bare machine.

## Personalize before use

**Git identity and credentials**  
The tracked `.gitconfig` holds only `core` + aliases. Your email/name, your credential helper (I use `cache --timeout=86400` on a machine with no keychain; the example ships commented `wincred`/`osxkeychain` variants) and any per-host settings such as an internal CA bundle belong in `~/.gitconfig.local`, which is git-ignored — keep it `chmod 600`. Copy `.gitconfig.local.example` to `~/.gitconfig.local` and edit it, so nobody else inherits your cert store or credential helper.

> `~/.gitconfig` must be stow's **symlink**, not a leftover real file, or `stow .` aborts (stow never overwrites files it doesn't own). Note the CLI only prints included values with `git config --global --list --includes`; ordinary commands like `git commit` pick them up regardless.

**Nothing machine-specific goes in this repo**  
Hosts, IP addresses, tokens and printer/API keys belong in the per-machine `~/.gitconfig.local` / `~/.ssh/config.d/` style overrides, not in tracked files. This repo is public: assume every line is readable.

## SSH

Only `.ssh/config` — host aliases, users, `IdentityFile` paths — is tracked. Private/public keys, `authorized_keys` and `known_hosts` live solely in `~/.ssh` and are never committed (`.gitignore` allows only `config` through). Stow merges `config` into an existing `~/.ssh` without touching the other files.

## Tmux

Keybindings (`prefix` is the default `Ctrl-b`):

| Key                     | Action                                                       |
|-------------------------|--------------------------------------------------------------|
| `r`                     | Reload config                                                |
| `h` / `j` / `k` / `l`   | Select pane (vim-style)                                      |
| `Alt` + `h`/`j`/`k`/`l` | Select pane, no prefix                                       |
| `Ctrl-p` / `Ctrl-n`     | Previous / next window                                       |
| `%` / `"`               | Split horizontally/vertically, keeping the current directory |

## NeoVim

- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstrapped on first launch)
- `lazy-lock.json` is **tracked**: the auto-bootstrap installs exactly the pinned commits, so a fresh machine gets the plugin set that is actually known to work here. `:Lazy update` moves to branch tips and rewrites the lock through the symlink — commit those bumps as their own `chore(nvim): bump plugin lock` commit, or `:Lazy restore` to go back.
- The leader key is **Space**
- Markdown tables auto-format with `gq` / `=` (`lua/mdformat.lua`)
- `:G` (fugitive status) opens in a vertical split when there's room
- Database client via [vim-dadbod](https://github.com/tpope/vim-dadbod) + [dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui): `:DBUI` (or `<leader>db`) opens the browser, `<leader>dc` adds a connection. Connections are saved to `.config/nvim/db_ui/` as JSON — **don't commit those files** (they can hold credentials).
- The clipboard uses OSC 52
- Spell check is on for `en` + `de_de`.

### LSP

For NeoVim's LSP settings to work you actually need the necessary language servers installed on your system (or in a development shell).

- c(++) requires `clang`(`d`)
- go requires `gopls`
- lua requires `lua-language-server`
- nix requires `nil`
- typescript/javascript requires `typescript-language-server`
- angular templates require `angular-language-server`
- css/scss/less requires `vscode-css-languageserver-bin`
- html requires `vscode-html-language-server`

#### Keybindings  

| Keybinding     | Description                                    | M    |
|----------------|------------------------------------------------|------|
| `leader + u`   | Toggles UndoTree                               | N    |
| `leader + db`  | Dadbod UI: Toggle database browser             | N    |
| `leader + dc`  | Dadbod UI: Add connection                      | N    |
| `leader + df`  | Dadbod UI: Find buffer                         | N    |
| `J`            | Moves selection down                           | V    |
| `K`            | Moves selection up                             | V    |
| `↓`            | Jumps 10 lines down                            | N    |
| `↑`            | Jumps 10 lines up                              | N    |
| `leader + p`   | Pastes without yanking                         | x    |
| `leader + y`   | Yanks to system clipboard                      | N, V |
| `leader + Y`   | Yanks to system clipboard                      | N    |
| `leader + ff`  | Telescope: Find Files                          | N    |
| `leader + fg`  | Telescope: Live Grep                           | N    |
| `leader + fb`  | Telescope: Buffers                             | N    |
| `leader + fh`  | Telescope: Help Tags                           | N    |
| `leader + r`   | LSP: Rename                                    | B    |
| `leader + a`   | LSP: Code Action                               | B    |
| `gd`           | LSP: Go to Definition                          | B    |
| `gD`           | LSP: Go to Declaration                         | B    |
| `gI`           | LSP: Go to Implementation                      | B    |
| `leader + D`   | LSP: Go to Type Definition                     | B    |
| `gr`           | Telescope: LSP References                      | B    |
| `leader + s`   | Telescope: LSP Document Symbols                | B    |
| `leader + S`   | Telescope: LSP Dynamic Workspace Symbols       | B    |
| `K`            | LSP: Hover                                     | B    |
| `Format`       | LSP: Format code                               | B    |
| `Ctrl + Space` | CMP: Complete                                  | N    |
| `Enter`        | CMP: Confirm and Replace                       | N    |
| `Tab`          | CMP: Select Next Item or Luasnip Expand/Jump   | N    |
| `Shift + Tab`  | CMP: Select Previous Item or Luasnip Jump Back | N    |

## opencode

Plugins and skills live in `plugins/` and `skills/` and are picked up automatically. Providers and MCP servers are configured in `opencode.json`, which is inherently per-machine — keep keys out of it and expect to edit the endpoints (see [Personalize](#personalize-before-use)). `webfetch` and the question tool are refused by `policies`, not `permissions`, so no repository's own `opencode.json` can turn them back on.

### Portable MCP launcher

`npx`-installed MCP servers are started via `sh -c` so one config works everywhere: NixOS has no node on `PATH` (it comes from `nix shell nixpkgs#nodejs`), Arch and the sandbox do, and the sandbox's `$HOME` may be unwritable. Both branches `exec`, so the client supervises the server directly — reuse the line, pin included.

## opencode tmux: idle-agent notifications

When you run opencode inside tmux, `plugins/tmux-notify/` flags the window of a session that **goes idle**, hits an **error**, or **asks for permission**: a red `●` in the tab plus a 5s toast, cleared when you switch back to that window (`window-status-format` and the `after-select-window` / `pane-focus-in` hooks in `tmux.conf`).

Only this terminal's own sessions can set or clear the flag. The logic runs in the TUI process (`tui.js`) so `TMUX_PANE` is the right pane; `index.js` is an empty server part that just makes the plugin discoverable.

Nothing to configure — it activates whenever opencode runs inside a tmux pane.
