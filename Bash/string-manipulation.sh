#yq like jq but different licence
yq '... comments=""' prowler/{az,k8s,aws}/config.yaml | head -25

# search several strings at same time
grep -E -A1 'CKV_AWS_115|CKV_AWS_338|CKV_AWS_233|CKV2_AWS_11|CKV_AWS_86|CKV_AWS_51' ../tmp/cw-checkov-after.txt

# Count words from results
grep -E 'CKV_AWS_115|CKV_AWS_338|CKV_AWS_233|CKV2_AWS_11|CKV_AWS_86|CKV_AWS_51' ../tmp/cw-checkov-after.txt | wc -l

# Read file without comment lines
yq '... comments=""' prowler/{az,k8s,aws}/config.yaml | head -25
