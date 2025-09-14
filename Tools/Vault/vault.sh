# Basic commands for Hashicorp Vault

vault status

vault login -h

vault login -method=userpass username=user123

# list all policies
vault policy list

# List policies for one user
vault policy read user123

# read secret value
vault read kv/data/aws/iam/devsecops

# Storing secrets
# there can be multiple key/value pairs stored as part of a single secret. The vault kv put <kv location path> command can take multiple "key=value" arguments to store map data. For example, the following command stores two keys, animal and communication in the secret/demo/devops/labs location:

vault kv put secret/demo/devops/labs \
    animal=horse \
    communication=devops

#########################################
# Store AWS access keys for CICD pipeline
vault kv put kv/aws/iam/devsecops \
region=$(aws configure get region) \
access_key_id=$(aws configure get aws_access_key_id) \
secret_access_key=$(aws configure get aws_secret_access_key)

# Check
vault read kv/data/aws/iam/devsecops

#########################################
# Store existing tls certificate that can be used with AWS certificate manager (ACM)
cd ~/certs
vault kv put kv/aws/acm/www.xx.paper \
private_key=@www.xx.paper.key \
certificate=@www.xx.paper.crt \
certificate_chain=@ca.xx.labs.root.crt

#########################################
# Store AWS EC2 instance key pair that you want to use in new instances
cd ~/.ssh
vault kv put kv/aws/ec2/devsecops \
private_key=@id_rsa \
public_key=@id_rsa.pub

#########################################
# Use Vault in CICD pipeline
# Common yml: The id_tokens configuration creates an environment variable called VAULT_JWT with an audience set to https://vault.xx.labs
.base:
  image: r.xx.labs/operations/xx-devops/builder_aws:stable
  tags:
    - docker
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  id_tokens:
    VAULT_JWT:
      aud: "https://vault.xx.labs"

# before_script configuration. The first command exchanges the VAULT_JWT token with the vault service for a temporary vault token.
default:
  before_script:
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=gitlab-rw-role jwt=$VAULT_JWT)"
#  The temporary token is stored in the VAULT_TOKEN environment variable. Subsequent calls to the vault API will authenticate using the VAULT_TOKEN value.