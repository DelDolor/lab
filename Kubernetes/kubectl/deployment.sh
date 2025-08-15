# deployment is a way to define a desired state for your application, such as which images to use for the app, the number of pod replicas, and the way to update them. Kubernetes will automatically manage the deployment to ensure that the current state matches the desired state.

#!/bin/bash
kubectl create deployment -h | less

# Create a deployment using kubectl
k create deploy test --image=httpd --replicas=3

# Check the deployment
k get deployments.apps
k describe deployments.apps test

# Check the pods created by the deployment
k get pods -l app=test
k get pods -l -o=wide app=test

# edit the deployment
k edit deployment test

# Scale the deployment
k scale deployment test --replicas=5

# delete the deployment
k delete deployment test

# Create a deployment template from an image
k create deployment httpd-depl-templ --image=httpd --dry-run=client  --replicas=5 -o=yaml

# Create a deployment from a YAML file
k apply -f manifests/deployment-sample.yaml

# check replicas
k get replicasets.apps
k describe replicasets.apps <replicaset-name>

############################################
# Update deployment (default strategy: rolling)
## Set monitoring to another terminal window
watch -n 1 "kubectl get pods -o=wide"
## Update content deploymen.yaml of and re-deploy
k apply -f manifests/deployment-sample.yaml 

# use another strategy or configure rolling update.
# you need to edit the deployment manifest file and add the strategy section on a same level as the template section.
# For example update only one pod at the time: 
#   strategy:
#       type: RollingUpdate
#       rollingUpdate:
#           maxSurge: 1 #paljonko saa mennä yli replicas määrän
#           maxUnavailable: 1 #montako podia voi olla alhaalla päivityksen aikana
#
# If you want to remove all exisiting pods and create new ones, you can use the Recreate strategy:
#   strategy:
#       type: Recreate
###########################################