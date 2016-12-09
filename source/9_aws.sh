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
    echo "Invalid commit"
    return
  fi
  if [ -z "$branch" ]; then
    echo "Invalid branch"
    return
  fi
  if [ -z "$deployGroup" ]; then
    echo "Invalid deploy target group"
    return
  fi
  gitpu
  aws deploy create-deployment --application-name oberd --deployment-config-name CodeDeployDefault.OneAtATime --deployment-group-name $deployGroup --github-location repository=$repository,commitId=$commitId
}