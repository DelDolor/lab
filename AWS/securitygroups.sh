#!bin/bash

aws configure get region

# List groups
aws ec2 describe-security-groups

# Describe one group
aws ec2 describe-security-groups --filters Name=tag:Name,Values=<sg-name> | jq '.SecurityGroups[] | .GroupId,.IpPermissions'

#Authorize security group ingress
export GroupId=$(aws ec2 describe-security-groups --filters Name=tag:Name,Values=<sg-name> --query "SecurityGroups[].GroupId" --output text)
echo $GroupId
aws ec2 authorize-security-group-ingress --group-id $GroupId --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $GroupId --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 describe-security-groups --filters Name=tag:Name,Values=<sg-name> --query "SecurityGroups[].{IpPermissions:IpPermissions}"
