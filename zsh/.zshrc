# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell" <---------- default

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
export FZF_BASE=/opt/homebrew/Cellar/fzf/0.38.0
plugins=(zsh-autosuggestions zsh-syntax-highlighting z git tmux web-search 
ripgrep fzf rye)


source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

eval "$(starship init zsh)"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# alias watch='cargo watch -q -c -w src/ -x "run"'

alias spotify='spotify_player'

alias j='just'
alias ls='eza -l --icons=always --no-permissions --no-user -h -a'


alias m2pdf="md_folder_to_pdf.sh"
alias j2src="jpg_to_src.sh"
alias rvim="start_neovim_remote.sh"
alias compressvideo="compress_video.sh"
alias rscript="cargo +nightly -Zscript"
alias svim="NVIM_APPNAME=svim nvim"
alias avim="NVIM_APPNAME=astronvim_v4 nvim"

# Renames tmux windows based on run command with just (command runner in rust), ignores when in neovim, and ignores when using flags
# Define the function `preexec`
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


# Has Bash Scripts
export PATH="$HOME/scripts:$PATH"

# Runs command on startup to show system info
macchina
source "$HOME/.rye/env"
