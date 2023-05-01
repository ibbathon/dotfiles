export UNAME=$(uname)
if [[ $UNAME == "Darwin" ]]; then
  COMPUTER="StupidMac"
else
  COMPUTER="$HOST"
fi

if [[ $COMPUTER == "StupidMac" ]]; then
  # enable brew
  eval "$(/opt/homebrew/bin/brew shellenv)"
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
  [ -s "$NVM_SETUP_FILE" ] && \. "$NVM_SETUP_FILE"
  [ -s "$NVM_COMPL_FILE" ] && \. "$NVM_COMPL_FILE"
fi
