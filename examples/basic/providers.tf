# The terraform block configures Terraform itself
# This includes Terraform version requirements and provider dependencies
terraform {

  # Specifies the minimum Terraform CLI version required
  # Ensures this configuration only works with Terraform v1.10.0 or newer
  required_version = ">= 1.10.0"

  # Defines all providers required by this Terraform configuration
  # Providers allow Terraform to interact with external platforms/services
  required_providers {

    # AWS provider configuration
    # Used to create and manage AWS infrastructure resources
    aws = {

      # Specifies where Terraform should download the provider from
      # "hashicorp/aws" refers to the official AWS provider
      source = "hashicorp/aws"

      # Defines the acceptable AWS provider version range
      # "~> 6.0" means use version 6.x
      version = "~> 6.0"
    }
  }
}

# The provider block configures how Terraform connects to AWS
# This is where authentication and regional settings are typically defined
provider "aws" {

  # Specifies the AWS region where resources will be deployed
  region = "us-east-1"
}