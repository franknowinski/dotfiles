alias lead="cd /Users/fnowinski/Projects/leads"
alias leads="cd /Users/fnowinski/Projects/leads"
alias slead="cd ~/Projects/leads; bundle exec rails s -p 4000"
alias adr="cd /Users/fnowinski/Projects/accredited-debt-relief"
alias sadr="cd ~/Projects/accredited-debt-relief; bundle exec rails s -p 3000"
alias glue="cd /Users/fnowinski/Projects/glue"
alias sglue="cd ~/Projects/glue; bundle exec rails s -p 6000"
alias bf="cd /Users/fnowinski/Projects/beyond-finance"
alias front="yarn build --mode=Projectselopment --Projectstool=eval-source-map --watch"

alias creds="bin/rails credentials:edit"
alias creds_test="rails credentials:edit --environment test"
alias creds_staging="rails credentials:edit --environment staging"
alias creds_prod="bin/rails credentials:edit --environment production"

alias swagger="bundle exec rake rswag:specs:swaggerize"
alias codeowner="codeownership validate"
alias compile="bundle exec rails assets:precompile"

# Removr PID when sql doesn't start
# Error: Failure while executing; homebrew.mxcl.postgresql@12.plist` exited with 5.
# rm /opt/homebrew/var/postgresql@12/postmaster.pid
# also try reinstalling postgresql@12
