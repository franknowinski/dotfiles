tmux new-session -s dev -n servers -d
tmux new-window -n vim -t dev
tmux new-window -n console -t dev

tmux send-keys -t dev:1.0 'cd ~/dev/' C-m
tmux send-keys -t dev:2.0 'cd ~/dev/' C-m
tmux send-keys -t dev:3.0 'cd ~/dev/' C-m

tmux select-window -t dev:1
tmux attach -t dev
