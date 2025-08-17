/*
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage


*/

output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}