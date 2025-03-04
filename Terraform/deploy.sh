#!/bin/bash

launch_terraform(){
  terraform init
  terraform plan
  terraform apply -auto-approve
}

TEST_START=$(date '+%m/%d/%Y %H:%M:%S')

pushd ./fixvid-modules/instance/certs || exit
ssh-keygen -C deployer -f deployer
popd  || exit

pushd ./fixvid-servers/ || exit
launch_terraform
popd || exit

pushd ./fixvid-devops-docker/ || exit
launch_terraform
popd || exit

CURRENT_TIME=$(date '+%m/%d/%Y %H:%M:%S')
START_IN_SECONDS=$(date --date "$TEST_START" +%s)
CURRENT_IN_SECONDS=$(date --date "$CURRENT_TIME" +%s)
diff=$((CURRENT_IN_SECONDS - START_IN_SECONDS))
echo "Took $(date +%H:%M:%S -ud @${diff})"
