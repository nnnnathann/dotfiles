# Add binaries into the path
export GOPATH=$HOME/development/golang
PATH=~/.dotfiles/bin:$PATH
PATH=$HOME/development/tools/android-sdk-macosx/tools:$PATH
PATH=$HOME/development/tools/android-sdk-macosx/platform-tools:$PATH
PATH=$PATH:$GOPATH/bin
export PATH
# Source all files in ~/.dotfiles/source/
function src() {
  local file
  if [[ "$1" ]]; then
    source "$HOME/.dotfiles/source/$1.sh"
  else
    for file in ~/.dotfiles/source/*; do
      source "$file"
    done
  fi
}

if [ ! -f ~/.env.local ]; then
	function e_bold()   { echo -e "\n\033[1m$@\033[0m"; }
	echo ""
	e_bold "Please copy ~/.dotfiles/.env.local.default to ~/.env.local and customize."
	echo ""
else
  boot2docker up -m 4096 > /dev/null 2>&1
  $(boot2docker shellinit | grep "export") > /dev/null 2>&1
	source ~/.env.local
  src
fi
