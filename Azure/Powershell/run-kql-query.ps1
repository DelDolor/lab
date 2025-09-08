# KQl query using query as string
Connect-MgGraph -Scopes "ThreatHunting.Read.All"
$kql = @"
AzureActivity
| take 1
"@

$body = @{ query = $kql } | ConvertTo-Json
$resp = Invoke-MgGraphRequest -Method POST `
  -Uri "https://graph.microsoft.com/v1.0/security/runHuntingQuery" `
  -Body $body -ContentType "application/json"
$resp.results | Format-Table -Auto


####################################
## Jos KQL omassa tiedostossaan:
Connect-MgGraph -Scopes "ThreatHunting.Read.All"
$kql = Get-Content "../KQL/sample.kql" -Raw
$body = @{ query = $kql } | ConvertTo-Json

$resp = Invoke-MgGraphRequest -Method POST `
  -Uri "https://graph.microsoft.com/v1.0/security/runHuntingQuery" `
  -Body $body -ContentType "application/json"

# Tulosta TOP 20
$resp.results | Select-Object -First 20 | Format-Table -Auto
