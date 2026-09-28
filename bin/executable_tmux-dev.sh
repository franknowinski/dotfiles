tmux new-session -s dev -n servers -d
tmux new-window -n five -t dev
tmux new-window -n kritic -t dev
tmux new-window -n hedge -t dev
tmux new-window -n nvim -t dev

tmux send-keys -t dev:1.0 'cd ~/Projects/' C-m
tmux send-keys -t dev:2.0 'cd ~/Projects/fivepicks' C-m
tmux send-keys -t dev:3.0 'cd ~/Projects/kritic' C-m
tmux send-keys -t dev:4.0 'cd ~/Projects/hedgehog' C-m
tmux send-keys -t dev:5.0 'cd ~/Projects/' C-m

tmux select-window -t dev:1
tmux attach -t dev
