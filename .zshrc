# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
# zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^l' clear-screen  # Clear screen with Ctrl+L
bindkey '^H' show-aliases-and-binds  # Show all aliases and keybindings with Ctrl+H
bindkey '^Bh' show-keybindings  # Show keybindings with Ctrl+B followed by h
bindkey '^Ah' show-aliases  # Show aliases with Ctrl+A followed by h
bindkey "^[[1;3D" backward-word # Move backward a word with Ctrl + Left
bindkey "^[[1;3C" forward-word # Move forward a word with Ctrl + Right
bindkey "^[[3;5~" kill-word # Delete the next word with Ctrl + Delete

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ======================
# Aliases
# ======================
alias ll='ls -la'
alias df='df -h'
alias du='du -h'
alias mkdir='mkdir -p'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='exa --icons --color=auto'  # Enhanced ls
alias cat='batcat'                      # Enhanced cat
alias vim='nvim'
alias vi='nvim'
alias c='clear'
alias grep='rg'                      # Enhanced grep
alias fd='fdfind'                    # Enhanced find

# Git aliases
alias gst='git status'
alias ga='git add'
alias gad='git add --all'
alias gc='git commit -m'
alias gd='git diff'
alias gl='git log'
alias glo='git log --oneline --graph'

# Functions
fzf-history-search() {
  BUFFER=$(fc -l 1 | tac | fzf --height 40% --reverse --tac --prompt="History> ")
  CURSOR=${#BUFFER}
  zle reset-prompt
}
zle -N fzf-history-search
bindkey '^R' fzf-history-search

show-aliases-and-binds() {
  local choices
  choices=$( (echo "Aliases"; alias; echo "Keybindings"; bindkey) | fzf --prompt="Select an option: " --height=40% --reverse )
  [[ -n "$choices" ]] && echo "$choices"
}

zle -N show-aliases-and-binds

show-keybindings() {
  local choices
  choices=$(bindkey | fzf --prompt="Select a keybinding: " --height=40% --reverse)
  [[ -n "$choices" ]] && echo "$choices"
}
zle -N show-keybindings

show-aliases() {
  local choices
  choices=$(alias | fzf --prompt="Select an alias: " --height=40% --reverse)
  [[ -n "$choices" ]] && echo "$choices"
}
zle -N show-aliases

# A shortcut to update the system and packages
update_all() {
  echo "Updating system..."
  eval "$UPDATE_CMD"
  echo "Updating zinit plugins..."
  zinit self-update && zinit update --all
}
alias update='update_all'

# Path
export PATH="$HOME/.local/bin:$PATH"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(gh completion -s zsh)"  # GitHub CLI completion

