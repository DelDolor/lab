# List all rules
az network nsg list

# list rules
az network nsg rule list --nsg-name <nsg-name> -g <rg-name> --query "[?name=='public_ssh']"
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name>  --query "sort_by([], &priority)[*].{Name:name,Priority:priority,Ingress_Source:sourceAddressPrefix,Destination_Port:destinationPortRange,Destination_Port_Range:destinationPortRanges,Access:access}"

#create new rule
az network nsg rule create --name attackers-rule --nsg-name <nsg-name> --resource-group <rg-name> --priority 1000 --access Allow --direction Inbound  --destination-port-ranges "8888"
az network nsg rule list --resource-group <rg-name> --nsg-name <nsg-name> --query "sort_by([], &priority)[*].{Name:name,Priority:priority,Ingress_Source:sourceAddressPrefix,Destination_Port:destinationPortRange,Destination_Port_Range:destinationPortRanges,Access:access}"
