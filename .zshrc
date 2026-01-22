# Lines configured by zsh-newuser-install
# End of lines configured by zsh-newuser-install

eval "$(direnv hook zsh)"

# prompt that updates after direnv runs
set_prompt() {
    # check for Python virtual environment
    if [[ -v VIRTUAL_ENV || -v CONDA_DEFAULT_ENV ]]; then
        local prompt_marker="%F{green}>%f"
    else
        local prompt_marker=">"
    fi
    
    # check for direnv and nix shell
    if [[ -v DIRENV_DIR ]]; then
        # direnv prompt
        export PROMPT="%B%n@%m:%F{yellow}%~%f $prompt_marker %b"
    elif [[ -v IN_NIX_SHELL ]]; then
        # nix shell prompt
        export PROMPT="%B%n@%m:%F{cyan}%~%f $prompt_marker %b"
    else
        # normal prompt
        export PROMPT="%B%n@%m:%F{blue}%~%f $prompt_marker %b"
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt

# ssh → tmux
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi

