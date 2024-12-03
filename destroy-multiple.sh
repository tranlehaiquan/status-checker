#!/bin/bash
# Loop through each region and run terraform apply
for region in "${regions[@]}"; do
  echo "Deploying to region: $region"
  terraform destroy -auto-approve
done