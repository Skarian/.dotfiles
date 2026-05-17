# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(zsh-autosuggestions zsh-syntax-highlighting z git tmux web-search 
    fzf rye)
    
source $ZSH/oh-my-zsh.sh

# User configuration
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Environment Variables
export FZF_BASE=/opt/homebrew/Cellar/fzf/0.38.0
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/scripts:$PATH"
export EMSDK_QUIET=1
export MAKE=/opt/homebrew/bin/gmake
export PATH="/Applications/Godot.app/Contents/MacOS:$PATH"

# Tool initialization
eval "$(starship init zsh)"

# Terminal Integrations
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Aliases
alias spotify='spotify_player'
alias j='just'
alias ls='eza -l --icons=always --no-permissions --no-user -h -a'
alias m2pdf="md_folder_to_pdf.sh"
alias j2src="jpg_to_src.sh"
alias rvim="start_neovim_remote.sh"
alias compress_video="compress_video.sh"
alias compress_videos="compress_videos.sh"
alias compress_image="compress_image.sh"
alias rscript="cargo +nightly -Zscript"
alias download-urls="/Users/nskaria/projects/nvme-downloader/download-urls.js"
alias nvim="NVIM_APPNAME=astronvim_v4 nvim"
alias make='/opt/homebrew/bin/gmake' # More updated make from brew

# [Custom Function]: Renames tmux windows based on run command with just (command runner in rust), ignores when in neovim, and ignores when using flags
function preexec() {
    # Check if the TMUX environment variable is set (i.e., if we're running within a tmux session)
    if [[ -n ${TMUX} ]]; then  
        # Split the command being run into an array of words (`cmd`). 
        # In shell scripting, `$1` refers to the first argument to the function, which in this case is the command being run.
        local -a cmd=(${(z)1})  

        # Get the name of the command currently being executed in the active tmux pane and store it in the variable `current_terminal`.
        local current_terminal=$(tmux display-message -p '#{pane_current_command}')

        # Check if the command currently being run in the active tmux pane is NOT `nvim`.
        if [[ "${current_terminal}" != "nvim" ]]; then
            # Check if:
            # 1. The first word of the command is "just" or "j" AND
            # 2. The command has more than one word AND
            # 3. The second word in the command does NOT start with a dash ("-").
            if { [[ "${cmd[1]}" == "just" ]] || [[ "${cmd[1]}" == "j" ]]; } && (( $#cmd > 1 )) && [[ "${cmd[2]}" != -* ]]; then
                # If all conditions are met, rename the tmux window to the second word in the command.
                tmux rename-window "${cmd[2]}"
            # If the first word of the command is "spotify_player" OR "spotify" and there are no additional flags or arguments (i.e., the command has exactly one word),
            elif { [[ "${cmd[1]}" == "spotify_player" ]] || [[ "${cmd[1]}" == "spotify" ]]; } && (( $#cmd == 1 )); then
                # rename the window to "spotify".
                tmux rename-window "spotify"
            fi
        fi
    fi
}

# For ESP32 - Rust
# source $HOME/export-esp.sh

# source $HOME/esp/esp-idf/export.sh
# For primary esp32 https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html#get-started-prerequisites
alias get_idf='. $HOME/esp/esp-idf/export.sh'

alias eml2md='/Users/nskaria/projects/eml2md/target/release/eml2md'


# Startup
macchina
compdef _flyctl fly
eval "$(direnv hook zsh)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# export NDK_HOME="/Users/nskaria/Library/Android/sdk/ndk/29.0.14206865"
# export PATH="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

# Android SDK
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT" # legacy compatibility for some tools

# Android Studio bundled JDK
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# Prefer these binaries first
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$PATH"


# Created by `pipx` on 2026-02-13 16:53:50
export PATH="$PATH:/Users/nskaria/.local/bin"

export CLOUDSDK_PYTHON="/opt/homebrew/bin/python3.10"
export PATH=/opt/homebrew/share/google-cloud-sdk/bin:"$PATH"

export GCP_PROJECT_ID="vr2xr"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nskaria/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nskaria/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nskaria/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nskaria/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

export VR2XR_UPLOAD_STORE_FILE="$HOME/googleplay/keystore/vr2xr-upload.jks"
export VR2XR_UPLOAD_KEY_ALIAS="vr2xr-upload"
export VR2XR_VERSION_NAME="0.0.1"
export VR2XR_VERSION_CODE="1"

if [ -f "$HOME/.zsh/secrets.zsh" ]; then
    source "$HOME/.zsh/secrets.zsh"
fi

alias codex-notify='sh /Users/nskaria/.codex/notifications/codex-bell.sh'
