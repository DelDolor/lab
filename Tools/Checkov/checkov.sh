#!bin/bash
# https://www.checkov.io/

# 1. Build container where Checkovs is installed
# 2. Mount target repository to that container
# 3. Scan 

docker run -v ${PWD}:/src -t private-container-reg/builder_checkov:stable checkov --directory /src --framework terraform

#######

# run checkov as a part of pipeline (merge_request.yml)
...
script:
    - "/bin/bash ./path-to/checkov-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS"
...
