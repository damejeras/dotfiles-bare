# Assistant
function _assist() {
  output=$(echo -n "$@" | fabric -p shell_command)
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
    ZOXIDE_RESULT=$(zoxide query $1)
  fi

  if [ -z "$ZOXIDE_RESULT" ]; then
    return 0
  fi

  FOLDER=$(basename "$ZOXIDE_RESULT")
  SESSION_NAME="${FOLDER// /_}"
  SESSION_NAME="${SESSION_NAME//./_}"

  SESSION=$(tmux list-sessions 2> /dev/null | grep "$SESSION_NAME" | awk '{print $1}')
  SESSION="${SESSION//:/}"

  if [ -z "$TMUX" ]; then
    if [ -z "$SESSION" ]; then
      cd "$ZOXIDE_RESULT"
      tmux new-session -s "$SESSION_NAME"
    else
      tmux attach -t "$SESSION"
    fi
  else
    CURRENT_SESSION=$(tmux display-message -p '#S')
    if [ -z "$SESSION" ]; then
      cd "$ZOXIDE_RESULT"
      tmux new-session -d -s "$SESSION_NAME"
      tmux set-env -t "$SESSION_NAME" LAST_TMUX_SESSION "$CURRENT_SESSION"
      tmux switch-client -t "$SESSION_NAME"
    else
      tmux set-env -t "$SESSION" LAST_TMUX_SESSION "$CURRENT_SESSION"
      tmux switch-client -t "$SESSION"
    fi
  fi
}

# Install custom prompts
function _install_fabric_prompts() {
	mkdir -p ~/.config/fabric/patterns/
	cp -a ~/.prompts/* ~/.config/fabric/patterns/
}

# This is a hack to prevent adding functions to history.
alias assist=" _assist"
alias t=" _session"
