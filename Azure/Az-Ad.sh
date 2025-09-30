# List groups startgin with "dm"
az ad group list | jq '.[] | select(.displayName | startswith("dm")) | {displayName, id}'

