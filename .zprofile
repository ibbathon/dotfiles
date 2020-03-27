if [[ $HOST == "MBIT138.local" ]]; then
  COMPUTER="LegalShield"
else
  COMPUTER="$HOST"
fi

if [[ $COMPUTER == "LegalShield" ]]; then
  eval "$(rbenv init - --no-rehash)"
fi
