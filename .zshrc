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

source $ZSH/oh-my-zsh.sh

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export TERM=xterm
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey ',m' fzf-file-widget

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_COMMAND='fd --type d . --color=never'
export FZF_DEFAULT_OPTS='
  --height 75% --multi --reverse
  --bind ctrl-f:page-down,ctrl-b:page-up
  --bind ctrl-p:abort
  --color=fg:-1,bg:-1,hl:#5fd7ff
  --color=fg+:-1,bg+:-1,hl+:#79e7fa
  --color=info:#87ff00,prompt:#ff76ff,pointer:#ff76ff
  --color=marker:#87ff00,spinner:#00c5c7,header:#00c5c7
'

export PATH="$HOME/.rbenv/bin:$PATH"

# Find in file
fif() {
    if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
    local file
    file="$(rga --max-count=1 --ignore-case --files-with-matches --no-messages "$@" | fzf-tmux +m --preview="rga --ignore-case --pretty --context 10 '"$@"' {}")" && open "$file"
}

# Opening a file in vim
fe() (
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files"  ]] && ${EDITOR:-vim} "${files[@]}"
)

# Checkout branch
fco() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# Checkout branch with preview
fco_preview() {
  local tags branches target
  branches=$(
    git --no-pager branch --all \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  tags=$(
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  target=$(
    (echo "$branches"; echo "$tags") |
    fzf --no-hscroll --no-multi -n 2 \
        --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'") || return
  git checkout $(awk '{print $2}' <<<"$target" )
}

# Cd down into dir
function cd() {
  if [[ "$#" != 0 ]]; then
    builtin cd "$@";
    return
  fi
  while true; do
    local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
    local dir="$(printf '%s\n' "${lsd[@]}" |
      fzf --reverse --preview '
          __cd_nxt="$(echo {})";
          __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
          echo $__cd_path;
          echo;
          ls -p --color=always "${__cd_path}";
          ')"
          [[ ${#dir} != 0 ]] || return 0
          builtin cd "$dir" &> /dev/null
        done
}
