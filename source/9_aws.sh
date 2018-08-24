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
  deploy_config=${4:-CodeDeployDefault.OneAtATime}
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
  deploy_id=$(aws deploy create-deployment --application-name $app --deployment-config-name $deploy_config --deployment-group-name $deployGroup --github-location repository=$repository,commitId=$commitId)
  echo "Check status: https://us-west-2.console.aws.amazon.com/codedeploy/home?region=us-west-2#/deployments/$deploy_id"
  open "https://us-west-2.console.aws.amazon.com/codedeploy/home?region=us-west-2#/deployments/$deploy_id"
}

function aws-push-emergency {
  aws-push $1 $2 $3 $4
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

function aws-production-deploy-current-commit {
  aws-push production
}

function aws-production-deploy-current-commit {
  aws-push-emergency production
}

function aws-production-crons-deploy-current-commit {
  aws-push production-crons
}

function aws-mips-production-deploy-current-commit {
  aws-push production-mips
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

# Usage:
# aws_run_command [autoscale-group] [command]

# Example:
# aws_run_command medamine-autoscale ls /tmp/mips_cron

# Will list out commands to run

# Group names for Oberd deploys:

# medamine2 = medamine-autoscale
# qa = oberd-qa-autoscale
# mips = oberd-mips-20170602
#
function aws_run_command {

read -r -d '' USAGE << EOF

Usage:
aws_run_command [autoscale-group] [oberd_relative_filepath]

Example:
aws_run_command medamine-autoscale ls /tmp/mips_cron

Will list out commands to run

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
  shift
  command="$@"

  if [ -z "$servers" ]; then
    echo "No servers found"
    echo "$USAGE"
    return
  fi

  for server in $servers; do
    echo "ssh -i ~/.ssh/oberd.pem ec2-user@$server '$command'"
  done

  read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    for server in $servers; do
      ssh -i ~/.ssh/oberd.pem ec2-user@$server '$command'
    done
  fi
}

function aws_autoscale_cp {

read -r -d '' USAGE << EOF

Usage:
aws_autoscale_cp [autoscale-group] /path/to/local/file /path/to/remote/file

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

  file="$2"

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

  if [ -z "$3" ]; then
    echo "Please specify a server path"
    echo "$USAGE"
    return
  fi

  for server in $servers; do
    echo "Will copy $file to $server:$3"
  done

  read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    for server in $servers; do
      scp -i ~/.ssh/oberd.pem "$file" "ec2-user@$server:$3"
    done
  fi
  echo "Copied files successfully."
}


function reset-mips-cron-prod {
  servers=$(aws ec2 describe-instances \
  --region us-west-2 \
  --filters "Name=tag:aws:autoscaling:groupName,Values=oberd-mips-prod" \
  --query 'Reservations[].Instances[].PublicDnsName' \
  --output text)
  shift
  if [ -z "$servers" ]; then
    echo "No servers found"
    echo "$USAGE"
    return
  fi
  for server in $servers; do
    read -p "Run ssh -i ~/.ssh/oberd.pem ec2-user@$server 'echo \"\" > /tmp/mips_cron' ? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        ssh -i ~/.ssh/oberd.pem ec2-user@$server 'echo "" > /tmp/mips_cron'
    fi
  done
}

function reset-mips-cron {
  servers=$(aws ec2 describe-instances \
  --region us-west-2 \
  --filters "Name=tag:aws:autoscaling:groupName,Values=oberd-mips-20170602" \
  --query 'Reservations[].Instances[].PublicDnsName' \
  --output text)
  shift
  if [ -z "$servers" ]; then
    echo "No servers found"
    echo "$USAGE"
    return
  fi
  for server in $servers; do
    read -p "Run ssh -i ~/.ssh/oberd.pem ec2-user@$server 'echo \"\" > /tmp/mips_cron' ? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        ssh -i ~/.ssh/oberd.pem ec2-user@$server 'echo "" > /tmp/mips_cron'
    fi
  done
}

function aws_connect {
  ssh -i ~/.ssh/oberd.pem ec2-user@"$@"
}

function aws-scale-mips-prod {
  if [ -z $1 ]; then
    aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "oberd-mips-prod" | grep InService | wc -l | tr -d '[:space:]'
    return
  fi
  size=${1:-3}
  aws autoscaling update-auto-scaling-group --auto-scaling-group-name "oberd-mips-prod" --min-size $size --max-size $size --desired-capacity $size
}

function aws_upload_oberd_changes {
  for f in $(git diff --name-only); do
    aws_upload_oberd_file "$@" $f
  done
}

function awsmm_last_deploy {
	deploy_id=$(aws deploy list-deployments --application-name oberd --deployment-group medamine2 --max-items 1 | grep DEPLOYMENTS | awk '{ print $2}')
	echo "Check status: https://us-west-2.console.aws.amazon.com/codedeploy/home?region=us-west-2#/deployments/$deploy_id"
}
