alias Z="fg"
alias al="ls -al"
alias aliases="chezmoi edit ~/.aliases.zsh"
alias cat="bat"
alias ctags="ctags --recurse=yes --exclude=.git --exclude=BUILD --exclude=.svn --exclude=db --exclude=node_modules --exclude=log --exclude=assets"
alias down="cd ~/Downloads"
alias ignore="n ~/.gitignore_global"
alias lss="ls -ltr"
alias xcon="chezmoi edit ~/bin/tmux-dev.sh" # Tmux script
alias rz="source ~/.zshrc"
alias tcon="chezmoi edit ~/.tmux.conf" # Tmux config
alias ncon="n ~/.config/nvim" # Nvim config
alias nchat="n ~/.config/nvim/lua/fnowinski/plugins/copilotchat.lua"
alias lsp="n ~/.config/nvim/lua/fnowinski/plugins/lsp/lspconfig.lua"
alias zcon="chezmoi edit ~/.zshrc" # Zsh config
alias gcon="chezmoi edit ~/.config/ghostty/config"
alias lg='lazygit'

# chezmoi: edit the source, then apply it to $HOME
alias dots="chezmoi cd"          # cd into ~/dotfiles
alias dapply="chezmoi apply -v"  # write the source files into $HOME
alias ddiff="chezmoi diff"       # what apply would change
alias dstatus="chezmoi status"   # short list of what's out of sync
alias dedit="chezmoi edit"       # dedit ~/.zshrc
alias dadd="chezmoi add"         # start tracking a file: dadd ~/.foo
alias dsave="chezmoi re-add"     # capture edits made directly in $HOME
alias dpull="chezmoi update -v"  # git pull + apply

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
alias sports="tmux a -t sports"
alias fuego="tmux a -t fuego"
alias tkill="killall -9 tmux"
alias reset="git co origin/main"
alias side="bundle exec sidekiq"
alias arubo='git diff --name-only --diff-filter=M | grep '\.rb$' | xargs rubocop'
alias rubo='bundle exec rubocop -a'
alias n="nvim"
alias cl="git co ."
alias ztime='time zsh -i -c exit'
alias pssh='fly ssh console "-C bundle exec rails c"'
alias when="whenever --update-crontab --set environment='development'"
alias cron="crontab -l"
alias pip='pip3'
alias pal="z pickup-pal"
alias half="z halfsies"
alias five="z fivepicks"
alias nlog="tail -f ~/.local/state/nvim/lsp.log"
alias fcon="fly ssh console"
alias fstart="fly machines start 1852d56c622708"

alias sonnet="claude --model sonnet"
alias ca="claude --model opus"
alias oc='ollama run qwen3-coder:30b'

# Tailscale CLI ships inside the app bundle
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
