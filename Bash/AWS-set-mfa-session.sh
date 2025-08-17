#!/bin/bash
# Script to set up an AWS MFA session for Terraform operations
# This script assumes you have the AWS CLI and jq installed and configured.
# It will prompt for an MFA token and set the necessary environment variables.

PROFILE="fedlogin-profile-name"
MFA_ARN="arn:aws:iam::12345678:mfa/mfa-name"
ROLE_ARN="arn:aws:iam::312345678:role/role-name" 

read -p "Anna MFA-koodi: " TOKEN

CREDS=$(aws sts assume-role \
--role-arn $ROLE_ARN \
--role-session-name terraform-session \
--serial-number $MFA_ARN \
--token-code $TOKEN \
--profile $PROFILE \
)

if echo "$CREDS" | jq -e '.Credentials.AccessKeyId' > /dev/null; then
    export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')
    echo "MFA-istunto asetettu. Voit nyt ajaa Terraform-komennot."
else
    echo "Virhe MFA-istunnon asettamisessa."
    echo $CREDS
    exit 1
fi