#every application should run in its own namespace, so that you can easily manage and isolate them. You can create a namespace using kubectl create namespace <namespace-name> command.
#!/bin/bash

# check your current context and namespace
k config get-contexts #* means current context

# Create a namespace manually
kubectl create namespace mealie

## Create a namespace yaml file
k create namespace mealie -o yaml --dry-run=client > mealie/namespace.yaml

## deploy the namespace from yaml file
k apply -f mealie/namespace.yaml

#start pod in namespace manually
k run jouni-mealie --image=nginx -n=mealie

# set namespace to default
k config set-context --current --namespace=mealie

# List all namespaces
kubectl get namespaces

# Get details of a specific namespace
kubectl describe namespace my-namespace

# Delete a namespace and all its resources
kubectl delete namespace my-namespace

# Switch to a different namespace
kubectl config set-context --current --namespace=my-namespace

# Get pods in a specific namespace
kubectl get pods -n my-namespace

# Get services in a specific namespace
kubectl get services -n my-namespace

# Get deployments in a specific namespace
kubectl get deployments -n my-namespace

# Get all resources in a specific namespace
kubectl get all -n my-namespace

# Edit a namespace
kubectl edit namespace my-namespace


