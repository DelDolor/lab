#!bin/bash
#!!!  The most important concept to understand is that each EKS cluster has a built in EKS OpenId Connect Provider. This is required to sign and validate service account identity tokens.
## https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html


# List clusters
aws eks list-clusters --profile aws-profile

#Update AWS EKS info to your kubeconfig
aws eks update-kubeconfig --profile ws-profile --alias aws --name <cluster-name>

#Connect to cluster
aws eks update-kubeconfig --name "<cluster-name>" --alias aws

#update kubctl profile
aws eks update-kubeconfig \
  --region eu-north-1 \
  --name poro-eks-cluster

#list pods
kubectl --context aws get pods -n <namespace>

# list access entries for one cluster
aws eks list-access-entries --cluster-name <cluster-name>

# Check  access policies associated for current user
aws eks list-associated-access-policies --cluster-name <cluster-name> --principal-arn $(aws sts get-caller-identity | jq -r '.Arn')

# Check your login details
kubectl auth whoami --context aws

# sample how to dig configuration
WEB_POD=$(kubectl get pods --context aws -o json -n <cluster-name> -l "app=web" | jq -r '.items[0].metadata.name')
kubectl --context aws cp somedir/${WEB_POD}:/app/app.jar /tmp/app.jar
unzip -p /tmp/app.jar BOOT-INF/classes/application-aws.properties > /labs/scratch/application-aws.properties



