* Run two client(linux with tmux)
```
GODOT_PATH='<YOUR_GODOT_BIN_PATH>'
CLIENT_PATH='<YOUR_CLIENT_ROOT_PATH>'
CMD="$GODOT_PATH -path $CLIENT_PATH"

tmux new-session -d -s godot &&
tmux split-window -t godot:0

tmux send-keys -t godot:0.0 "$CMD" C-m
sleep 1
tmux send-keys -t godot:0.1 "$CMD" C-m

tmux attach -t godot
```
