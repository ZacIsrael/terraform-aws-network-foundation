# Creates the Virtual Private Cloud for the network foundation
# The VPC provides the isolated network that contains all subnets
resource "aws_vpc" "main" {

  # Defines the IPv4 address range for the VPC
  cidr_block = "10.0.0.0/16"

  # Uses the default EC2 instance tenancy model
  instance_tenancy = "default"


  # Applies identifying and management metadata to the VPC
  tags = {
    Name      = "network-foundation-vpc"
    ManagedBy = "Terraform"
  }
}

# Creates the public subnet in Availability Zone us-east-1a
# This subnet uses the first Availability Zone defined in the availability_zones variable
resource "aws_subnet" "public_subnet_1a" {
  # Associates the subnet with the VPC created above
  vpc_id = aws_vpc.main.id

  # Defines the IPv4 address range for the subnet
  cidr_block = "10.0.1.0/24"

  # Deploys the subnet into the first configured Availability Zone
  availability_zone = var.availability_zones[0]

  # Assigns a human-readable name to the subnet
  tags = {
    Name = "public-subnet-1a"
    ManagedBy = "Terraform"
  }

}

# Creates the public subnet in Availability Zone us-east-1b
# This subnet uses the second Availability Zone defined in the availability_zones variable
resource "aws_subnet" "public_subnet_1b" {

  # Associates the subnet with the VPC created above
  vpc_id = aws_vpc.main.id

  # Defines the IPv4 address range for the subnet
  cidr_block = "10.0.2.0/24"

  # Deploys the subnet into the second configured Availability Zone
  availability_zone = var.availability_zones[1]

  # Assigns a human-readable name to the subnet
  tags = {
    Name = "public-subnet-1b"
    ManagedBy = "Terraform"
  }

}

# Creates the private subnet in Availability Zone us-east-1a
# This subnet uses the first Availability Zone defined in the availability_zones variable
resource "aws_subnet" "private_subnet_1a" {

  # Associates the subnet with the VPC created above
  vpc_id = aws_vpc.main.id

  # Defines the IPv4 address range for the subnet
  cidr_block = "10.0.3.0/24"

  # Deploys the subnet into the first configured Availability Zone
  availability_zone = var.availability_zones[0]

  # Assigns a human-readable name to the subnet
  tags = {
    Name = "private-subnet-1a"
    ManagedBy = "Terraform"
  }

}

# Creates the private subnet in Availability Zone us-east-1b
# This subnet uses the second Availability Zone defined in the availability_zones variable
resource "aws_subnet" "private_subnet_1b" {
  # Associates the subnet with the VPC created above
  vpc_id = aws_vpc.main.id

  # Defines the IPv4 address range for the subnet
  cidr_block = "10.0.4.0/24"

  # Deploys the subnet into the second configured Availability Zone
  availability_zone = var.availability_zones[1]

  # Assigns a human-readable name to the subnet
  tags = {
    Name = "private-subnet-1b"
    ManagedBy = "Terraform"
  }
}


