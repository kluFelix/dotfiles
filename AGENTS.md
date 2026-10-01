## Rules

This directory is the single source of truth for my shell/editor/git/opencode config, deployed by GNU Stow: `stow .` symlinks these files into `$HOME` (`.config/*` merges into `~/.config/`).

- Make config changes ONLY in this repo. Never edit `~/.config/...`, `~/.zshrc`, or `~/.gitconfig` directly — they are stow symlinks (or stale copies) of files here.
- Never run `stow` (stow/unstow/restow); leave deployment to the user. Edits to already-linked files apply live through the symlinks, so no redeploy is needed.
- Update `README.md` when adding a new tool or making major changes.
