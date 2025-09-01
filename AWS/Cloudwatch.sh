# run the commands below or use the AWS Web Console > CloudWatch > Log Groups > /aws/lambda/ApiGatewayJwtAuthorizer to view the logs files.
AUTHORIZER_LOG_STREAM=$(aws logs describe-log-streams --log-group-name "/aws/lambda/somename" --order-by LastEventTime | jq -r '.[][-1].logStreamName')
echo $AUTHORIZER_LOG_STREAM

# List log streams that are available
aws logs describe-log-streams \
  --log-group-name "/aws/lambda/somename" \
  --order-by LastEventTime \
  --descending \
  --max-items 20

#get log events
aws logs get-log-events --log-group-name "/aws/lambda/somename)" --log-stream-name "${AUTHORIZER_LOG_STREAM}" | grep 'token'


aws logs get-log-events --log-group-name "/aws/lambda/somenme" --log-stream-name "${AUTHORIZER_LOG_STREAM}" | grep 'token'


