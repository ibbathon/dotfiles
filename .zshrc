export EDITOR=nvim

export UNAME=$(uname)
if [[ $UNAME == "Darwin" ]]; then
  COMPUTER="VaultHealth"
else
  COMPUTER="$HOST"
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
if [[ $COMPUTER == "VaultHealth" ]]; then
  alias ls='ls -aG'
else
  alias ls='ls -a --color=auto'
fi
alias cp='cp -i'
alias mv='mv -i'
alias vi=vim
alias vim=nvim

# Background-setting aliases so I can quickly switch to black for streaming
if [[ $COMPUTER == "Archiater" ]]; then
  alias hsetroot_stream='hsetroot -solid black'
  alias hsetroot_normal='hsetroot -full backgrounds/1352085388.jayaxer_all_business_by_jayaxer.jpg'
fi

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
PROMPT="%F{red}%? %F{magenta}%~ %F{green}%#%f "
# Git info
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
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
# Justin's docker shortcuts, wrapped to prevent overdefinition
if [[ -z $DOCKER_SHORTCUTS_DEFINED ]]; then
  DOCKER_SHORTCUTS_DEFINED="yes"

  alias dc='docker-compose'
  alias dcd='docker-compose -f docker-compose-dev.yml'

  dcgetcid() {
    echo $(docker-compose ps -q "$1")
  }

  dce() {
    CMD="${@:2}"
    docker-compose exec $1 sh -c "stty cols $COLUMNS rows $LINES && sh -c \"$CMD\"";
  }

  # Opens a sh console on a container: `dcb backend`
  dcb() {
    dce "$1" /bin/sh
  }

  # Watch the logs for all the running containers: `dcl`
  # Watch the logs for a single container: `dcl adonis`
  # optional tail if you want more than 25 lines: `dcl adonis 100`
  dcl() {
    TAIL=${2:-25}
    docker-compose logs -f --tail="$TAIL" $1
  }

  # Attach your terminal to a container.
  # If you have binding.pry in your code and browse the site
  # then run `dca adonis` in a terminal to be able to type into Pry
  dca() {
    docker attach $(dcgetcid "$1")
  }
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

if ls ~/.nvm/nvm.sh &> /dev/null; then
  export NVM_DIR="$HOME/.nvm"
  # Standard loader that autoloads from current directory
  # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  # Alternate NVM loader that hard-codes to a single version
  export PATH=~/.nvm/versions/node/v12.22.3/bin:$PATH
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use
fi


### VaultHealth-specific code
if [[ $COMPUTER == "VaultHealth" ]]; then
  export AWS_PROFILE="vlt"
  function aws_docker_login {
    aws-google-auth $@
    aws ecr get-login-password $@ | \
      docker login --username AWS --password-stdin \
      291140025886.dkr.ecr.us-east-2.amazonaws.com
  }
  function aws_google_auth_creds {
    AUTHOUT="$(aws-google-auth $@ --print-creds 1>&1 1>&2)"
    if [ $? -eq 0 ]; then
      $(echo "$AUTHOUT"|tail -n 1)
    fi
  }
  alias dc="docker-compose"
  alias dcd="docker-compose -f docker-compose-dev.yml"
  alias dcd-build="dcd build api admin-api lambda"

  # pull in GH PAT
  export GITHUB_PACKAGES_TOKEN=`cat $HOME/.ssh/gh_pat`


  #!!! These two are automatically added by terraform and so shouldn't
  # be in the README.
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/local/bin/terraform terraform


  alias ngrok-admin-api="ngrok http 127.0.0.1:5000"
  alias ngrok-api="ngrok http 127.0.0.1:5001"
  alias setup-stage-api="export FLASK_APP=application.py FLASK_ENV=development RX_CONFIG=stage.StageConfig RETOOL_AUTH_HEADER=123"
  alias setup-stage-admin-api="export FLASK_APP=admin-application.py FLASK_ENV=development RX_CONFIG=stage.StageConfig RETOOL_AUTH_HEADER=123"
fi
