#####################################
#Login with SP (PS Az CLI)
az login --service-principal `
  --username <APP_ID> `
  --password <CLIENT_SECRET> `
  --tenant <TENANT_ID>
  --allow-no-subscription
#####################################
 
az login --service-principal --username "sdfsdfsfd" --password "sdfsdfsdf" --tenant "sdfsdfsdf" --allow-no-subscription
 
 
# Get Azure RBACs
az role assignment list
 
 
#Use AppID to get ObjectID and to het entra roles & groups
$spObjectId = az ad sp show --id "1a0f13ad-...-4b57e68955a1" --query id -o tsv
 
#listaa roolit ja ryhmät
az rest --method GET `
  --url https://graph.microsoft.com/v1.0/servicePrincipals/$spObjectId/memberOf?`$select=id,displayName `
  --query "value[].{displayName:displayName,id:id}"
 
#jos ei riitä, niin tällä saa kaikki yksittäiset role assignmentit
az rest --method GET `
  --url https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments`?$filter=principalId eq '$spObjectId'&`$expand=roleDefinition `
  --query "value[].{role:roleDefinition.displayName,scope:directoryScopeId,id:id}"
 
#Listaa kaikki käyttäjät
az ad user list --query "[].{userPrincipalName:userPrincipalName,displayName:displayName}" -o table
 
############################################################################################
# Rakennetetaan taulukko käyttäjistä joilla privilege rooli suoraan tai ryhmän kautta
## Hae roleAssignments ja expandaa principal
$assignments = az rest --method GET `
  --url https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$expand=principal `
  -o json | ConvertFrom-Json
 
## Hae roleDefinitions
$roles = az rest --method GET `
  --url https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions `
  -o json | ConvertFrom-Json
 
## Suodata vain käyttäjät ja yhdistä roolin nimi
$assignments.value | Where-Object {
    $_.principal.'@odata.type' -eq '#microsoft.graph.user'
} | ForEach-Object {
    $rolePath = $_.roleDefinitionId
    $roleGuid = $rolePath -replace '.*/', ''  # Poistaa kaiken ennen viimeistä /
    $roleName = ($roles.value | Where-Object { $_.id -eq $roleGuid }).displayName
    [PSCustomObject]@{
        User = $_.principal.userPrincipalName
        Role = $roleName
    }
} | Format-Table
 
# 1. Hae roleAssignments ja expandaa principal
$assignments = az rest --method GET `
  --url https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$expand=principal `
  -o json | ConvertFrom-Json
 
# 2. Hae roleDefinitions
$roles = az rest --method GET `
  --url https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions `
  -o json | ConvertFrom-Json
 
# 3. Erottele suorat käyttäjät ja ryhmät
$directAssignments = @()
$groupAssignments = @()
 
foreach ($a in $assignments.value) {
    $roleGuid = $a.roleDefinitionId -replace '.*/', ''
    $roleName = ($roles.value | Where-Object { $_.id -eq $roleGuid }).displayName
 
    if ($a.principal.'@odata.type' -eq '#microsoft.graph.user') {
        $directAssignments += [PSCustomObject]@{
            User = $a.principal.userPrincipalName
            Role = $roleName
            ViaGroup = $null
        }
    }
    elseif ($a.principal.'@odata.type' -eq '#microsoft.graph.group') {
        $groupAssignments += [PSCustomObject]@{
            GroupId = $a.principal.id
            GroupName = $a.principal.displayName
            Role = $roleName
        }
    }
}
 
# 4. Hae ryhmien jäsenet ja muodosta epäsuorat roolit
$indirectAssignments = @()
 
foreach ($g in $groupAssignments) {
    $members = az rest --method GET `
      --url https://graph.microsoft.com/v1.0/groups/$($g.GroupId)/members `
      -o json | ConvertFrom-Json
 
    foreach ($m in $members.value) {
        if ($m.'@odata.type' -eq '#microsoft.graph.user') {
            $indirectAssignments += [PSCustomObject]@{
                User = $m.userPrincipalName
                Role = $g.Role
                ViaGroup = $g.GroupName
            }
        }
    }
}
 
# 5. Yhdistä ja näytä kaikki
$allAssignments = $directAssignments + $indirectAssignments
$allAssignments | Sort-Object User, Role | Format-Table
 
#########################################################################################
 
# Haetaan PIM ryhmät joilla privilege rooli sekä ryhmien eligible jäsenet
## 1. Hae kaikki PIM eligibilityt ryhmille
$pimEligibilities = az rest --method GET `
  --url https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilitySchedules?`$expand=principal,roleDefinition `
  -o json | ConvertFrom-Json
 
## 2. Suodata eligibilityt, joissa principal on ryhmä
$groupEligibilities = $pimEligibilities.value | Where-Object {
    $_.principal.'@odata.type' -eq '#microsoft.graph.group'
}
 
## 3. Hae eligible ryhmien jäsenet
$eligibleViaGroup = @()
 
foreach ($e in $groupEligibilities) {
    $groupId = $e.principal.id
    $groupName = $e.principal.displayName
    $roleName = $e.roleDefinition.displayName
 
    # Hae ryhmän jäsenet
    $members = az rest --method GET `
      --url https://graph.microsoft.com/v1.0/groups/$groupId/members `
      -o json | ConvertFrom-Json
 
    foreach ($m in $members.value) {
        if ($m.'@odata.type' -eq '#microsoft.graph.user') {
            $eligibleViaGroup += [PSCustomObject]@{
                User = $m.userPrincipalName
                Role = $roleName
                ViaGroup = $groupName
                Eligibility = "Eligible via group"
            }
        }
    }
}
 
## 4. Tulosta
$eligibleViaGroup | Sort-Object User, Role | Format-Table