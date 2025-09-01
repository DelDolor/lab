#!bin/bash

# List all semgrep rules
ls /opt/semgrep/rules

# Scan using java rules
semgrep scan -f /opt/semgrep/rules/java /src

# Scanning as a part of pipeline
script:
    "/bin/bash ./path-to/semgrep-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS"
