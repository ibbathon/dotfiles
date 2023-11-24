zmodload zsh/zprof

export EDITOR=nvim

export UNAME=$(uname)
if [[ $UNAME == "Darwin" ]]; then
  COMPUTER="StupidMac"
else
  COMPUTER="$HOST"
fi

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  IS_SSH="true"
fi

# Case-insensitive tab-completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# Fix colors for OTHER_WRITABLE
export LS_COLORS="ow=37;42"

# Keep history between sessions
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=5000
setopt appendhistory
setopt sharehistory
setopt incappendhistory


### Aliases
if [[ $COMPUTER == "StupidMac" ]]; then
  alias ls='ls -aG'
else
  alias ls='ls -a --color=auto'
fi
alias cp='cp -i'
alias mv='mv -i'
alias vi=vim
alias vim=nvim
alias docker='sudo docker'

# Alias for shutting down proton games, because it refuses to do so gracefully
function ShutDownProtonGame() {
  pkill -9 -f "steamapp"
  pkill -9 -f "C:"
  pkill -9 -f "wine"
  pkill -9 -f "explorer"
  pkill -9 -f "Disgaea"
}
alias proton_shutdown=ShutDownProtonGame


### Prompt setup
if [ -n "$IS_SSH" ]; then
  EXTRA_PROMPT="%F{blue}%m "
fi
check_kubeconfig() {
  if [ -n "$KUBECONFIG" ]; then
    KUBE_MACHINE=`echo $KUBECONFIG|sed "s/.*\/\([^\/]*\)\.yaml/\1/"`
    KUBE_PROMPT="%F{yellow}k8s:${KUBE_MACHINE} "
  else
    unset KUBE_PROMPT
  fi
}
PROMPT='${EXTRA_PROMPT}${KUBE_PROMPT}%F{red}%? %F{magenta}%~ %F{green}%#%f '
# Git info
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info check_kubeconfig )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{yellow}%b %F{green}%c%F{red}%u%F{cyan}%m%f'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr 'x'

# Allow checking for untracked files
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
     git status --porcelain | grep -m 1 '^??' &>/dev/null
  then
    hook_com[misc]='?'
  fi
}


### Python setup
# Local Python exes
export PATH=$PATH:~/.local/bin
# Prefer IPython when executing `python`
export PYTHONSTARTUP=${HOME}/helpers/ipython_startup.py


### Mac-specific setup
if [[ $COMPUTER == "StupidMac" ]]; then
  # use the far-superior GNU versions of grep
  export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
  # enable brew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  ### NEA-specific setup
  #DB_PASSWORD=$(kubectl get secret --namespace optos-framework optos-db-credentials -o jsonpath="{.data.PATRONI_SUPERUSER_PASSWORD}" | base64 --decode)
  #export OPTOS_DB_URL=postgresql://postgres:${DB_PASSWORD}@127.0.0.1:30432
  export PANTS_CONCURRENT=true
fi


### Key setup
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  history-beginning-search-forward
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# allow reverse-incremental search
bindkey '^R' history-incremental-search-backward

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start {
		echoti smkx
	}
	function zle_application_mode_stop {
		echoti rmkx
	}
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi


### Docker aliases
# wrapped to prevent overdefinition
if [[ -z $DOCKER_SHORTCUTS_DEFINED ]]; then
  DOCKER_SHORTCUTS_DEFINED="yes"

  alias dc='docker compose'
  alias dcd='docker compose -f docker-compose-dev.yml'
fi


### Env Managers
if command -v nodenv &> /dev/null; then
  export PATH="$PATH:$HOME/.nodenv/bin"
  eval "$(nodenv init -)"
fi

if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

if command -v pyenv &> /dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  # pyenv github says to use /bin, but my version is installing in
  # /shims. Make sure to check your .pyenv dir for the correct one.
  export PATH=$PYENV_ROOT/shims:$PATH
  eval "$(pyenv init -)"
fi

# Fucking pants
export PATH=$PATH:~/bin

# only do nvm if we haven't already initialized
if ! command -v nvm &> /dev/null; then
  NVM_SETUP_FILE="$HOME/.nvm/nvm.sh"
  NVM_COMPL_FILE="$HOME/.nvm/bash_completion"
  if ls /opt/homebrew/opt/nvm/nvm.sh &> /dev/null; then
    NVM_SETUP_FILE="/opt/homebrew/opt/nvm/nvm.sh"
    NVM_COMPL_FILE="/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  fi
  export NVM_DIR="$HOME/.nvm"
  # Standard loader that autoloads from current directory
  # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  # Alternate NVM loader that hard-codes to a single version
  # export PATH=~/.nvm/versions/node/v16.18.0/bin:$PATH
  # [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use
  if [ -f "$NVM_SETUP_FILE" ]; then source "$NVM_SETUP_FILE"; fi
  if [ -f "$NVM_COMPL_FILE" ]; then source "$NVM_COMPL_FILE"; fi
fi

# zprof
