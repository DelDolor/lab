cd ~/code/sabre-cloud-audit
mkdir -p /labs/scratch/prowler/az/output
glab job artifact main prowler-az --path /labs/scratch/prowler/az
cp /labs/scratch/prowler/az/output/prowler-output-sans*.html /labs/scratch/prowler/az/output/prowler-latest.html
