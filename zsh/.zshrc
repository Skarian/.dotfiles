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
source "$HOME/projects/emsdk/emsdk_env.sh"

# Terminal Integrations
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Aliases
alias spotify='spotify_player'
alias j='just'
alias ls='eza -l --icons=always --no-permissions --no-user -h -a'
alias m2pdf="md_folder_to_pdf.sh"
alias j2src="jpg_to_src.sh"
alias rvim="start_neovim_remote.sh"
alias compressvideo="compress_video.sh"
alias rscript="cargo +nightly -Zscript"
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

# Startup
macchina
compdef _flyctl fly
