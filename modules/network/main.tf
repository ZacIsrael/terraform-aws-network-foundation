# Creates the Virtual Private Cloud for the network foundation
# The VPC provides the isolated network that contains all subnets
resource "aws_vpc" "main" {

  # Defines the IPv4 address range for the VPC
  cidr_block = var.vpc_cidr

  # Uses the default EC2 instance tenancy model
  instance_tenancy = "default"


  # Applies identifying and management metadata to the VPC
  tags = {
    Name      = "network-foundation-vpc"
    ManagedBy = "Terraform"
  }
}

# Creates an Internet Gateway to allow communication between
# the VPC and the internet
resource "aws_internet_gateway" "main" {
  # Associates the Internet Gateway with the VPC created above
  vpc_id = aws_vpc.main.id

  # Applies identifying and management metadata to the Internet Gateway
  tags = {
    Name      = "network-foundation-igw"
    ManagedBy = "Terraform"
  }
}

# Creates the public subnet in Availability Zone us-east-1a
# This subnet uses the first Availability Zone defined in the availability_zones variable
resource "aws_subnet" "public_subnet_1a" {
  # Associates the subnet with the VPC created above
  vpc_id = aws_vpc.main.id

  # Defines the IPv4 address range for the subnet
  # Programmatically generates the first /24 subnet CIDR from the VPC CIDR
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)

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
  # Programmatically generates the second /24 subnet CIDR from the VPC CIDR
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 2)

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
  # Programmatically generates the third /24 subnet CIDR from the VPC CIDR
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 3)

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
  # Programmatically generates the fourth /24 subnet CIDR from the VPC CIDR
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 4)

  # Deploys the subnet into the second configured Availability Zone
  availability_zone = var.availability_zones[1]

  # Assigns a human-readable name to the subnet
  tags = {
    Name = "private-subnet-1b"
    ManagedBy = "Terraform"
  }
}

# Route Tables 
# Creates the route table used by the public subnets
# This route table will control routing for resources in the public network
resource "aws_route_table" "public" {
   # Associates the route table with the VPC created above
  vpc_id = aws_vpc.main.id

# Applies identifying metadata to the public route table
  tags = {
    Name = "public-route-table"
  }
}

# Creates the route table used by the private subnets
# This route table will control routing for resources in the private network
resource "aws_route_table" "private" {
  # Associates the route table with the VPC created above
  vpc_id = aws_vpc.main.id

# Applies identifying metadata to the private route table
  tags = {
    Name = "private-route-table"
  }
}

# Associates the public subnet in us-east-1a with the public route table
resource "aws_route_table_association" "public_1" {
  # Specifies the public subnet to associate
  subnet_id = aws_subnet.public_subnet_1a.id

  # Specifies the public route table used by the subnet
  route_table_id = aws_route_table.public.id
}

# Associates the public subnet in us-east-1b with the public route table
resource "aws_route_table_association" "public_2" {
  # Specifies the public subnet to associate
  subnet_id = aws_subnet.public_subnet_1b.id

  # Specifies the public route table used by the subnet
  route_table_id = aws_route_table.public.id
}

# Associates the private subnet in us-east-1a with the private route table
resource "aws_route_table_association" "private_1" {
   # Specifies the private subnet to associate
  subnet_id = aws_subnet.private_subnet_1a.id

  # Specifies the private route table used by the subnet
  route_table_id = aws_route_table.private.id
}

# Associates the private subnet in us-east-1b with the private route table
resource "aws_route_table_association" "private_2" {
  # Specifies the private subnet to associate
  subnet_id = aws_subnet.private_subnet_1b.id

  # Specifies the private route table used by the subnet
  route_table_id = aws_route_table.private.id
}

