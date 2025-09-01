#!bin/bash

#Describe known running instance
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=<ec2-instance-name>"

# Grep ID
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=<ec2-instance-name>" | grep InstanceId

# jq Instance ID
export EC2Instance=$(aws ec2 describe-instances --filters \
"Name=instance-state-name,Values=running" "Name=tag:Name,Values=<ec2-instance-name>" \
| jq -r ".Reservations[].Instances[].InstanceId")
echo $EC2Instance

# Connect to instance
aws ssm start-session --target <instance-id>

# LAB22 : pre-built in bash-extension:
aws ssm start-session --target $(dm-bastion-instance-id-aws)



