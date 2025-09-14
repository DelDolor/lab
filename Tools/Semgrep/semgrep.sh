#!bin/bash

# List all semgrep rules
ls /opt/semgrep/rules

run semgrep against the ~/code/dm-api/src/ directory using the r.sans.labs/operations/dm-devops/builder_semgrep:stable image.

# Scan using java rules
semgrep scan -f /opt/semgrep/rules/java /src

# Scanning as a part of pipeline
script:
    "/bin/bash ./path-to/semgrep-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS"

# Use these when you have semgrep installed in container
# list all rules
docker run container-regitstry-url/builder_semgrep:stable ls /opt/semgrep/rules

# Scan
#The semgrep scan command uses the -f <CONFIG> flag to configure which rules are used to perform the scan.
# for example Run semgrep to scan the src (${PWD}/src) directory of the dm-api project using the java rules.
cd ~/gits/repo
docker run -v ${PWD}/src:/src container-regitstry-url/builder_semgrep:stable semgrep scan -f /opt/semgrep/rules/java /src

> Ran 59 rules on 26 files: 1 finding.
>  1 Code Finding:                                                                               
    /src/main/java/com/xxx/data/repositories/TicketSearchRepository.java
   ❯❯❱ opt.semgrep.rules.java.lang.security.audit.formatted-sql-string.formatted-sql-string

# Semgrep in merge_request.yaml
semgrep:
  image: container-regitstry-url/builder_semgrep:stable
  extends: .merge-request
  variables:
    RESULTS_DIR: ./semgrep
    SARIF_RESULTS: results.sarif
    JUNIT_RESULTS: results.junit.xml
  script:
    - 'echo "Run semgrep scan and process results"'
    - "/bin/bash ./build/bin/semgrep-scan.sh $RESULTS_DIR $SARIF_RESULTS $JUNIT_RESULTS"
  artifacts:
    when: always
    paths:
      - $RESULTS_DIR/*
    reports:
      junit: $RESULTS_DIR/$JUNIT_RESULTS