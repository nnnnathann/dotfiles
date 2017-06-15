function gitup_aws(){
  local branch_name=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
  git fetch origin
  if [ "$#" != "0" ]; then
    branch_name=$1
    git checkout $branch_name
  fi
  git pull origin $branch_name
}
function gitpu_aws(){
  local branch_name=`git rev-parse --symbolic-full-name --abbrev-ref HEAD`
  if [ "$#" != "0" ]; then
    branch_name=$1
    git checkout $branch_name
  fi
  gitup_aws
  git push origin $branch_name
}
# Usage:
# 
# Inside of a git project, use this script to deploy to AWS CodeDeploy.
# 
# aws-push [deploy-group] [repository] [application-name]
# 
function aws-push {
  branch="$(git rev-parse --abbrev-ref HEAD)"
  commitId="$(git rev-parse HEAD)"
  deployGroup=${1:-medamine2}
  repository=${2:-oberd/oberd}
  app=${3:-oberd}
  if [ -z "$commitId" ]; then
    echo "Invalid commit, are you in OBERD directory?"
    return
  fi
  if [ -z "$branch" ]; then
    echo "Invalid branch, are you in OBERD directory?"
    return
  fi
  if [ -z "$deployGroup" ]; then
    echo "Invalid deploy target group"
    return
  fi
  gitpu_aws
  aws deploy create-deployment --application-name $app --deployment-config-name CodeDeployDefault.OneAtATime --deployment-group-name $deployGroup --github-location repository=$repository,commitId=$commitId
}

function aws-medamine-deploy-current-commit {
  aws-push medamine2
}

function aws-qa-deploy-current-commit {
  aws-push qa
}

function aws-mips-deploy-current-commit {
  aws-push mips
}

# Usage:
# upload_oberd_file [autoscale-group] [oberd_relative_filepath]

# Example:
# upload_oberd_file medamine-autoscale business/Session.php

# Will upload a file to all the servers currently in the
# medamine-autoscale groupName in AWS

# Group names for Oberd deploys:

# medamine2 = medamine-autoscale
# qa = oberd-qa-autoscale
# 
function aws_upload_oberd_file {

read -r -d '' USAGE << EOF

Usage:
upload_oberd_file [autoscale-group] [oberd_relative_filepath]

Example:
upload_oberd_file medamine-autoscale business/Session.php

Will upload a file to all the servers currently in the
medamine-autoscale groupName in AWS

Group names for Oberd deploys:

medamine2 = medamine-autoscale
qa = oberd-qa-autoscale
mips = oberd-mips-20170602

EOF

  servers=$(aws ec2 describe-instances \
  --region us-west-2 \
  --filters "Name=tag:aws:autoscaling:groupName,Values=$1" \
  --query 'Reservations[].Instances[].PublicDnsName' \
  --output text)

  file="$OBERD_DIR/$2"

  if [ -z "$servers" ]; then
    echo "No servers found"
    echo "$USAGE"
    return
  fi

  if [ ! -f "$file" ]; then
    echo "File '$file' does not exist"
    echo "$USAGE"
    return
  fi

  for server in $servers; do
    echo "Will copy $file to $server:/var/www/oberd/$2"
  done

  read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    for server in $servers; do
      scp -i ~/.ssh/oberd.pem "$file" "ec2-user@$server:/var/www/oberd/$2"
    done
  fi
  echo "Copied files successfully."
}