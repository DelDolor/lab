/*
 https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage

    Muuttujia voi antaa myös command line argumentteina: terraform plan -var instance-type=t3.large
*/

variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "learn-terraform"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t3.micro"
}
