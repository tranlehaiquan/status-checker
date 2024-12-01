#!/bin/bash

# ap-southeast-5
# ap-southeast-4
# ap-south-1
# ap-northeast-3
# ap-northeast-2
# ap-southeast-1
# ap-southeast-2
# ap-northeast-1

# List of regions
regions=("ap-southeast-1" "ap-southeast-2")

# Loop through each region and run terraform apply
for region in "${regions[@]}"; do
  echo "Deploying to region: $region"
  terraform apply -var="aws_regions=$region" -auto-approve
done