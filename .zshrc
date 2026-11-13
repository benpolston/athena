# ~/.zshrc

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="${EDITOR:-nano}"

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# Behaviour
setopt AUTO_CD INTERACTIVE_COMMENTS
bindkey -e                                   # emacs-style keys (Ctrl+A/E etc, like bash)
bindkey '^[[1;5C' forward-word               # Ctrl+Right
bindkey '^[[1;5D' backward-word              # Ctrl+Left
bindkey '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char

# Up/Down search history for what you've already typed
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search '^[[B' down-line-or-beginning-search

# Completion: menu you can arrow through, case-insensitive
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'

# CTF helpers (bash-compatible)
[ -f ~/.config/bash/ctf.sh ] && source ~/.config/bash/ctf.sh

# Terminal toys
alias bonsai='cbonsai -l -i'          # grow a live bonsai tree (q to quit)
alias aquarium='asciiquarium'
alias pipes='pipes.sh -t 1 -R'
alias matrix='cmatrix -ab -u 3'
# showoff  -> fills workspace 9 with btop, cava, bonsai, pipes, fastfetch

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# thefuck: type "fuck" to fix the last command
command -v thefuck >/dev/null && eval "$(thefuck --alias)"

# Prompt
eval "$(starship init zsh)"

# Greeting: only in a fresh top-level terminal window
[[ $SHLVL -le 2 && -z $NO_FETCH && -n $KITTY_WINDOW_ID ]] && fastfetch

# Must be last
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

