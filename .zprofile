if [[ $HOST == "MBIT138.local" ]]; then
  COMPUTER="LegalShield"
else
  COMPUTER="$HOST"
fi

if [[ $COMPUTER == "LegalShield" ]]; then
  eval "$(rbenv init - --no-rehash)"

  # Setting PATH for Python 3.9
  PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin:${PATH}"
  export PATH
fi
