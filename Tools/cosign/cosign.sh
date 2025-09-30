# Generate public and privet keys. store privet into vault
vault login -method=userpass username=xxxx
cosign generate-key-pair --kms "hashivault://path"
#> cosign generate-key-pair --kms "hashivault://path"
#> Public key written to cosign.pub

## Verify signature from container reg
IMAGE_NAME="$(vault kv get -field=image_name kv/az/acr/api)"
MANIFEST_DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE_NAME}" | cut -f2 -d@)"

cosign verify --key cosign.pub "${IMAGE_NAME}@${MANIFEST_DIGEST}" | jq

#The following checks were performed on each of these signatures:
#  - The cosign claims were validated
#  - Existence of the claims in the transparency log was verified offline
#  - The signatures were verified against the specified public key

#see what the tag was at the time of signing by extracting it from the signature payload. This confirms that the image's current tag matches the tag that was signed.
cosign verify --key cosign.pub "${IMAGE_NAME}@${MANIFEST_DIGEST}" 2>/dev/null | jq -r '.[-1].optional.tag'


#########################################################################

kubectl get -n cosign-system configmap config-policy-controller -o yaml

# test
kubectl --context aws create namespace sig-test

kubectl --context aws label ns sig-test policy.sigstore.dev/include=true

kubectl --context aws run -n sig-test nginx --image nginx
#Warning: no matching policies: spec.containers[0].image
#Warning: index.docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
#pod/nginx created

kubectl --context aws run -n sig-test awscli --image public.ecr.aws/aws-cli/aws-cli:2.22.28 -- help


