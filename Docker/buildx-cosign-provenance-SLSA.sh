#The docker binary supports multiple methods for building docker images. In the feature/supply-chain-security-az branch, we moved the pipeline from using the legacy build client (using docker build) to the buildx CLI plugin (i.e. docker buildx build) which uses the BuildKit engine. This provides a significantly more modern, efficient, and extensible method for building docker images and OCI artifacts.

# build and push container image
docker buildx build --push --attest type=provenance,mode=max -t "${IMAGE_NAME}" .

# Inspect provenance SLSA metadata
DOCKER_USERNAME="00000000-0000-0000-0000-000000000000"
DM_ACR_LOGIN_SERVER=$(vault kv get -field=dm_acr_login_server kv/az/deployment/metadata)
DOCKER_ACCESS_TOKEN=$(vault kv get -field=access_token kv/az/acr/api)
docker login --username ${DOCKER_USERNAME} --password-stdin "${DM_ACR_LOGIN_SERVER}" <<<${DOCKER_ACCESS_TOKEN}
IMAGE_NAME="$(vault kv get -field=image_name kv/az/acr/api)"
docker buildx imagetools inspect "${IMAGE_NAME}" --format "{{ json .Provenance.SLSA }}" | less


# Extract build time Dockerfile
docker buildx imagetools inspect ${IMAGE_NAME} --format '{{ range (index .Provenance.SLSA.metadata "https://mobyproject.org/buildkit@v1#metadata").source.infos }}{{ if eq .filename "Dockerfile" }}{{.data }}{{ end }}{{ end }}' | base64 -d


# COSIGN
## Verify signature
IMAGE_NAME="$(vault kv get -field=image_name kv/az/acr/api)"
MANIFEST_DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE_NAME}" | cut -f2 -d@)"

cosign verify --key cosign.pub "${IMAGE_NAME}@${MANIFEST_DIGEST}" | jq

#The following checks were performed on each of these signatures:
#  - The cosign claims were validated
#  - Existence of the claims in the transparency log was verified offline
#  - The signatures were verified against the specified public key

#see what the tag was at the time of signing by extracting it from the signature payload. This confirms that the image's current tag matches the tag that was signed.
cosign verify --key cosign.pub "${IMAGE_NAME}@${MANIFEST_DIGEST}" 2>/dev/null | jq -r '.[-1].optional.tag'

