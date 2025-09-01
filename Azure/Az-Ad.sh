az ad group list | jq '.[] | select(.displayName | startswith("dm")) | {displayName, id}'
{
  "displayName": "cluster-name",
  "id": "204dbcfb-...-9c4cacae97ef"
}
{
  "displayName": "othernamer",
  "id": "8ab2d9ff-...-4142f52a658b"
}