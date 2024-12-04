# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/fnowinski/.oh-my-zsh"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:/Users/fnowinski/.path_scripts"
export PATH="/Users/fnowinski/Library/Python/3.9/bin:$PATH"
export PATH="/opt/homebrew/opt/node@14/bin:$PATH"
# export PATH="/Users/fnowinski/.nvm/versions/node/v18.16.0/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c@76/bin:$PATH"
export PATH="/opt/homebrew/opt/icu4c@76/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"
# export SSL_CERT_FILE="/Users/fnowinski/.rbenv/versions/3.1.3/openssl/ssl/cert.pem"
# export ODDS_API_KEY="b8c9a9168cc35e003f3a8799d382cedd"

eval "$(rbenv init - zsh)"
#
export EDITOR='nvim'

bindkey -e

# ZSH_THEME=cobalt2
# ZSH_CUSTOM=$HOME/dotfiles
# ZSH_DISABLE_COMPFIX=true

HYPHEN_INSENSITIVE="true"
HIST_STAMPS="mm/dd/yyyy"
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

source ~/dotfiles/aliases.zsh
source ~/dotfiles/work.zsh

plugins=(
  git
  z
  zsh-autosuggestions
  # forgit # Add forgit to /.oh-my-zsh/plugins/
)

function terminate() {
  local port=$1
  local pids=($(lsof -t -i ":$port"))

  if [[ ${#pids[@]} -gt 0 ]]; then
    echo "Killing processes on port $port"
    for pid in "${pids[@]}"; do
      kill -9 $pid
    done
  else
    echo "No processes found on port $port"
  fi
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey ',m' fzf-file-widget

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!{node_modules/*,.git/*,vendor/*,assets/*,coverage/*,tmp/*,public/*}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_COMMAND='fd --type d . --color=never'
export FZF_DEFAULT_OPTS='
  --height 75% --multi
  --bind ctrl-f:page-down,ctrl-b:page-up
  --bind ctrl-p:abort
  --color=fg:-1,bg:-1,hl:#5fd7ff
  --color=fg+:-1,bg+:-1,hl+:#79e7fa
  --color=info:#87ff00,prompt:#ff76ff,pointer:#ff76ff
  --color=marker:#87ff00,spinner:#00c5c7,header:#00c5c7
  --color=preview-fg:#87ff00
'

# Find in file
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  local file
  file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$@" | fzf-tmux +m --preview="rga --ignore-case --pretty --context 10 '"$@"' {}")" && open "$file"
}

# Checkout branch with fuzzy-finder
cob() {
  git co $(git branch | fzf)
}

getmain() {
  main
  git co -
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
#
# ##### For gem install, may need to comment out 12/3
# export CXXFLAGS="-I/Library/Developer/CommandLineTools/SDKs/MacOSX15.0.sdk/usr/include/c++/v1"
#
source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
