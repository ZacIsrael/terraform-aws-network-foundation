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

  # Ensures exactly two Availability Zones are provided
  # This matches the module's two-AZ network architecture
  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "You must define exactly 2 Availability Zones."
  }
}

# Defines the IPv4 CIDR block assigned to the VPC
# This establishes the overall address space available to the network
variable "vpc_cidr" {

  # Human-readable description of the variable's purpose
  description = "CIDR block for the VPC"

  # Requires the VPC CIDR block to be provided as a string
  type = string

  # Default CIDR block used if no custom value is provided
  default = "10.0.0.0/16"

  # Ensures the provided value is a valid IPv4 /16 CIDR block
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be a valid IPv4 /16 CIDR block."
  }
}
