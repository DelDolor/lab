#!bin/bash
# OPA Gatekeeper etc.

kubectl --context aws get constraints

kubectl --context aws describe k8sallowedrepos.constraints.gatekeeper.sh/my-approved-repo

#query the status using yq (similar to JQ for YAML) to determine if we have any policy violations remaining. 
kubectl --context aws get k8sallowedrepos/my-approved-repo  -o yaml | yq -r '.status'
