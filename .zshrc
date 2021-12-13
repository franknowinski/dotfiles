export ZSH="/Users/franknowinski/.oh-my-zsh"
export PATH="/usr/local/sbin:$PATH"
export EDITOR='vim'

bindkey -e
eval "$(rbenv init -)"

ZSH_THEME=cobalt2
ZSH_CUSTOM=$HOME/dotfiles
ZSH_DISABLE_COMPFIX=true

HYPHEN_INSENSITIVE="true"
HIST_STAMPS="mm/dd/yyyy"

#SOURCE_FILES+=(~/dotfiles/aliases)
#for file in $SOURCE_FILES[@]; do
  #source "$file"
#done

plugins=(
  git
  z
  forgit # Add forgit to /.oh-my-zsh/plugins/
)

alias master='git co master && git pull origin master && git fetch'
alias integration='git co integration && git pull origin integration && git fetch'
alias amend='git commit --amend --no-edit'
alias push='git push -f origin HEAD'
alias gst="git status"
alias diff="git diff"
alias gco="git co"
alias gadd="git add ."
alias gcont="git rebase --continue"
alias gpush="git push origin head"
alias gpull="git pull origin --rebase"
alias ci="git ci -m "
alias grebase="git rebase -i origin/master"
alias migrate="bundle exec rake db:migrate"
alias tdev="tmux a -t dev"
alias tkill="killall tmux"

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

regex () {
  gawk 'match($0,/'$1'/, ary) {print ary['${2:-'0'}']}'
}

makepr() {
  if [ ! -d .git ] ;
    then echo "ERROR: This isnt a git directory" && return false;
  fi
  pwd | regex "tc-www" | grep "tc-www" | grep -v grep &> /dev/null
  in_tcw=$?
  pwd | regex "studio" | grep "studio" | grep -v grep &> /dev/null
  in_studio=$?
  pwd | regex "graph" | grep "graph" | grep -v grep &> /dev/null
  in_graph=$?
  if [[ $in_tcw == 0 ]] || [[ $in_studio == 0 ]] || [[ $in_graph == 0  ]]; then
    compare="/compare/integration...";
  else
    compare="/compare/master...";
  fi
  expand="?expand=1"
  branch=`git branch | grep \* | cut -d ' ' -f2-`
  github_url="https://github.com/frankNowinski"
  url=$github_url$(git_repo)$compare$branch$expand
  open $url
}

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
#if [[ -n $SSH_CONNECTION ]]; then
  #export TERM=xterm
#fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey ',m' fzf-file-widget

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
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

export PATH="$HOME/.rbenv/bin:$PATH"

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
