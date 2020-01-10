#!/bin/zsh

GITWORK=~/gitwork

# Clone the tmux conf repo
cd $GITWORK
[ -d .tmux ] || git clone https://github.com/gpakosz/.tmux

# Create necessary directories
mkdir -p ~/.config/qtile

# Link config files
DOTBASE=$GITWORK/dotfiles
STANDARD_DOTFILES=(
  ".config/qtile/config.py"
  ".inputrc"
  ".tmux.conf.local"
  ".vimrc"
  ".xprofile"
  ".Xresources"
  ".zshrc"
)
for f in $STANDARD_DOTFILES; do
  ln -sf $DOTBASE/$f ~/$f
done

ln -sf $GITWORK/.tmux/.tmux.conf ~/.tmux.conf
