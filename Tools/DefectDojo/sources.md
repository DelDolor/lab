# Scanners & report sources for Defect Dojo

## Merge Request pipeline

### Semgrep (semgrep)

Semgrep provides a lightweight, multi-language, extensible static analysis solution. Static Application Security Testing (SAST) focuses on finding security vulnerabilities. Main purpose is to check compliance against policies and best practices (allow s3:* etc.).
- Open-source (also fork called Opengrep exists)
- Communit driven rules & possibility to create custom
    - r2c-security-audit
- Supports: Go, Java, JavaScript, Python, Tuby, TypeScript, C#, generic markup (JSON, YAML)
- Supports automation
- default output: stdout


```
# Example scan for java sourcecode
semgrep scan -f /opt/semgrep/rules/java --disable-version-check --junit-xml-output=${RESULTS_DIR}/${JUNIT_RESULTS} --sarif-output=${RESULTS_DIR}/${SARIF_RESULTS} ./src
```

### Trivy filesystem (trivy-fs)
Container security (CVE/vulnerability & misconfiguration) scanning engine written by Aqua Security. Supports scanning configuration files kube manifests & dockerfiels for misconfigurations.
- fs (filesystem) scans local filesystem directory for configuration files & dependencies. searches supported files and run rules to discover anti-patterns from configuration files.
- easy to integrate CI/CD pipelines
- default output stdout table, can be formatted to junitxml, sarif, json 


```
trivy fs --scanners misconfig --offline-scan --format json --output "$RESULTS_DIR/trivy.json" ./
trivy convert --format sarif --output "$RESULTS_DIR/$SARIF_RESULTS" "$RESULTS_DIR/trivy.json"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --output "$RESULTS_DIR/$JUNIT_RESULTS" "$RESULTS_DIR/trivy.json"
```

## CD pipeline

### Trivy image scan (container registry) (trivy-scan-aws)
Container security (CVE/vulnerability & misconfiguration) scanning engine written by Aqua Security. Supports scanning configuration files kube manifests & dockerfiels for misconfigurations.
- image scan scans container image for vulnerabilities
- easy to integrate CI/CD pipelines
- default output stdout table, can be formatted to junitxml, sarif, json


```
trivy image --ignore-unfixed --format json --output "$RESULTS_DIR/trivy.json" "${TRIVY_IMAGE}"
trivy convert --format sarif --output "$RESULTS_DIR/$SARIF_RESULTS" "$RESULTS_DIR/trivy.json"
trivy convert --format template --template "@/usr/local/share/trivy/templates/junit.tpl" --output "$RESULTS_DIR/$JUNIT_RESULTS" "$RESULTS_DIR/trivy.json"
```

### SBOM - Software Bill of Material (sbom-aws)
Syft is multipurpose SBOM generator that supportss enumeration in docker, podman, and container image formats. You can also specify directory, file, container registry etc.
- Default output stdout columnar summary. 
- Supports SBOM in json-based Syft format, JSON or XML-based CycloneDX format, JSON or XML-based SPDX and GitHub dependency snapshot format.
- Custom templates for output is also supported

```
# example where syft scans image called ${IMAGE_NAME} and outputs results in three different format
syft "docker:${IMAGE_NAME}" \
    -o "json=${RESULTS_DIR}/${SYFT_SBOM}" \
    -o "spdx-json=${RESULTS_DIR}/${SPDX_SBOM}" \
    -o "cyclonedx-json=${RESULTS_DIR}/${CYCLONEDX_SBOM}"
```

### Grype
<tbd> grype can search vulnerabilities from syft sbom.

### Cosign (sign images in aws)
Cosign  supports container signing, verification, and storage in an OCI compliant container registry. 
- Supports multiple key management solutions: BYOK, AWS KMS, Az Key Vault, GC KMS, Kubernetse and hardware-based keys
- Supports also additional artifact types that can be stored in container registry: Tekton bundles, Helm charts, Web assembly (WASM) modules, binary files

```
docker push 2345678.dkr.ecr.us-west-2.amazonaws.com/my-tool:1.4
cosign sign --key awskms://path/to/cosign 12345678.dkr.ecr.us-west-2.amazonaws.com/my-tool:1.4
```

```
cosign sign --yes --key "hashivault://${VAULT_TRANSIT_KEY}" -a "tag=${IMAGE_TAG}" -a "pipeline=${CI_PIPELINE_ID}" "${IMAGE_NAME}@${MANIFEST_DIGEST}"
```