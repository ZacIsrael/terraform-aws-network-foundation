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

  # Ensures the provided value is a valid IPv4 CIDR block
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

# Defines the IPv4 CIDR blocks assigned to the public subnets
# The module expects one public subnet for each Availability Zone
variable "public_subnet_cidrs" {

  # Human-readable description of the variable's purpose
  description = "CIDR blocks for the public subnets in the VPC"

  # Requires the public subnet CIDR blocks to be provided as a list of strings
  type = list(string)

  # Default CIDR blocks used if no custom ones are provided
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  # Ensures exactly two valid IPv4 CIDR blocks are provided
  # Each CIDR block is validated before it can be used to create a subnet
  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))
    ]) && length(var.public_subnet_cidrs) == 2

    error_message = "public_subnet_cidrs must contain exactly 2 valid IPv4 CIDR blocks."
  }
}

# Defines the IPv4 CIDR blocks assigned to the private subnets
# The module expects one private subnet for each Availability Zone
variable "private_subnet_cidrs" {

  # Human-readable description of the variable's purpose
  description = "CIDR blocks for the private subnets in the VPC"

  # Requires the private subnet CIDR blocks to be provided as a list of strings
  type = list(string)

  # Default CIDR blocks used if no custom ones are provided
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  # Ensures exactly two valid IPv4 CIDR blocks are provided
  # Each CIDR block is validated before it can be used to create a subnet
  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))
    ]) && length(var.private_subnet_cidrs) == 2

    error_message = "private_subnet_cidrs must contain exactly 2 valid IPv4 CIDR blocks."
  }
}
