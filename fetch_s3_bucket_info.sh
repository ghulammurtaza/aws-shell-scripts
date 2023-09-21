#!/bin/bash

output_csv="s3_bucket_info.csv"
echo "Env,Service,Component,Category,Region,Backup Responsible Company,Backup Enabled(Yes/No),Retention Policy,Rotation Scheme" > "$output_csv"

buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

for bucket in $buckets; do
  region=$(aws s3api get-bucket-location --bucket "$bucket" --query "LocationConstraint" --output text)
  
  
  if [ -z "$region" ] || [ "$region" == "eu-central-1" ]; then
    region="eu-central-1"
  fi

  versioning_status=$(aws s3api get-bucket-versioning --bucket "$bucket" --query "Status" --output text)
  
  if [ "$versioning_status" == "Enabled" ]; then
    backup_enabled="Yes"
    retention_policy=""
    rotation_scheme=""
  else
    backup_enabled="No"
    retention_policy="Not Applied (Versioning Disabled)"
    rotation_scheme="Not Applied (Versioning Disabled)"
  fi
  
  echo "Int,s3_bucket,${bucket},Data,$region,,${backup_enabled},${retention_policy},${rotation_scheme}" >> "$output_csv"
done

echo "S3 bucket information saved to $output_csv"
