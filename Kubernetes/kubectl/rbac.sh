# Whoami and which groups I belong
kubectl auth whoami --context az

# Check example binding Clusterroles
kubectl describe clusterrolebindings aks-cluster-admin-binding-aad --context az
