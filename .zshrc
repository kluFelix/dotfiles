# Lines configured by zsh-newuser-install
# End of lines configured by zsh-newuser-install

eval "$(direnv hook zsh)"

# prompt that updates after direnv runs
set_prompt() {
    if [[ -v DIRENV_DIR ]]; then
        # direnv prompt
        export PROMPT="%B%n@%m:%F{yellow}%~%f > %b"
    elif [[ -v IN_NIX_SHELL ]]; then
        # direnv prompt
        export PROMPT="%B%n@%m:%F{cyan}%~%f > %b"
    else
        # normal prompt
        export PROMPT="%B%n@%m:%F{blue}%~%f > %b"
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt

# ssh → tmux
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi

