#!bin/bash

#Describe known running instance
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=<ec2-instance-name>"

#Descripe known stopped instance
aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" "Name=tag:Name,Values=<ec2-instance-name>" --profile <profname>


# Grep ID
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=<ec2-instance-name>" | grep InstanceId

# jq Instance ID
export EC2Instance=$(aws ec2 describe-instances --filters \
"Name=instance-state-name,Values=running" "Name=tag:Name,Values=<ec2-instance-name>" \
| jq -r ".Reservations[].Instances[].InstanceId")
echo $EC2Instance

# Startup instance
aws ec2 start-instances --instance-ids i-xxxxxx

# Connect to instance
aws ssm start-session --target <instance-id>

# LAB22 : pre-built in bash-extension:
aws ssm start-session --target $(dm-bastion-instance-id-aws)

# Test with dry-run
aws ec2 run-instances --dry-run \
  --image-id ami-0f95bf1ddbac1ba39 \
  --instance-type m7i-flex.xlarge \
  --subnet-id subnet-0d38466395f910614 \
  --associate-public-ip-address \
  --key-name stirring-ox

# Allowed instance sizes in current az
aws ec2 describe-instance-type-offerings \
  --location-type availability-zone \
  --filters Name=location,Values=eu-north-1b \
  --query "InstanceTypeOfferings[].InstanceType" --output text | tr '\t' '\n' | grep -Ev 'xlarge$|metal$'

