# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/fnowinski/.oh-my-zsh"
export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:/Users/fnowinski/.path_scripts"
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export EDITOR='vim'
export GOPRIVATE=github.com/movableink

source /Users/fnowinski/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

bindkey -e

#ZSH_THEME=cobalt2
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_CUSTOM=$HOME/dotfiles
ZSH_DISABLE_COMPFIX=true

HYPHEN_INSENSITIVE="true"
HIST_STAMPS="mm/dd/yyyy"

##SOURCE_FILES+=(~/dotfiles/aliases)
##for file in $SOURCE_FILES[@]; do
  ##source "$file"
##done

plugins=(
  git
  z
  forgit # Add forgit to /.oh-my-zsh/plugins/
)

alias master='git co master && git pull origin master && git fetch'
alias main='git co main && git pull origin main && git fetch'
alias integration='git co integration && git pull origin integration && git fetch'
alias amend='git commit --amend --no-edit'
alias push='git push -f origin HEAD'
alias gst="git status"
alias gd="git diff"
alias gco="git co"
alias gadd="git add ."
alias gcont="git rebase --continue"
alias gpush="git push origin head"
alias gpull="git pull origin `git branch`"
alias ci="git ci -m "
alias grebase="git rebase -i origin/master"
alias migrate="bundle exec rake db:migrate"
alias tdev="tmux a -t dev"
alias tkill="killall tmux"
alias rubo="git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs rubocop -a"
alias migrate_test="RAILS_ENV=test bundle exec rake db:migrate && rake db:test:prepare"
alias reset="git co origin/master "

alias be="bundle exec"
alias rc="bundle exec rails c"
alias rs="bundle exec rails s"
alias rspec='be rspec'
alias gstash='git stash save'
alias glist='git stash list'
alias gpop='git stash pop'
alias lss="ls -ltr"
alias al="ls -al"
alias ssh='TERM=xterm-256color ssh'
alias Z='fg'
alias ftest='yarn test -s --no-launch'
alias multi="./bin/rails c -- --nomultiline"

#alias ctags="ctags --recurse=yes --exclude=.git --exclude=BUILD --exclude=.svn --exclude=db --exclude=node_modules --exclude=vendor --exclude=log --exclude=assets"
#alias gemtags="ctags -R -f gem.tags --recurse=yes --exclude=.git --exclude=BUILD --exclude=.svn --exclude=db --exclude=node_modules --exclude=vendor --exclude=log --exclude=assets"
alias ctags="ctags --recurse=yes --exclude=.git --exclude=BUILD --exclude=.svn --exclude=db --exclude=node_modules --exclude=log --exclude=assets"

# Link solargraph repos
# ln -s ~/src/enhance-rails-intellisense-in-solargraph/rails.rb <project_root>/config/definitions.rb
regex () {
  gawk 'match($0,/'$1'/, ary) {print ary['${2:-'0'}']}'
}


## Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export TERM=term
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey ',m' fzf-file-widget

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!{node_modules/*,.git/*,vendor/*,assets/*,tmp/*,public/*}"'
#export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
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

## Find in file
#fif() {
  #if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  #local file
  #file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$@" | fzf-tmux +m --preview="rga --ignore-case --pretty --context 10 '"$@"' {}")" && open "$file"
#}

## Checkout branch with fuzzy-finder
cob() {
  git co $(git branch | fzf)
}

terminate () {
  lsof -i TCP:$1 | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} IPv4 | awk '{print $2}' | xargs kill -9
}


# Lazy git
lg()
{
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

  lazygit "$@"

  if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
  fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
alias python=python3

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

source $ZSH/oh-my-zsh.sh
