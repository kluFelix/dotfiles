# Lines configured by zsh-newuser-install
# End of lines configured by zsh-newuser-install

export PROMPT="%B%n@%m:%F{blue}%~%f > %b"

if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi
