alias Z="fg"
alias al="ls -al"
alias aliases="n ~/dotfiles/aliases.zsh"
alias cat="bat"
alias ctags="ctags --recurse=yes --exclude=.git --exclude=BUILD --exclude=.svn --exclude=db --exclude=node_modules --exclude=log --exclude=assets"
alias down="cd ~/Downloads"
alias ignore="n ~/.gitignore"
alias lss="ls -ltr"
alias xcon="n ~/tmux-dev.sh" # Tmux script
alias rz="source ~/.zshrc"
alias ssh='TERM=xterm-256color ssh'
alias tcon="n ~/dotfiles/.tmux.conf" # Tmux config
alias vcon="n ~/dotfiles/.vimrc" # Vim config
alias ncon="n ~/.config/nvim" # Nvim config
alias work="n ~/dotfiles/work.zsh"
alias zcon="n ~/dotfiles/.zshrc" # Zsh config
alias dotfiles"n ~/dotfiles"
alias mkscript="n ~/.path_scripts/makepr"
alias mkstart="n ~/.path_scripts/start"
alias scripts="cd ~/.path_scripts"
alias lg='lazygit'

alias amend='git commit --amend --no-edit'
alias be="bundle exec"
alias ci="git ci -m "
alias diff="git diff"
alias gadd="git add ."
alias rcont="git add .; git rebase --continue"
alias gco="git co"
alias gcont="git rebase --continue"
alias glist='git stash list'
alias gpop='git stash pop'
alias gstash='git stash save'
alias gclear='git stash clear'
alias gpull="git pull origin --rebase"
alias gpush="git push origin head"
alias grebase="git rebase -i origin/main"
alias gst="git status"
alias main='git co main && git pull origin main && git fetch'
alias migrate="bundle exec rake db:migrate"
alias tmigrate="bin/rails db:migrate RAILS_ENV=test"
alias push='git push -f origin HEAD'
alias rc="bundle exec rails c"
alias rs="bundle exec rails s"
alias rspec='be rspec'
alias tdev="tmux a -t dev"
alias tkill="killall tmux"
alias reset="git co origin/main"
alias side="bundle exec sidekiq"
alias arubo='git diff --name-only --diff-filter=M | grep '\.rb$' | xargs rubocop'
alias rubo='bundle exec rubocop -a'
alias n="nvim"
alias cl="git co ."
alias ztime='time zsh -i -c exit'
alias wcon='n ~/.wezterm.lua'
