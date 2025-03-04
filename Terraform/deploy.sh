#!/bin/bash

launch_terraform(){
  terraform init
  terraform plan
  terraform apply -auto-approve
}

TEST_START=$(date '+%m/%d/%Y %H:%M:%S')

pushd ./fixvid-servers/
launch_terraform
popd

pushd ./fixvid-devops-docker/
launch_terraform
popd

CURRENT_TIME=$(date '+%m/%d/%Y %H:%M:%S')
START_IN_SECONDS=$(date --date "$TEST_START" +%s)
CURRENT_IN_SECONDS=$(date --date "$CURRENT_TIME" +%s)
diff=$((CURRENT_IN_SECONDS - START_IN_SECONDS))
echo "Took $(date +%H:%M:%S -ud @${diff})"
