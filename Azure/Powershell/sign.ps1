# OS X Bash

pwsh

#Login with SP (PS Az CLI)
az login --service-principal `
  --username <APP_ID> `
  --password <CLIENT_SECRET> `
  --tenant <TENANT_ID>
  --allow-no-subscription

#MgGraph
Disconnect-MgGraph
Connect-MgGraph
#Connect-MgGraph -Scopes "ThreatHunting.Read.All"
Get-MgContext



#####################################
#Login with SP (PS Az CLI)
az login --service-principal `
  --username <APP_ID> `
  --password <CLIENT_SECRET> `
  --tenant <TENANT_ID>
  --allow-no-subscription
#####################################