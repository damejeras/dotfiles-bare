# Assistant
function _assist() {
  output=$(echo -n "$@" | fabric --pattern shell_command)
  echo "$output"
  vared -p "Do you want to evaluate the command? (y/n) " -c choice
  if [[ $choice == y ]]; then
    eval "$output"
  fi
  print -s "$output"  # Add the command to history
}

# Tmux sessionizer
function _session() {
    if [ $# -eq 0 ]; then
        if [ -z "$TMUX" ]; then
            ZOXIDE_RESULT=$(zoxide query -l | fzf --reverse)
        else
            ZOXIDE_RESULT=$(zoxide query -l | fzf-tmux -p --reverse)
        fi
    else
        # Check if session exists first
        SESSION_NAME="${1//[.]/_}"
        SESSION=$(tmux list-sessions 2> /dev/null | awk -v name="$SESSION_NAME" '$1 ~ "^"name":" {print $1}')
        SESSION="${SESSION//:/}"
        
        if [ -n "$SESSION" ]; then
            if [ -z "$TMUX" ]; then
                tmux attach -t "$SESSION"
            else
                tmux switch-client -t "$SESSION"
            fi
            return 0
        fi
        
        # Create new session directory and initialize
        SESSION_PATH="$HOME/Sessions/$1"
        mkdir -p "$SESSION_PATH"
        ZOXIDE_RESULT="$SESSION_PATH"
    fi

    if [ -z "$ZOXIDE_RESULT" ]; then
        return 0
    fi

    SESSION_PATH="$ZOXIDE_RESULT"
    SESSION_NAME="${SESSION_PATH##*/}"
    TMUX_SESSION_NAME="${SESSION_NAME//[.]/_}"

    SESSION=$(tmux list-sessions 2> /dev/null | awk -v name="$TMUX_SESSION_NAME" '$1 ~ "^"name":" {print $1}')
    SESSION="${SESSION//:/}"

    if [ -z "$TMUX" ]; then
        if [ -z "$SESSION" ]; then
            tmux new-session -s "$TMUX_SESSION_NAME" -c "$SESSION_PATH"
        else
            tmux attach -t "$SESSION"
        fi
    else
        if [ -z "$SESSION" ]; then
            tmux new-session -d -s "$TMUX_SESSION_NAME" -c "$SESSION_PATH"
            tmux switch-client -t "$TMUX_SESSION_NAME"
        else
            tmux switch-client -t "$SESSION"
        fi
    fi
}

# Load history
function _shared_history() {
    local time=${1:-1h}
    local limit=${2:-100}
    local selected=$(logcli query '{service_name="zsh"}' --since=$time --limit=$limit --addr=$HISTORY_LOKI_HOST --username=$HISTORY_LOKI_USERNAME --password=$HISTORY_LOKI_PASSWORD --output raw 2>/dev/null | tr '\n' '\0' | sed 's/↵/\n/g' | fzf --read0)
    [[ -n "$selected" ]] && print -z "$selected"
}

# Install custom prompts
function _install_fabric_prompts() {
	mkdir -p ~/.config/fabric/patterns/
	cp -a ~/.prompts/* ~/.config/fabric/patterns/
}

# Load promtail
function _load_promtail {
	launchctl unload $HOME/Library/LaunchAgents/promtail.plist
	envsubst < $HOME/.shell/promtail/promtail.template.plist > $HOME/.shell/promtail/promtail.plist
	envsubst < $HOME/.shell/promtail/config.template.yaml > $HOME/.shell/promtail/config.yaml
	cp $HOME/.shell/promtail/promtail.plist $HOME/Library/LaunchAgents/promtail.plist
	launchctl load $HOME/Library/LaunchAgents/promtail.plist
}

# This is a hack to prevent adding functions to history.
alias assist=" _assist"
alias t=" _session"
alias h=" _shared_history"
