# check if there is secrets laying around
kubectl exec -it <pod-name> -- /bin/bash
env | grep 'AZURE_'

# and same secrets that are stored into ENV can be seen from pod description
DM_WEB_POD=$(kubectl --context az get pods -o json -n dm -l "app=web" | jq -r '.items[0].metadata.name')
kubectl --context az get pod -n dm -o json $DM_WEB_POD | jq '.spec.containers[].env[]'

#################################################
# and if you use pod identity (entra sp), you can see the token file inside the pod
cat /var/run/secrets/azure/tokens/azure-identity-token ; echo

jwt-decode "PASTE THE TOKEN HERE"

## The short-lived identity tokens are valid for 60 minutes
date -d @ENTER_YOUR_IAT_VALUE_HERE
date -d @ENTER_YOUR_EXP_VALUE_HERE
##  If the token is stolen from the pod, an attacker will only have access to the Azure tenant for 60 minutes.

## Verify from Entra point of view
DM_WEB_SERVICE_PRINCIPAL_CLIENT_ID=$(vault kv get -field=dm_web_service_principal_client_id kv/az/deployment/metadata)
az ad app federated-credential list --id $DM_WEB_SERVICE_PRINCIPAL_CLIENT_ID

#################################################
