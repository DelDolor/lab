jwt-decode "eyJhb...ZTk5OTc2NmUifQ.eyJhdW...ndlYiJ9.TJJOYl-XK..NPMog"

# AWS JWT:
#The issuer is the EKS OpenID Connect Provider URL. 
#The audience is the default value used by AWS services sts.amazonaws.com. 
#The subject is the full name (namespace and name) of the Kubernetes service account allowed to assume the IAM role. 
#The iat is the time the token was issued and the exp is the expiration time of the token. 
#To find the token's expiration window, run the following commands to convert the iat and exp values to a human readable date.
date -d @ENTER_YOUR_IAT_VALUE_HERE
date -d @ENTER_YOUR_EXP_VALUE_HERE
