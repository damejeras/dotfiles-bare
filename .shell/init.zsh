# Make sure Homebrew is available.
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not in PATH."
    return 1
fi

# Install the necessary tools.
if ! command -v fzf &>/dev/null || ! command -v zoxide &>/dev/null; then
	brew bundle --file $HOME/.shell/Brewfile
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Ensure zinit is installed.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Ensure Powerlevel10k is installed.
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Install other plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light olets/zsh-window-title

# Keybindings
bindkey -e # Emacs mode
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History settings
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Load completions
autoload -U compinit && compinit
zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Source secrets
source $HOME/.shell/secrets.zsh

# Source history
source $HOME/.shell/history.zsh

# Source aliases
source $HOME/.shell/aliases.zsh

# Source functions
source $HOME/.shell/functions.zsh

# Enable shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Load p10k
[[ ! -f $HOME/.shell/p10k.zsh ]] || source $HOME/.shell/p10k.zsh

