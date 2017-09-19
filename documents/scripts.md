#### Linux Shell script with tmux
* Run two client
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

* Run Servers without Gradle(gradle build success and only local modify)
```
tmux new-session -d -s servers

tmux new-window -t servers:1

tmux rename-window -t servers:0 'game'
tmux rename-window -t servers:1 'lobby'

GOPATH='<YOUR_SERVER_ROOT_PATH>/.gogradle/project_gopath'

tmux send-keys -t servers:game "export GOPATH=$GOPATH" C-m
tmux send-keys -t servers:lobby "export GOPATH=$GOPATH" C-m

tmux send-keys -t servers:game 'go build -o bin/darwin_amd64_game -i servers/game' C-m
tmux send-keys -t servers:game 'bin/darwin_amd64_game -stderrthreshold=INFO' C-m

tmux send-keys -t servers:lobby 'go build -o bin/darwin_amd64_lobby -i servers/lobby' C-m
tmux send-keys -t servers:lobby 'bin/darwin_amd64_lobby' C-m

tmux attach -t servers:game
```
