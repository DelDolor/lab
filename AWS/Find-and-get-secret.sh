aws secretsmanager list-secrets --region us-east-1 --profile lab14
aws secretsmanager get-secret-value --region us-east-1 --profile lab14 --secret-id <secretname> --query SecretString --output text