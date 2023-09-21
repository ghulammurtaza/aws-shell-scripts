#!/bin/bash

regions=("us-east-1" "us-west-1" "us-west-2" "eu-west-1" "eu-central-1" "ap-northeast-1" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "sa-east-1" "ca-central-1" "eu-north-1" "eu-south-1" "ap-east-1" "me-south-1")
output_csv="cloudwatch_log_groups_info.csv"

echo "Env,Service,Component,Region,Backup Responsible Company,Backup Enabled(Yes/No),Retention Policy,Rotation Scheme" > "$output_csv"

for region in "${regions[@]}"; do
  log_groups=$(aws logs describe-log-groups --query "logGroups[].logGroupName" --output text --region "$region")

  for log_group in $log_groups; do
    retention=$(aws logs describe-log-groups --query "logGroups[?logGroupName=='$log_group'].retentionInDays | [0]" --output text --region "$region")
    
    if [ "$retention" == "None" ]; then
      retention="Never expire"
    else
      retention="${retention} Days"
    fi
    
    echo "Int,cloudwatch-log-group,$log_group,$region,,,$retention,N/A" >> "$output_csv"
  done
done

echo "CloudWatch log group information saved to $output_csv"