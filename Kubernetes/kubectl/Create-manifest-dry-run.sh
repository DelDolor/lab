# Create nginx deployment manifest using dry-run
# This command creates a YAML manifest for an nginx deployment using the dry-run option.
# The `--dry-run=client` option means that the command will not actually create the deployment, but will output the YAML manifest to the console.
# The `-o yaml` option specifies that the output should be in YAML format.
# The output is redirected to a file named `nginx-001.yaml` in manifests folder.

#!/bin/bash
k run nginx-yaml --image=nginx --dry-run=client -o yaml > manifests/nginx-001.yaml

# and deploy it to cluster
kubectl apply -f manifests/nginx-001.yaml

# Validate
kubectl get pods
kubectl describe pod <pod name>

