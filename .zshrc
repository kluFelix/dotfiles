# Lines configured by zsh-newuser-install
# End of lines configured by zsh-newuser-install

if [[ -v IN_NIX_SHELL ]]; then
  # nix-shell prompt
  export PROMPT="%B%n@%m:%F{cyan}%~%f > %b"
else
  # normal prompt
  export PROMPT="%B%n@%m:%F{blue}%~%f > %b"
fi

if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi
