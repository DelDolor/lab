kubectl get -n cosign-system configmap config-policy-controller -o yaml

# test
kubectl --context aws create namespace sig-test

kubectl --context aws label ns sig-test policy.sigstore.dev/include=true

kubectl --context aws run -n sig-test nginx --image nginx
#Warning: no matching policies: spec.containers[0].image
#Warning: index.docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
#pod/nginx created

kubectl --context aws run -n sig-test awscli --image public.ecr.aws/aws-cli/aws-cli:2.22.28 -- help
