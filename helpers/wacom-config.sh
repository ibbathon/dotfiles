#!/bin/sh

# wait for tablet to become available
for i in $(seq 10); do
  if xsetwacom list devices | grep -q "HID 256c"; then
    break
  fi
  sleep 1
done

xsetwacom set 'HID 256c:006d stylus' MapToOutput HEAD-1
