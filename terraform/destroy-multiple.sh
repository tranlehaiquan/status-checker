#!/bin/bash

# List of regions
regions=("ap-southeast-1" "ap-southeast-2")

# Loop through each region and run terraform apply
for region in "${regions[@]}"; do
  echo "Deploying to region: $region"
  terraform destroy -var="aws_regions=$region" -auto-approve
done