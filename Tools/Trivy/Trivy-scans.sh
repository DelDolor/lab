#!bin/bash

########################
# Scan using trivy-XXX-scan.sh script
# automated github configuration scan (container and Kubernetes configuration files)
./path-to/trivy-fs-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS
# automated runtime image scan (inside container or vm)
./build/bin/trivy-image-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS $VAULT_DATA
###########################

# and this is how to use it as a part of (merge-request) pipeline
trivy-fs:
  image: r.sans.labs/operations/dm-devops/builder_trivy:stable
  extends: .merge-request
  variables:
    RESULTS_DIR: ./trivy-fs
    SARIF_RESULTS: results.sarif
    JUNIT_RESULTS: results.junit.xml
  script:
    - "/bin/bash ./build/bin/trivy-fs-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS"
  artifacts:
    when: always
    paths:
      - $RESULTS_DIR/*
    reports:
      junit: $RESULTS_DIR/$JUNIT_RESULTS


# Scan latest container inside container. To do this you need image name, username ja password that has access to container registry (ECR) and 
# this is example how to fetch those from Vault:
## Login to vault
vault login -method=userpass username=<username>

## Get needed values to env.
TRIVY_USERNAME=$(vault kv get -field=username kv/aws/ecr/api)
TRIVY_PASSWORD=$(vault kv get -field=access_token kv/aws/ecr/api)
echo $TRIVY_USERNAME
echo $TRIVY_PASSWORD

IMAGE_NAME=$(vault kv get -field=image_name kv/aws/ecr/api) #here you can also define image name manually
echo $IMAGE_NAME

## sample how to scan bookworm and write results to file
TRIVY_USERNAME=$(vault kv get -field=username kv/az/acr/api)
TRIVY_PASSWORD=$(vault kv get -field=access_token kv/az/acr/api)
#IMAGE_NAME=$(vault kv get -field=image_name kv/az/acr/api)
IMAGE_NAME=python:3.12.8-bookworm
docker run --user root \
-v /labs/scratch/trivy:/results \
-e "TRIVY_USERNAME=${TRIVY_USERNAME}" -e "TRIVY_PASSWORD=${TRIVY_PASSWORD}" \
--rm -ti r.sans.labs/operations/dm-devops/builder_trivy:stable trivy image \
--format json \
--output /results/python3.12.8-bookworm.json \
--ignore-unfixed ${IMAGE_NAME}
###########################


## Run trivy from  container
docker run -e "TRIVY_USERNAME=${TRIVY_USERNAME}" -e "TRIVY_PASSWORD=${TRIVY_PASSWORD}" --rm -tipath-to/dm-devops/builder_trivy:stable trivy image --ignore-unfixed ${IMAGE_NAME}

# and this is how to use it as a part of (build) pipeline
trivy-scan-aws:
  image: r.sans.labs/operations/dm-devops/builder_trivy:stable
  stage: scan
  extends: .base
  needs:
    - build-aws
  variables:
    RESULTS_DIR: ./tests/trivy-scan-aws
    SARIF_RESULTS: results.sarif
    JUNIT_RESULTS: results.junit.xml
    VAULT_DATA: kv/aws/ecr/api
  script:
    #HERE
    - "/bin/bash ./build/bin/trivy-image-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS $VAULT_DATA"
  artifacts:
    when: always
    paths:
      - $RESULTS_DIR/*
    reports:
      junit: $RESULTS_DIR/$JUNIT_RESULTS

################ other Scans
#offline container scan
trivy -q fs --scanners misconfig --offline-scan /src

# Scan config from whole directory and export outputs to sarif and junit results
trivy config "${CI_PROJECT_DIR:-.}" --format json --output "$RESULTS_DIR/trivy.json"
trivy convert --format sarif --output "$RESULTS_DIR/$SARIF_RESULTS" "$RESULTS_DIR/trivy.json"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --output "$RESULTS_DIR/$JUNIT_RESULTS" "$RESULTS_DIR/trivy.json"

# Scan container image
# Runs the trivy image scan command ignoring unfixed vulnerabilities. 
# Uses the convert command and the @/usr/local/share/trivy/templates/junit.tpl template to writes the junit output file to the ${RESULTS_DIR}/${JUNIT_RESULTS} location
trivy image "${TRIVY_IMAGE}" --username "${TRIVY_USERNAME}" --password "${TRIVY_PASSWORD}" --ignore-unfixed --exit-code 0 --format json --output "${RESULTS_DIR}/trivy.json"
trivy convert --format sarif --input "${RESULTS_DIR}/trivy.json" --output "${RESULTS_DIR}/${SARIF_RESULTS}"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --input "${RESULTS_DIR}/trivy.json" --output "${RESULTS_DIR}/${JUNIT_RESULTS}"

# Lab 2.3 run from offline from container
docker run -v ${PWD}:/src --rm -ti r.sans.labs/operations/dm-devops/builder_trivy:stable trivy -q fs --scanners misconfig --offline-scan /src
