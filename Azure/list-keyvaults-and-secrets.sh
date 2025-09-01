# List keyvaults
az keyvault list -o table

# List secret names from KV
az keyvault secret list --vault-name <vaultname> -o table

# Show secret value
az keyvault secret show --vault-name <vaultname> --name <secret-name> --query value -o tsv
