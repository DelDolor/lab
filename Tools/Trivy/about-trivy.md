# Trivy
https://github.com/aquasecurity/trivy By AquaSecurity
Find vulnerabilities, misconfigurations, secrets, SBOM in containers, Kubernetes, code repositories, clouds and more .

## Targets (what Trivy can scan):
- Container Image
- Filesystem
- Git Repository (remote)
- Virtual Machine Image
- Kubernetes

## Scanners (what Trivy can find there):
- OS packages and software dependencies in use (SBOM)
- Known vulnerabilities (CVEs)
- IaC issues and misconfigurations
- Sensitive information and secrets
- Software licenses


## Use Cases
- Run locally to check vulnerabilities or misconfigurations in src-files or images
- Run FS scan as a part of Merge-request pipeline to discover misconfigurations
- Run IMAGE scan as a part of main pipeline to discover vulnerabilities in libraries and packages inside of container

# Hints
- use --ignore-unfixed to get result that contains only findings that has fix available