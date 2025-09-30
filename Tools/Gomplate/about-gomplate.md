# Gomplate
https://docs.gomplate.ca/
gomplate is a template renderer which supports a growing list of datasources, such as: JSON (including EJSON - encrypted JSON), YAML, AWS EC2 metadata, Hashicorp Consul and Hashicorp Vault secrets.

## Example from sec540 lab 3.2
```
export DM_SECURITY_AUDITOR_GROUP_ID=$(az ad group list | jq -r '.[] | select(.displayName=="dm-aks-security-auditor").id')
gomplate -f ~/code/dm-infrastructure-az/assets/k8s-all/templates/auditor-rbac.yaml.tmpl > ~/code/dm-infrastructure-az/assets/k8s-all/auditor-rbac.yaml
```
