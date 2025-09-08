#local init session and startup bastion
aws s3 ls --profile csb1-adm
aws ec2 start-instances --instance-ids i-xxxxxx

#connect to bastion
ssh -i .ssh\xxx.pem ubuntu@some-domain.com

#Refresh session
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
aws s3 ls --profile csb1-adm
# anna token

export AWS_PROFILE=csb1-adm
export AWS_SDK_LOAD_CONFIG=1   # tärkeä, että Terraform lukee ~/.aws/config
eval $(aws configure export-credentials --profile csb1-adm --format env)

# Check that everything is ok
env | grep AWS

# Run terra
terraform init 
terraform plan
terraform apply