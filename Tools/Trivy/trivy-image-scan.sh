#!/bin/bash
#Run Aqua Security's trivy scanner against the most recently built dm-api image inside the container.
set -e

# set vars
RESULTS_DIR=$1
SARIF_RESULTS=$2
JUNIT_RESULTS=$3
VAULT_DATA=$4

# set image data env vars
export TRIVY_USERNAME=$(vault kv get -field=username "${VAULT_DATA}") || echo ""
export TRIVY_PASSWORD=$(vault kv get -field=access_token ${VAULT_DATA}) || echo ""
TRIVY_IMAGE=$(vault kv get -field=image_name "${VAULT_DATA}") || echo ""

# validate the vault data before proceesing
if [[ -z "${TRIVY_USERNAME}" || -z "${TRIVY_PASSWORD}" || -z "${TRIVY_IMAGE}" ]]; then
    echo "${VAULT_DATA} data is missing or incomplete."
    exit 0
fi

# create results dir
mkdir -p "${RESULTS_DIR}"

# run the scan
echo "Starting trivy image scan..."
trivy --version

#LAB23: Implement trivy scan and process results
trivy image --ignore-unfixed --format json --output "$RESULTS_DIR/trivy.json" "${TRIVY_IMAGE}"
trivy convert --format sarif --output "$RESULTS_DIR/$SARIF_RESULTS" "$RESULTS_DIR/trivy.json"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --output "$RESULTS_DIR/$JUNIT_RESULTS" "$RESULTS_DIR/trivy.json"

#Cloudwars:  
# Runs the trivy image scan command ignoring unfixed vulnerabilities. 
# Uses the convert command and the @/usr/local/share/trivy/templates/junit.tpl template to writes the junit output file to the ${RESULTS_DIR}/${JUNIT_RESULTS} location
trivy image "${TRIVY_IMAGE}" --username "${TRIVY_USERNAME}" --password "${TRIVY_PASSWORD}" --ignore-unfixed --exit-code 0 --format json --output "${RESULTS_DIR}/trivy.json"
trivy convert --format sarif --output "${RESULTS_DIR}/${SARIF_RESULTS}" "${RESULTS_DIR}/trivy.json"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --output "${RESULTS_DIR}/${JUNIT_RESULTS}" "${RESULTS_DIR}/trivy.json"


if [[ -f ${RESULTS_DIR}/${SARIF_RESULTS} ]]; then
    echo "Trivy image scan summary..."
    RULES=$(jq '.runs[].tool.driver.rules | length' <${RESULTS_DIR}/${SARIF_RESULTS})
    FAILURES=$(jq '.runs[].results | length' <${RESULTS_DIR}/${SARIF_RESULTS})
    echo "Number of rules evaluated: ${RULES}"
    echo "Number of rules failing: ${FAILURES}"
    jq -r '.runs[].results[].ruleId' <${RESULTS_DIR}/${SARIF_RESULTS}
fi