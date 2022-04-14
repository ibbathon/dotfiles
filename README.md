# Ibb's dotfiles
Config files for my linux environments.

This is intended solely for my use, but you're welcome to use all or part of it for your own
setups.

## Setup Steps
1. Clone this repo.
1. Modify `setup.sh`, setting GITWORK to the parent directory of this repo.
    - `setup.sh` should then be located at `$GITWORK/dotfiles/setup.sh`
1. Run `setup.sh`.

## Additional Steps/Setup
### Disabling solaar's annoying "powered on" messages
https://github.com/pwr-Solaar/Solaar/issues/335#issuecomment-289785633

The moronic devs don't believe in options (fuck Gnome's ideology), so the only way to silence this nonsense is by editing the code directly. At line 141 in `/usr/lib/python3.9/site-packages/solaar/ui/notify.py`, edit it to look like
```
if reason != _('powered on'):
    n.show()
```
