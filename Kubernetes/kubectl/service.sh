#!/bin/bash
# service url: servicename.namespace.svc.cluster.local

# list all services in the current namespace
k get services -o=wide

# check how to expose a service / route traffic to a service
k expose -h | less

# expose a deployment as a service
k expose deployment <deployment-name> --port=<port>

# change service type to loadBalancer and get external IP
# Note: LoadBalancer type requires a cloud provider or a local setup that supports it (like Rancher Desktop)
k edit svc <service-name> # change type to LoadBalancer or use kubectl patch  

# create service yaml file from existing service
k get service <service-name> -o yaml > git-path/<service-name>/service.yaml


