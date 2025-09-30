# As an alternative to manually downloading files in the Gitlab artifact UI, you can use the GitLab CLI glab.
#glab job artifact <pipeline-name> <job-name> -R group/project
glab job artifact main sbom-az -R group/project
tree sboms

jq -r '.packages[].licenseDeclared' < sboms/sbom.spdx.json | sort | uniq -c
