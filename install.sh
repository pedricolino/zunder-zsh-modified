#!/bin/sh

FMT_RED=$(printf "\033[31m")
FMT_GREEN=$(printf "\033[32m")
FMT_YELLOW=$(printf "\033[33m")
FMT_BLUE=$(printf "\033[34m")
FMT_CYAN=$(printf "\033[36m")
FMT_BOLD=$(printf "\033[1m")
FMT_RESET=$(printf "\033[0m")

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
ZUNDER_ZSH_DIR="$HOME/.config/zunder-zsh"

set -e

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

fmt_error() {
    printf "%sError: %s%s\n" "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

fmt_warning() {
    printf "%s%s%s\n" "${FMT_BOLD}${FMT_YELLOW}" "$*" "$FMT_RESET"
}

fmt_success() {
    printf "%s%s%s\n" "$FMT_GREEN" "$*" "$FMT_RESET"
}

fmt_info() {
    printf "%s:: %s%s%s\n" "${FMT_BOLD}${FMT_CYAN}" "${FMT_RESET}${FMT_BOLD}" "$*" "$FMT_RESET"
}

fmt_prompt() {
    printf "%s:: %s%s%s" "${FMT_BOLD}${FMT_BLUE}" "${FMT_RESET}${FMT_BOLD}" "$*" "$FMT_RESET"
}

print_line() {
    printf "%*s\n" "$(stty size | cut -d ' ' -f2)" '' | tr ' ' '-'
}

install_icons() {
    fmt_info "Installing icons..."

    # Create directory if it doesn't exist
    mkdir -p "$HOME/.local/share/fonts"

    # Download font file
    curl -fLo "$HOME/.local/share/fonts/Symbols Nerd Font.ttf" \
        "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFont-Regular.ttf" \
        || return 1
}

install_package() {
    fmt_prompt "Do you want to install $*? [Y/n] "
    read -r response
    if [ "$response" != "n" ] && [ "$response" != "N" ]; then
        case $os_type in
            "arch") sudo pacman -S --noconfirm "$*" ;;
            *debian*) sudo apt install -y "$*" ;;
            "fedora") sudo dnf install --assumeyes "$*" ;;
            "opensuse suse") sudo zypper install -y "$*" ;;
            "darwin") brew install "$*" ;;
            "android") pkg install -y "$*" ;;
            "void") sudo xbps-install -y "$*" ;;
            *)
                echo
                fmt_error "Zunder-zsh doesn't support automatic package installations" \
                    "in your current operating system."
                echo "Please do it manually."
                exit 1
                ;;
        esac || {
            fmt_error "Installation failed."
            exit 1
        }
    else
        return 1
    fi
}

check_os_type() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        [ -n "$ID_LIKE" ] && os_type="$ID_LIKE" || os_type="$ID"
    else
        [ "$(uname)" = "Darwin" ] && os_type="darwin"

        case "$PREFIX" in
            *com.termux*) os_type="android" ;;
        esac
    fi

    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        is_wsl=true
        fmt_info "WSL detected."
    fi

    case $os_type in
        "arch")
            fmt_info "You are using an Arch-like distro."
            ;;
        *debian*)
            fmt_info "You are using a Debian-like distro."
            ;;
        "fedora")
            fmt_info "You are using a Fedora-like distro."
            ;;
        "opensuse suse")
            fmt_info "You are using an OpenSuse-like distro."
            ;;
        "darwin")
            fmt_info "You are using MacOS."
            ;;
        "android")
            fmt_info "You are using Termux on Android."
            ;;
        "void")
            fmt_info "You are using Void Linux."
            ;;
        *)
            fmt_warning "The type of your operating system couldn't be detected."
            echo "The functionality of the installer will be limited."
            fmt_prompt "Continue? [Y/n] "
            read -r response

            if [ "$response" = "n" ] || [ "$response" = "N" ]; then
                exit 1
            fi

            os_type="unknown"
            ;;
    esac
}

check_dependencies() {
    set -- "zsh" "git" "curl"

    fmt_info "Checking dependencies..."

    for dependency in "$@"; do
        if ! command_exists "$dependency"; then

            if [ "$os_type" = "unknown" ]; then
                fmt_error "$dependency is needed for zunder-zsh to work properly."
                echo "Please install it manually."
                exit 1
            fi

            install_package "$dependency" || {
                fmt_error "$dependency is needed for zunder-zsh to work properly."
                echo "Please install it manually or run again this script."
                exit 1
            }
        fi
        shift 1
    done

    [ "$#" -eq 0 ] && fmt_success "All dependencies satisfied."
}

load_files() {
    fmt_info "Zunder-zsh will replace your .zshrc and .zshenv."
    fmt_warning "Make a backup copy if necessary."
    fmt_prompt "Continue? [y/N]: "
    read -r prompt

    if [ "$prompt" = "Y" ] || [ "$prompt" = "y" ]; then
        ln -srf "$SCRIPT_DIR/config/.zshrc" "$HOME/.zshrc"
        ln -srf "$SCRIPT_DIR/config/.zshenv" "$HOME/.zshenv"
        if [ ! -d "$ZUNDER_ZSH_DIR" ]; then
            mkdir -p "$ZUNDER_ZSH_DIR"
            ln -srf "$SCRIPT_DIR/config/before.zsh" "$ZUNDER_ZSH_DIR"
            ln -srf "$SCRIPT_DIR/config/after.zsh" "$ZUNDER_ZSH_DIR"
        fi
        ln -srf "$SCRIPT_DIR/config/functions" "$ZUNDER_ZSH_DIR"
        ln -srf "$SCRIPT_DIR/config/spaceship.zsh" "$ZUNDER_ZSH_DIR"
        ln -srf "$SCRIPT_DIR/config/spaceship-section-slurm-jobs.plugin.zsh" "$ZUNDER_ZSH_DIR"
        ln -srf "$SCRIPT_DIR/config/spaceship-section-pending-slurm-jobs.plugin.zsh" "$ZUNDER_ZSH_DIR"
        ln -srf "$SCRIPT_DIR/config/spaceship-section-node-name.plugin.zsh" "$ZUNDER_ZSH_DIR"
        ln -srf "$SCRIPT_DIR/config/files_to_source" "$ZUNDER_ZSH_DIR"

        # add custom scripts from different repositories 
        git -C "$ZUNDER_ZSH_DIR/functions/biogrok" pull || \
            git clone --quiet "https://github.com/noporpoise/biogrok.git" "$ZUNDER_ZSH_DIR/functions/biogrok"
        git -C "$ZUNDER_ZSH_DIR/functions/MShTools" pull || \
            git clone --quiet --branch DLS/SLURM "https://github.com/mwinokan/MShTools.git" "$ZUNDER_ZSH_DIR/functions/MShTools"
        git -C "$ZUNDER_ZSH_DIR/functions/zsh-hist" pull || \
            git clone --quiet "https://github.com/marlonrichert/zsh-hist.git" "$ZUNDER_ZSH_DIR/functions/zsh-hist"
    else
        echo
        fmt_warning "Canceled."
        echo "This won't apply the configuration at all."
        exit 1
    fi
}

set_default() {
    ZSH_PATH="$(which zsh)"

    if [ "$os_type" != "android" ]; then
        
        # check if you have sudo rights
        prompt=$(sudo -nv 2>&1)
        if [ $? -eq 0 ]; then
            # exit code of sudo-command is 0
            echo "You have sudo rights."
            sudo usermod -s "$ZSH_PATH" "$USER"
        elif echo $prompt | grep -q '^sudo:'; then
            echo "You have sudo rights but need a password for this."
            sudo usermod -s "$ZSH_PATH" "$USER" # not sure if this
        else
            echo "You do not have sudo rights. Then I must cheat and add two lines to your .bash_profile"

            bash_profile_settings=$(printf "export SHELL=/bin/zsh\nexec /bin/zsh -l")

            if grep -Fq "$bash_profile_settings" "$HOME/.bash_profile"; then
            fmt_warning "Your .bash_profile already contains the same settings."
            else
                echo -e "$bash_profile_settings" >> "$HOME/.bash_profile"
            fi
        fi

    else
        chsh -s zsh
    fi
}

add_tmux_config() {
    # Append to the end of the file if it is does not contain those settings already
    if grep --quiet --no-messages --file "$SCRIPT_DIR/config/.tmux.conf" "$HOME/.tmux.conf"; then
        fmt_success "Your TMUX configuration already contains the same settings."
    else
        cat "$SCRIPT_DIR/config/.tmux.conf" >> "$HOME/.tmux.conf"
        fmt_success "TMUX configuration added."
    fi
}

add_nano_config() {
    # Append to the end of the file if it is does not contain those settings already
    if grep --quiet --no-messages --file "$SCRIPT_DIR/config/.nanorc" "$HOME/.nanorc"; then
        fmt_success "Your Nano configuration already contains the same settings."
    else
        cat "$SCRIPT_DIR/config/.nanorc" >> "$HOME/.nanorc"
        fmt_success "Nano configuration added."
    fi
}

main() {
    check_os_type

    echo
    [ "$os_type" != "darwin" ] && check_dependencies

    echo
    load_files

    if ! [ -d "$HOME/.local/share/zap" ]; then
        echo
        fmt_info "Installing plugins..."
        zsh -i -c exit
    fi

    if [ "$os_type" != "darwin" ] && [ "$os_type" != "android" ] && [ "$os_type" != "unknown" ] && [ -z "$is_wsl" ]; then
        fc-list | grep -q "Symbols Nerd Font" || (echo && install_icons)
    fi

    if [ "$(basename "$SHELL")" != "zsh" ]; then
        echo
        fmt_prompt "Zsh isn't your current default shell, do you want to set it? [Y/n]: "
        read -r prompt

        if [ "$prompt" != "n" ] && [ "$prompt" != "N" ]; then
            if set_default >/dev/null 2>&1; then
                fmt_success "Zsh was applied as default shell."
                fmt_warning "You may have to restart your computer to apply the changes."
            else
                fmt_error "Zsh couldn't be applied as the default shell."
            fi
        else
            fmt_warning "Zsh won't be set as the default shell."
        fi
    fi

    fmt_info "Do you want to add my personal TMUX configuration?"
    fmt_info "It will enable the mouse, scrolling and switching between panels with Alt and arrow key (left/right/up/down)"
    fmt_prompt "[Y/n]:"
    read -r prompt

    if [ "$prompt" != "n" ] && [ "$prompt" != "N" ]; then
        add_tmux_config
    fi

    fmt_info "Do you want to add my personal Nano settings?"
    fmt_info "It will add coloring and change your shortcuts to Windows-like shortcuts such as CTRL+Z to undo, CTRL+S to save and CTRL+Q to quit."
    fmt_warning "Note that you need to quit Nano wit CTRL+Q then."
    fmt_prompt "[Y/n]:" 
    read -r prompt

    if [ "$prompt" != "n" ] && [ "$prompt" != "N" ]; then
        add_nano_config
    fi

    echo
    fmt_success "Installation complete."
}

main "$@"
