/*
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

We recommend defining your provider blocks and other primary infrastructure in main.tf as a best practice. 

- Provider block configures the aws provider. Terraform's AWS provider uses the same authentication methods as the AWS CLI

- Use data blocks to query your cloud provider for information about other resources. This data source fetches data about the latest AWS AMI that matches the filter, so you do not have to hardcode the AMI ID into your configuration. 

- Resource block defines components of your infrastructure. First line of a resource block declares a resource type and resource name. In this example, the resource type is aws_instance. The prefix of the resource type corresponds to the name of the provider, and the rest of the string is the provider-defined resource type. Together, the resource type and resource name form a unique resource address for the resource in your configuration. 
    The resource address for your EC2 instance is aws_instance.app_server. 
You can refer to a resource in other parts of your configuration by its resource address.

- Terraform AWS modulit: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

- Install:
  terraform fmt
  terraform init
  terraform validate
  terraform apply #Terraform will print out the execution plan and ask you to confirm the changes before it applies them
  >  + next to resource "aws_instance" "app_server" means that when you apply this plan, Terraform will create the resource with aws_instance.app_server as its ID.
*/

provider "aws" {
  region  = "eu-north-1"
  profile = "terraform" #from ../auth.sh file
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type #from variables.tf file
  
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name = var.instance_name #from variables.tf file
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "example-vpc"
  cidr = "20.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["20.0.1.0/24", "20.0.2.0/24"]
  public_subnets  = ["20.0.101.0/24"]

  enable_dns_hostnames    = true
}

