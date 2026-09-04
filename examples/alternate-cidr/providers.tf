# The provider block configures how Terraform connects to AWS
# This is where authentication and regional settings are typically defined
provider "aws" {

  # Specifies the AWS region where resources will be deployed
  region = "us-east-1"
}