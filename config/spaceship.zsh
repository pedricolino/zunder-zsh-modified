SPACESHIP_PROMPT_ORDER=(
    dir            # Current directory section
    git            # Git section (git_branch + git_status)
    venv           # virtualenv section
    conda
    exec_time      # Execution time
    exit_code 
    time 
    jobs           # Background jobs indicator
    async          # Async jobs indicator
    line_sep       # Line break
    char           # Prompt character
)

SPACESHIP_PROMPT_ADD_NEWLINE=false
_spaceship_add_newline() {
    [ -z "$_should_add_newline" ] && _should_add_newline=true || echo
}
precmd_functions+=(_spaceship_add_newline)
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=black
SPACESHIP_EXIT_CODE_SHOW=true

SPACESHIP_DIR_TRUNC=2
SPACESHIP_DIR_TRUNC_REPO=true
SPACESHIP_DIR_TRUNC_PREFIX="…/"

SPACESHIP_CONDA_VERBOSE=true

SPACESHIP_VENV_PREFIX="using "
SPACESHIP_VENV_SYMBOL="> "

SPACESHIP_CHAR_COLOR_SUCCESS="reset"
if [[ "$TERM" = "linux" ]]; then
    SPACESHIP_CHAR_SYMBOL="> "
else
    SPACESHIP_CHAR_SYMBOL="> "
    SPACESHIP_CHAR_SYMBOL_SECONDARY="· "
    SPACESHIP_CHAR_COLOR_SECONDARY=8
fi
SPACESHIP_CONDA_SYMBOL=""
