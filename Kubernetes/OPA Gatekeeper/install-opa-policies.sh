#!/bin/bash
set -e

# sign in to the cluster
. assets/cluster-login.sh

# install OPA Gatekeeper Policies
echo "OPA Gatekeeper Policies: Installing Templates on ${CLUSTER_NAME}..."
kubectl apply -k https://gitlab.sans.labs/external/gatekeeper-library//library/general/?ref=master

echo "OPA Gatekeeper Policies: Installing Constratints on ${CLUSTER_NAME}..."
kubectl apply -f ./assets/policy/opa-repo-constraint.yaml