# ========================
# Navigation
# ========================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'


# ========================
# Reload / config
# ========================
alias reload='exec zsh'
alias sz='source ~/.zshrc'

# ========================
# zoxide (smart cd)
# ========================

# ========================
# Modern CLI replacements
# ========================
alias ls='eza --icons --group-directories-first'
alias l='eza -1 --icons'
alias ll='eza -lah --icons --git --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias lta='eza --tree --level=3 --all --icons'
alias cat='bat --paging=never'
# Modern CLI Replacements
alias ff='fastfetch'
#GIT aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gf='git fetch'
alias gd='git diff'
alias gco='git checkout'
