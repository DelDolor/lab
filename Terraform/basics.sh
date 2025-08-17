# Basic commands for Terraform
source lab/Bash/AWS-set-mfa-session.sh     #Luo AWS session MFA Tokenilla. aja tämä ennen AWS providerin käyttöä.
terraform init          #alustaa kansion ja lataa tarvittavat providerit yms.
terraform fmt           #Muotoilee tiedostot yhteneviksi ja luettaviksi
terraform validate      #Tarkistaa konfiguraation syntaksin ja rakenteen
terraform apply         #tulostaa ja toteuttaa execution planin
terraform show          #näyttää sen hetkisen tilan (tfstate filen sisältö)
terraform state list    #Listaa projektin resurssit
terraform plan          #generoi muutossuunnitelman ja näyttää muutokset (terraform plan -var instance-type=t3.large)
terraform destroy       #Poistaa kaiken

# Terraform session assume rolen ja MFAn kanssa
# Check ready to use sample script: lab/Bash/AWS-set-mfa-session.sh
CREDS=$(aws sts assume-role \
--role-arn $ROLE_ARN \
--role-session-name terraform-session \
--serial-number $MFA_ARN \
--token-code $TOKEN \
--profile $PROFILE \
)
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')
