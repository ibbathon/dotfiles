if [[ $HOST == "MBIT138.local" ]]; then
  COMPUTER="LegalShield"
else
  COMPUTER="$HOST"
fi

if [[ $COMPUTER == "LegalShield" ]]; then
  eval "$(rbenv init - --no-rehash)"

  # Setting PATH for Python 3.9
  PATH="/usr/local/opt/python@3.9/libexec/bin:${PATH}"
  export PATH
fi
