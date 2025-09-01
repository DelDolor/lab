#!/bin/bash
# automated github configuration scan (container and Kubernetes configuration files)
set -e

# set vars
RESULTS_DIR=$1
SARIF_RESULTS=$2
JUNIT_RESULTS=$3

# create results dir
mkdir -p "${RESULTS_DIR}"

# run the scan
echo "Starting trivy fs scan..."
trivy --version

trivy fs --scanners misconfig --offline-scan --format json --output "$RESULTS_DIR/trivy.json" ./
trivy convert --format sarif --output "$RESULTS_DIR/$SARIF_RESULTS" "$RESULTS_DIR/trivy.json"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --output "$RESULTS_DIR/$JUNIT_RESULTS" "$RESULTS_DIR/trivy.json"


if [[ -f ${RESULTS_DIR}/${SARIF_RESULTS} ]]; then
    echo "Trivy fs scan summary..."
    RULES=$(jq '.runs[].tool.driver.rules | length' <${RESULTS_DIR}/${SARIF_RESULTS})
    FAILURES=$(jq '.runs[].results | length' <${RESULTS_DIR}/${SARIF_RESULTS})
    echo "Number of rules evaluated: ${RULES}"
    echo "Number of rules failing: ${FAILURES}"
    jq -r '.runs[].results[].ruleId' <${RESULTS_DIR}/${SARIF_RESULTS}
fi
