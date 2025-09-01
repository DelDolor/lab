# List Defender for cloud assesments
az security assessment list -o tabl

# Grep container registry alerts
az security assessment list -o table 2>/dev/null | grep -i registry

#  get a list of the vulnerabilities discovered in one of the sub-assessments
az security sub-assessment list --assessment-name <long-name-from-preivous-list> 2>/dev/null \
| jq -r '.[] | select(.additionalData.artifactDetails.artifactType=="ContainerImage").status.severity' \
| sort | uniq -c | sort -n

# use the az security sub-assessment list command to query the vulnerabilities by name.
az security sub-assessment list --assessment-name <long-name-from-preivous-list> 2>/dev/null \
| jq -r '.[] | select(.additionalData.artifactDetails.artifactType=="ContainerImage") | [.displayName, .status.severity, .additionalData.softwareDetails.packageName, .additionalData.softwareDetails.version, .additionalData.softwareDetails.fixStatus] | @tsv'
