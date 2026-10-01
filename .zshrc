HISTFILE=~/.zsh_history
SAVEHIST=100000
HISTSIZE=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_EXPIRE_DUPS_FIRST HIST_REDUCE_BLANKS EXTENDED_HISTORY

eval "$(direnv hook zsh)"

for zsh_autosuggestions in \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-contrib/zsh-autosuggestions/zsh-autosuggestions.zsh \
    "$HOME/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
    if [[ -f $zsh_autosuggestions ]]; then
        source $zsh_autosuggestions
        ZSH_AUTOSUGGEST_STRATEGY=(history)
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
        break
    fi
done

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

# interactive shells get a tmux; over ssh reuse one named session
if [[ $- == *i* ]] && command -v tmux >/dev/null && [[ -z "$TMUX" ]]; then
    if [[ -n "$SSH_TTY" ]]; then
        tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
    else
        tmux
    fi
fi

alias ll='ls -lah --color=auto'
export EDITOR=nvim

# must be sourced last
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]=fg=green
ZSH_HIGHLIGHT_STYLES[builtin]=fg=green

for zsh_syntax_highlighting in \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    "$HOME/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
do
    if [[ -f $zsh_syntax_highlighting ]]; then
        source $zsh_syntax_highlighting
        break
    fi
done
