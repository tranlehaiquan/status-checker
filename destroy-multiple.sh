#!/bin/bash

# List of regions
regions=("ap-southeast-1" "ap-southeast-2")

# asking for confirmation
read -p "Are you sure you want to destroy resources in all regions? (y/n): " confirm
if [[ $confirm != "y" ]]; then
  echo "Operation cancelled."
  exit 1
fi

# Loop through each region and run terraform apply
for region in "${regions[@]}"; do
  echo "Deploying to region: $region"
  terraform destroy -var="aws_regions=$region" -auto-approve
done