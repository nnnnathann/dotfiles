#!/bin/bash


# Z Jump Script

# Fast directory switching
export _Z_NO_PROMPT_COMMAND=1
export _Z_DATA=~/.dotfiles/caches/.z
. ~/.dotfiles/libs/z/z.sh
source ~/.dotfiles/libs/git_completion/git_completion.bash

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi