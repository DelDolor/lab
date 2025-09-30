# Container registry scans
az security assessment list -o table 2>/dev/null | grep -i registry

# get a list of the vulnerabilities discovered in one of the sub-assessments.
az security sub-assessment list --assessment-name c0b7cfc6-...-53c7ff2cc0d5 2>/dev/null \
| jq -r '.[] | select(.additionalData.artifactDetails.artifactType=="ContainerImage").status.severity' \
| sort | uniq -c | sort -n

# query the vulnerabilities by name.
az security sub-assessment list --assessment-name c0b7cfc6-...-53c7ff2cc0d5 2>/dev/null \
| jq -r '.[] | select(.additionalData.artifactDetails.artifactType=="ContainerImage") | [.displayName, .status.severity, .additionalData.softwareDetails.packageName, .additionalData.softwareDetails.version, .additionalData.softwareDetails.fixStatus] | @tsv'

## Example output ##
# CVE-2023-2975   Medium  openssl 3.0.9-1         FixAvailable
# CVE-2023-36054  High    krb5    1.20.1-2        FixAvailable
# CVE-2023-47038  High    perl    5.36.0-7        FixAvailable
