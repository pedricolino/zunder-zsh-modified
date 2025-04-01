#                                _                       _
#            _____   _ _ __   __| | ___ _ __     _______| |__
#           |_  / | | | '_ \ / _` |/ _ \ '__|___|_  / __| '_ \
#            / /| |_| | | | | (_| |  __/ | |_____/ /\__ \ | | |
#           /___|\__,_|_| |_|\__,_|\___|_|      /___|___/_| |_|
#
## INITIALIZATION =============================================================
# Directory where files related to zunder-zsh are located.
ZUNDER_ZSH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zunder-zsh"

# By default zcompdump is created in the home directory, so we will create a
# directory for the zsh cache in a separate directory to clean things up a
# little bit.
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Creates the cache directory if doesn't exist, as compinit will fail if it
# doesn't find the directory in which .zcompdump is specified to be located.
[[ ! -d "$CACHE_DIR" ]] && mkdir -p "$CACHE_DIR"

# Disable syntax highlightling in WSL.
[[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] && SYNTAX_HIGHLIGHTING_PROVIDER="none"

# Fallback prompt.
PROMPT=$'%B%F{cyan}%~%f%#%b '

# Disable autosuggestions and exa in Linux tty and replace prompt character.
if [[ "$TERM" == "linux" ]]; then
    DISABLE_AUTOSUGGESTIONS=true
    DISABLE_EXA=true
fi

## ZAP ========================================================================
# Clone zap
ZAP_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zap"
[[ ! -d "$ZAP_DIR" ]] \
    && git clone https://github.com/zap-zsh/zap.git --depth=1 "$ZAP_DIR"

# Load zap
[[ -f "$ZAP_DIR/zap.zsh" ]] && source "$ZAP_DIR/zap.zsh"

# Load zsh-defer plugin and plug-defer command
plug romkatv/zsh-defer
fpath+=("$ZUNDER_ZSH_DIR/functions")
autoload plug-defer

## BEFORE CONFIG ==============================================================
if [[ -f "$ZUNDER_ZSH_DIR/before.zsh" ]]; then
    source "$ZUNDER_ZSH_DIR/before.zsh"
fi

## COMPLETIONS ================================================================
# Changes the zcompdump directory. The .zcompdump file is used to improve
# compinit's initialization time.
ZCOMPDUMP_PATH="$CACHE_DIR/.zcompdump"

# Initializes completion system. Relevant documentation:
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Use-of-compinit.
autoload -Uz compinit && compinit -d $ZCOMPDUMP_PATH

# Compiles the .zcompdump to load it faster next time.
# Search for zcompile in https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html.
[[ "$ZCOMPDUMP_PATH.zwc" -nt "$ZCOMPDUMP_PATH" ]] \
    || zsh-defer zcompile "$ZCOMPDUMP_PATH"

# Matches completion menu colors with the LS_COLORS variable.
[[ -n $LS_COLORS ]] && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Marks the selected item in the completion menu.
zstyle ':completion:*:*:*:*:*' menu select

# Makes the completion case-insensitive unless a uppercase is used and fuzzy.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

# Enables cache. I have not found any real use for it but theoretically it's
# useful to improve the speed of some completions.
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$CACHE_DIR/.zcompcache"

# Attempts to find new commands to complete.
zstyle ':completion:*' rehash true

# Specifies which characters are considered part of a word for completion
# purposes. In this case, underscores (_) and hyphens (-) will be treated as
# part of words, preventing the shell from splitting at these characters during
# word completion.
WORDCHARS='_-'

## KEYBINDINGS ================================================================
# Forces the use of emacs keyboard shortcuts. By default uses the vim ones,
# but they are not very good by default and can be confusing for novice users.
bindkey -e

# These additional shortcuts only apply to emacs mode, since they have the
# `-M emacs` flag.

# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs "^[[1;5D" backward-word
# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs "^[[1;5C" forward-word

# [Alt-LeftArrow] - move backward one word
bindkey -M emacs "^[[1;3D" backward-word
# [Alt-RightArrow] - move forward one word
bindkey -M emacs "^[[1;3C" forward-word

# [Shift-Tab] - move through the completion menu backwards
bindkey -M emacs "^[[Z" reverse-menu-complete

# [Delete] - delete forward
bindkey -M emacs "^[[3~" delete-char
# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word

# Start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey -M emacs "^[[A" up-line-or-beginning-search

# Start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M emacs "^[[B" down-line-or-beginning-search

## HISTORY ====================================================================
HISTFILE="$HOME/.zsh_history" # Location of the history file.
HISTSIZE=100000                # Maximum number of commands in the history.
SAVEHIST=10000                # Number of commands to save between sessions.
setopt share_history          # Share history between sessions.

## ALIASES ====================================================================
# ls, grep and tree doesn't have color enabled by default, so this aliases enables it.
if [[ "$(uname)" = "Darwin" ]]; then
    alias ls="ls -G" # MacOS
else
    alias ls="ls --color=auto" # GNU/Linux
fi
alias grep="grep --color=auto"
[[ -n "$commands[tree]" ]] && alias lt="tree"

# Useful aliases to list files.
alias la="ls -A"
alias ll="ls -l"
alias lla="ls -lA"

# Uses exa instead if installed and enabled.
if [[ "$DISABLE_EXA" != true && (-n "$commands[eza]" || -n "$commands[exa]") ]]; then
    [[ -n "$commands[eza]" && -z "$commands[exa]" ]] && alias exa="eza"
    alias ls="exa --icons --group-directories-first"
    alias ll="exa --icons --group-directories-first  --time-style 'relative' --git -l"
    alias la="exa --icons --group-directories-first -a"
    alias lla="exa --icons --group-directories-first  --time-style 'relative' --git -la"
    alias lt="exa --icons -T"

    # show absolute time format if required
    alias ll_time="exa --icons --group-directories-first --git -l"
    alias lla_time="exa --icons --group-directories-first --git -la"
fi

# More secure rm, cp and mv operations.
alias rm="rm -v"
alias cp="cp -vi"
alias mv="mv -vi"

## OTHER ======================================================================
# Disables highlighting of pasted text.
zle_highlight+=(paste:none)

# If a command is issued that can’t be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
setopt autocd

# Sets window title. This is ignored in kitty because it has its way to do it.
if [[ $TERM != "xterm-kitty" ]]; then
    case "$TERM" in
        cygwin | xterm* | putty* | rxvt* | konsole* | ansi | mlterm* | alacritty | st* | foot* | contour*)
            function set_window_title() {
                print -Pn "\e]2;${USER}@${HOST}:${PWD/$HOME/~}\a"
            }
            autoload -Uz add-zsh-hook
            add-zsh-hook precmd set_window_title
            ;;
    esac
fi

## ZSH PLUGINS ================================================================
# Spaceship prompt
if [[ "$DISABLE_SPACESHIP_PROMPT" != true ]]; then
    SPACESHIP_CONFIG="$ZUNDER_ZSH_DIR/spaceship.zsh"
    plug spaceship-prompt/spaceship-prompt
fi

# Command not found message
plug warbacon/zsh-command-not-found

# Additional completions
plug zsh-users/zsh-completions

# Autosuggestions
if [[ "$DISABLE_AUTOSUGGESTIONS" != true ]]; then
    plug-defer zsh-users/zsh-autosuggestions
    ZSH_AUTOSUGGEST_MANUAL_REBIND=1
fi

# Syntax highlighting
case "$SYNTAX_HIGHLIGHTING_PROVIDER"; in
    fast-syntax-highlighting)
        plug-defer zdharma-continuum/fast-syntax-highlighting
        ;;
    none)
        ;;
    *)
        plug-defer zsh-users/zsh-syntax-highlighting
        ;;
esac

## AFTER CONFIG ===============================================================
if [[ -f "$ZUNDER_ZSH_DIR/after.zsh" ]]; then
    source "$ZUNDER_ZSH_DIR/after.zsh"
fi

## Conda ======================================================================
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/data/cephfs-1/home/users/cemo10_c/work/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/data/cephfs-1/home/users/cemo10_c/work/miniconda/etc/profile.d/conda.sh" ]; then
        . "/data/cephfs-1/home/users/cemo10_c/work/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/data/cephfs-1/home/users/cemo10_c/work/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

## PERSONAL ZSH PREFERENCES ====================================================
# Allow completion from within a word/phrase
setopt COMPLETE_IN_WORD

# When completing from the middle of a word, move the cursor to the end of the word
setopt ALWAYS_TO_END

# Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt PROMPT_SUBST

# Do not write events to history that are duplicates of previous events
setopt HIST_IGNORE_DUPS

# When searching history don't display results already cycled through twice
setopt HIST_FIND_NO_DUPS

# Remove extra blanks from each command line being added to history
# setopt HIST_REDUCE_BLANKS

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS

## TMUX auto attach ============================================================
# from https://gist.github.com/ThomasLeister/c18fb2666fb0924c6555634892285264
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then      # if this is an SSH session
    if which tmux >/dev/null 2>&1; then                 # check if tmux is installed
            if [[ -z "$TMUX" ]] ;then                   # do not allow "tmux in tmux"
                    ID="$( tmux ls | grep -vm1 attached | cut -d: -f1 )" # get the id of a deattached session
                    if [[ -z "$ID" ]] ;then                              # if not available create a new one
                            tmux new-session
                    else
                            tmux attach-session -t "$ID"                 # if available, attach to it
                    fi
            fi
    fi
fi

## ZSH-hist PLUGIN =============================================================
# It automatically formats commands in the history.
source "$ZUNDER_ZSH_DIR/functions/zsh-hist/zsh-hist.plugin.zsh"
unsetopt HIST_REDUCE_BLANKS

# Do not add failed commands to history.
# See https://superuser.com/a/902508
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

autoload -Uz add-zsh-hook
add-zsh-hook precmd zshaddhistory

## SYNTAX HIGHLIGHTING IN LESS ================================================
# Get syntax highlighting in less if the package source-highlight is installed.
# Your path to the relevant source-highlight script might differ.
SOURCE_HIGHLIGHT_SCRIPT='~/work/bin/src-hilite-lesspipe.sh'
# # If the script is found, set it as the LESSOPEN variable.
if [[ -n $SOURCE_HIGHLIGHT_SCRIPT ]]; then
    export LESSOPEN="| $SOURCE_HIGHLIGHT_SCRIPT %s"
# https://www.meejah.ca/blog/less-pygments
#   export LESSOPEN="| pygmentize -f terminal -O -style=native -g %s"
    export LESS=' -R '
fi

## PERSONAL ADDITIONS ===========================================================
# source my custom aliases and functions
for file in $ZUNDER_ZSH_DIR/files_to_source/*.sh
do
    source "$file"
done

# for fzf
source <(fzf --zsh)

# set TMP directory (also important for SNAPPY)
export TMPDIR=$HOME/scratch/tmp/$(hostname)
mkdir -p $TMPDIR

# variables for different tools
export VSCODE_CLI_USE_FILE_KEYCHAIN=1
export NXF_SINGULARITY_CACHEDIR=~/.singularity
export MSHTOOLS=$ZUNDER_ZSH_DIR/functions/MShTools

# add automatically added repositories with script collections to path
export PATH=$PATH:$(find "$ZUNDER_ZSH_DIR/functions" -maxdepth 1 -type d | paste -sd ":" -)

# set nano as the default editor because I am not familiar with vi/vim (yet)
export EDITOR='nano'
