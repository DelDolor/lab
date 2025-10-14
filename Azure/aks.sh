# Login to cluster
### Get Credentials
AKS_CLUSTER_NAME=$(vault kv get -field=aks_name kv/az/deployment/metadata)
AKS_RESOURCE_GROUP_NAME=$(vault kv get -field=aks_resource_group kv/az/deployment/metadata)
az aks get-credentials -g "${AKS_RESOURCE_GROUP_NAME}" -n "${AKS_CLUSTER_NAME}" --context az

### bash shortcut
#### Store in ~/.bashrc.extensions file¨
dm-k8s-login-az() {
  AKS_CLUSTER_NAME=$(vault kv get -field=aks_name kv/az/deployment/metadata)
  AKS_RESOURCE_GROUP_NAME=$(vault kv get -field=aks_resource_group kv/az/deployment/metadata)
  az aks get-credentials -g "${AKS_RESOURCE_GROUP_NAME}" -n "${AKS_CLUSTER_NAME}" --context az --overwrite-existing
  kubelogin convert-kubeconfig -l azurecli
}

#### and login using:
dm-k8s-login-az

# view the Entra ID profile details
az aks list --only-show-errors | jq '.[].aadProfile'

