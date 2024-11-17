export SECONDARY_HISTORY_FILE="$HOME/.shell/command_log"
_log_command() {
    local cmd="$1"
    
	# Skip empty or whitespace-only commands
    [[ -z "${cmd// }" ]] && return 0

    # Remove trailing newline first
    cmd="${cmd%$'\n'}"
    
    # Convert continuation lines to single line
    cmd="${cmd//$'\\\n'/}"
    
    # Convert actual newlines to marker
    cmd="${cmd//$'\n'/↵}"
    
    # Now normalize the string by removing any $' sequences
    cmd="${cmd//$'\\'/'\\'}"
    
    if ! tail -n 20 "$SECONDARY_HISTORY_FILE" | cut -d' ' -f2- | grep -Fx -- "$cmd" >/dev/null 2>&1; then
        echo "$(date +%s) $cmd" >> "$SECONDARY_HISTORY_FILE"
    fi

    return 0
}

add-zsh-hook zshaddhistory _log_command
