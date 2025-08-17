/*
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

The terraform {} block configures Terraform itself, including which providers to install, and which version of Terraform to use to provision your infrastructure. Using a consistent file structure makes maintaining your Terraform projects easier, so we recommend configuring your Terraform block in a dedicated terraform.tf file.

Terraform uses binary plugins called providers to manage your resources by calling your cloud provider's APIs. Terraform providers are distributed and versioned separately from Terraform. By decoupling providers from the Terraform binary, Terraform can support any infrastructure vendor with an API.

The string ~> 5.92 means your configuration supports any version of the provider with a major version of 5 and a minor version greater than or equal to 92.
The string >= 1.2 means your configuration supports any version of Terraform greater than or equal to 1.2.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
