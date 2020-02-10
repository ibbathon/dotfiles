export EDITOR=vim

if [[ $HOST == "MBIT138.local" ]]; then
  COMPUTER="LegalShield"
else
  COMPUTER="$HOST"
fi

if [[ $COMPUTER == "LegalShield" ]]; then
  alias ls='ls -aG'
else
  alias ls='ls -a --color=auto'
fi
alias cp='cp -i'
alias mv='mv -i'

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


### Prompt setup
PROMPT="%F{red}%? %F{magenta}%~ %F{green}%#%f "
# Git info
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{yellow}%b %F{green}%c%F{red}%u%f'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr 'x'


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


### LegalShield-specific
if [[ $HOST == "LegalShield" ]]; then
  # Pathing for various languages/tools
  export PATH="$HOME/.bin:$PATH"
  eval "$(rbenv init - --no-rehash)"
  export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
  export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
  eval "$(nodenv init -)"

  ## Justin's docker shortcuts, wrapped to prevent overdefinition
  if [[ -z $DOCKER_SHORTCUTS_DEFINED ]]; then
    DOCKER_SHORTCUTS_DEFINED="yes"
  
    alias dc='docker-compose'
  
    dcgetcid() {
      echo $(docker-compose ps -q "$1")
    }
  
    dce(){
      CMD="${@:2}"
      docker exec -it $(dcgetcid $1) bash -c "stty cols $COLUMNS rows $LINES && bash -c \"$CMD\"";
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
  
    # Opens a bash console on a container: `dcb adonis`
    dcb() {
      dce "$1" /bin/bash
    }
  
    alias dce='noglob dce'
  fi
  
  
  ## My shortcuts for working within PPLSI
  
  # Shortcuts for accessing databases
  psql_dev() {
    psql -h localhost -U admin adonis_development
  }
  psql_test() {
    psql -h localhost -U admin adonis_test
  }
  
  # Fix delete key on Windows keyboard for iTerm2
  bindkey    "^[[3~"          delete-char
  bindkey    "^[3;5~"         delete-char
fi
