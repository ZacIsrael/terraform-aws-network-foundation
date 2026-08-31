# Defines the AWS region where Terraform will deploy resources
# This controls which AWS data center location the infrastructure is created in
variable "aws_region" {

  # Description shown in Terraform documentation and CLI output
  description = "AWS region to deploy resources"

  # Restricts the variable value to a string
  type = string

  # Default AWS region used if no custom value is provided
  default = "us-east-1"
}

# Defines the Availability Zones where subnets will be deployed
# Using multiple AZs improves availability and fault tolerance
variable "availability_zones" {
  # Human-readable description of the variable's purpose
  description = "Availability Zones used for subnet deployment"

  # Requires the Availability Zones to be provided as a list of strings
  type = list(string)

  # Uses two Availability Zones in us-east-1 by default
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}
