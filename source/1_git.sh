
# Git shortcuts

alias g='git'
function ga() { git add "${@:-.}"; } # Add all files by default
alias gp='git push'
alias gpa='gp --all'
alias gu='git pull'
alias gl='git log'
alias gg='gl --decorate --oneline --graph --date-order --all'
alias gs='git status'
alias gst='gs'
alias gd='git diff --color | diff-so-fancy'
alias gdc='gd --cached'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gba='git branch -a'
function gc() { git checkout "${@:-master}"; } # Checkout master by default
alias gco='gc'
alias gcb='gc -b'
alias gr='git remote'
alias grv='gr -v'
#alias gra='git remote add'
alias grr='git remote rm'
alias gcl='git clone'
alias gcd='git rev-parse 2>/dev/null && cd "./$(git rev-parse --show-cdup)"'

# Current branch or SHA if detached.
alias gbs='git branch | perl -ne '"'"'/^\* (?:\(detached from (.*)\)|(.*))/ && print "$1$2"'"'"''

# Run commands in each subdirectory.
alias gu-all='eachdir git pull'
alias gp-all='eachdir git push'
alias gs-all='eachdir git status'

# Removes all local branches that
# have already been merged into master
# (will preview, with confirmation)
#
# Example:
#   $> clean_local
#   will delete hotfix/1.1.36c
#   Continue (y/n)? y
#   deleted hotfix/1.1.36c
#
function clean_local(){
  dead=`git branch --merged master | grep "^[^*]"`
  if [ -z "$1" ]; then
    for b in $dead; do
      if [ "$b" != "master" ]; then
        echo "will delete: $b"
      fi
    done
    read -p "Continue (y/n)? " choice
    case "$choice" in
      y|Y ) clean_local "yes";;
      * ) exit 0;;
    esac
  else
    for b in $dead; do
      if [ "$b" != "master" && "$b" != "develop" ]; then
        git branch -D $b
      fi
    done
  fi
}

# Removes all remote branches that
# have already been merged into master
# (will preview, with confirmation)
#
# Example:
#   $> clean_github
#   will delete hotfix/1.1.36c on github
#   Continue (y/n)? y
#   deleted hotfix/1.1.36c on github
#
function clean_github(){
  git remote prune origin
  merged=$(git branch -a --merged master | grep "remotes/origin" | cut -f3-100 -d'/')
  if [ -z "$1" ]; then
    for b in $merged; do
      if [[ "$b" != "master"  && "$b" != "develop" ]]; then
        echo "will delete $b on github"
      fi
    done
    read -p "Continue (y/n)? " choice
    case "$choice" in
      y|Y ) clean_github "yes";;
      * ) exit 0;;
    esac
  else
    for b in $merged; do
      if [[ "$b" != "master"  && "$b" != "develop" ]]; then
        git push origin :$b
        echo "deleted $b on github"
      fi
    done
  fi
}

# Update local branch with origin, checkout
# if necessary
#
# Parameters:
#   [branchname] (optional) name of branch to update
#
# Examples:
#   $ (release/1.1.36): gitup
#     -> will git pull release/1.1.36
#   $ (release/1.1.36): gitup develop
#     -> will checkout and pull develop
#
function gitup(){
  local branch_name=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
  git fetch origin
  if [ "$#" != "0" ]; then
    branch_name=$1
    git checkout $branch_name
  fi
  git pull origin $branch_name
}

# Push local branch to matching branch,
# without relying on remote tracking conf
#
# Examples:
#   $ (develop): gitpu
#     -> will update and push develop to origin
#
function gitpu(){
  local branch_name=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
  if [ "$#" != "0" ]; then
    branch_name=$1
    git checkout $branch_name
  fi
  gitup
  git push origin $branch_name
}
function stage(){
  local branch_name=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
  git push staging $branch_name
}
# open all changed files (that still actually exist) in the editor
function ged() {
  local files=()
  for f in $(git diff --name-only "$@"); do
    [[ -e "$f" ]] && files=("${files[@]}" "$f")
  done
  local n=${#files[@]}
  echo "Opening $n $([[ "$@" ]] || echo "modified ")file$([[ $n != 1 ]] && \
    echo s)${@:+ modified in }$@"
  q "${files[@]}"
}

# add a github remote by github username
function gra() {
  if (( "${#@}" != 1 )); then
    echo "Usage: gra githubuser"
    return 1;
  fi
  local repo=$(gr show -n origin | perl -ne '/Fetch URL: .*github\.com[:\/].*\/(.*)/ && print $1')
  gr add "$1" "git://github.com/$1/$repo"
}

# GitHub URL for current repo.
function gurl() {
  local remotename="${@:-origin}"
  local remote="$(git remote -v | awk '/^'"$remotename"'.*\(push\)$/ {print $2}')"
  [[ "$remote" ]] || return
  local user_repo="$(echo "$remote" | perl -pe 's/.*://;s/\.git$//')"
  echo "https://github.com/$user_repo"
}
# GitHub URL for current repo, including current branch + path.
alias gurlp='echo $(gurl)/tree/$(gbs)/$(git rev-parse --show-prefix)'

# git log with per-commit cmd-clickable GitHub URLs (iTerm)
function gf() {
  local remote="$(git remote -v | awk '/^origin.*\(push\)$/ {print $2}')"
  [[ "$remote" ]] || return
  local user_repo="$(echo "$remote" | perl -pe 's/.*://;s/\.git$//')"
  git log $* --name-status --color | awk "$(cat <<AWK
    /^.*commit [0-9a-f]{40}/ {sha=substr(\$2,1,7)}
    /^[MA]\t/ {printf "%s\thttps://github.com/$user_repo/blob/%s/%s\n", \$1, sha, \$2; next}
    /.*/ {print \$0}
AWK
  )" | less -F
}
# open last commit in GitHub, in the browser.
function gfu() {
  local n="${@:-1}"
  n=$((n-1))
  git web--browse  $(git log -n 1 --skip=$n --pretty=oneline | awk "{printf \"$(gurl)/commit/%s\", substr(\$1,1,7)}")
}
# open current branch + path in GitHub, in the browser.
alias gpu='git web--browse $(gurlp)'

# Just the last few commits, please!
for n in {1..5}; do alias gf$n="gf -n $n"; done

# OSX-specific Git shortcuts
if [[ "$OSTYPE" =~ ^darwin ]]; then
  alias gdk='git ksdiff'
  alias gdkc='gdk --cached'
  alias gt='gittower "$(git rev-parse --show-toplevel)"'
fi

# example: gitmerge develop fix/whatever
function gitmerge() {
  if [ "$#" -ne 2 ]; then
      echo "usage: gitmerge master hotfix/whatever"
      exit
  fi
  base=$1
  target=$2
  gitup $2
  gitup $1
  git merge $2
}


function get_pr_branch {
  number=$@
  for num in $number; do
    branch=$(curl -s -H "Authorization: token $GITHUB_OAUTH_TOKEN" https://api.github.com/repos/oberd/OBERD/pulls/$num | jq -r '.head.ref')
    echo "$num $branch"
  done
}

function create_oberd_release {
  gitup develop
  branches=$(get_pr_branch "$@" | awk '{print $2}')
  for branch in $branches; do
    echo "Updating $branch"
    gitup "$branch"
  done
  gitup develop
  echo "Merge Commands:"
  for branch in $branches; do
    echo "git merge $branch"
  done
}

function git_log_calendar {
  if [ "$#" -ne 1 ]; then
      echo "usage: git_log_calendar [base_branch]"
      return
  fi
  TMP_PATH=/tmp/git_log_calendar.html
  SOURCE_HEADER="$HOME/.dotfiles/libs/git_log_calendar/header.html"
  SOURCE_FOOTER="$HOME/.dotfiles/libs/git_log_calendar/footer.html"
  cat "$SOURCE_HEADER" > "$TMP_PATH"
  local branch_name=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
  local output=$(git log --pretty='format:{ "date":"%ad", "author":"%an" },' --date=short $branch_name ^$1 --no-merges --reverse)
  echo "<div id='git-base-branch' style='display:none;'>$base_branch</div>" >> "$TMP_PATH"
  echo "<div id='git-target-branch' style='display:none;'>$branch_name</div>" >> "$TMP_PATH"
  echo "<div id='git-output' style='display:none;'>$output</div>" >> "$TMP_PATH"
  cat "$SOURCE_FOOTER" >> "$TMP_PATH"
  echo "wkhtmltoimage --javascript-delay 5000 \"file://$TMP_PATH\" \"$HOME/Desktop/git_log_calendar.jpg\""
  wkhtmltoimage "file://$TMP_PATH" "$HOME/Desktop/git_log_calendar.jpg"
  open "$HOME/Desktop/git_log_calendar.jpg"
}

# Pass this pull request numbers and it will
# merge them to develop
function mergedev {
  if [ "$#" -eq 0 ]; then
    echo "usage: mergedev [pull request number] [pull request number]..."
    return
  fi
  pr_number=$@
  gitup develop
  for num in $pr_number; do
    branch=$(get_pr_branch $num | awk '{ print $2}')
    if [[ ! -z "$branch" ]]; then
      echo "Updating $branch"
      gitup $branch
      echo "Merging $branch to develop"
      gitup develop
      git merge "$branch"
      if [ ! $? -eq 0 ]; then
          echo "Error with branch $branch"
          break
      fi
    fi
  done
}

