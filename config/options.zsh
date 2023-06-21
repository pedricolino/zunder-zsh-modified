# HISTORY ----------------------------------------------------------------------
HISTFILE="$ZDOTDIR/.zsh_history"
HISTORY_IGNORE="exit"
HISTSIZE=50000
SAVEHIST=10000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing non-existent history.
setopt HIST_IGNORE_SPACE         # Do not store commands prefixed with a space

# COMPLETION STYLE -------------------------------------------------------------
setopt GLOBDOTS 
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true

# OTHER ------------------------------------------------------------------------
setopt AUTOCD     # Change working directory without using cd

# Change window title
# It doesn't change it when shell_integration is enabled in kitty terminal
# because it has its own way of doing it
if [[ -z $KITTY_SHELL_INTEGRATION ]]; then
    function set_win_title(){
        echo -ne "\033]0;"$USER@${HOST%%.*}:" ${PWD/$HOME/~}\007"
    }
    precmd_functions+=(set_win_title)
fi

zle_highlight+=(paste:none)  # Disable background color on paste

autoload -Uz select-word-style && select-word-style bash  # Bash word style

