#Execute prowler using the aws command to scan the AWS Account accessible from the credentials present in the environment.
#Scan only the region specified by the environment variable AWS_DEFAULT_REGION
#Use the configuration in the specified file.
#Disable color codes in the output and return a "success" regardless of what the scan finds. These help our CI/CD processes run more smoothly.
#Report findings only for rules with "critical" or "high" severity.
#Configure the output - create 4 different output formats, and place the files in the "./output" directory.
#prowler aws \
    --region ${AWS_DEFAULT_REGION} \
    --config-file prowler/aws/config.yaml \
    --no-color --ignore-exit-code-3 \
    --severity critical high \
    --output-formats csv json-asff json-ocsf html \
    --output-directory ./output
