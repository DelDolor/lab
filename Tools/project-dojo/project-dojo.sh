
# Query application risk score
export DEFECTDOJO_API_KEY=$(vault kv get -field=token xxx)
curl -sL "https://dojo.domain.com" --header "Content-Type: application/json" --header "Authorization: Token $DEFECTDOJO_API_KEY" | jq '.results[]'

 | grep "grade"
 > "prod_numeric_grade": 5,
