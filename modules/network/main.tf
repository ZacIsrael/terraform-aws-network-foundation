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
    Name      = "public-subnet-1a"
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
    Name      = "public-subnet-1b"
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
    Name      = "private-subnet-1a"
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
    Name      = "private-subnet-1b"
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
    Name      = "public-route-table"
    ManagedBy = "Terraform"
  }
}

# Creates the route table used by the private subnets
# This route table will control routing for resources in the private network
resource "aws_route_table" "private" {
  # Associates the route table with the VPC created above
  vpc_id = aws_vpc.main.id

  # Applies identifying metadata to the private route table
  tags = {
    Name      = "private-route-table"
    ManagedBy = "Terraform"
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

# Source & target security groups
# Creates the source security group
resource "aws_security_group" "source" {
  # Assigns a human-readable name to the security group
  name = "source-sg"

  # Describes the purpose of the security group
  description = "Security group used as the trusted source for target resources"

  # Associates the security group with the VPC created above
  vpc_id = aws_vpc.main.id

  # Applies identifying and management metadata to the security group
  tags = {
    Name      = "source-sg"
    ManagedBy = "Terraform"
  }
}

# Creates the target security group
# The target receives TCP 443 traffic only (NO SSH) from the source security group
resource "aws_security_group" "target" {
  # Assigns a human-readable name to the security group
  name = "target-sg"
  # Describes the purpose of the security group
  description = "Security group that allows TCP 443 traffic from the source security group"
  # Associates the security group with the VPC created above
  vpc_id = aws_vpc.main.id

  # Applies identifying and management metadata to the security group
  tags = {
    Name      = "target-sg"
    ManagedBy = "Terraform"
  }
}

# Allows inbound TCP 443 traffic to the target security group
# Traffic is permitted only when it originates from the source security group
resource "aws_vpc_security_group_ingress_rule" "allow_443" {

  # Specifies the security group that receives the inbound traffic
  security_group_id = aws_security_group.target.id

  # Restricts the traffic source to resources using the source security group
  referenced_security_group_id = aws_security_group.source.id

  # Describes the purpose of the ingress rule
  description = "Allow TCP 443 from source security group"

  # Defines the starting port allowed by the rule
  from_port = 443

  # Defines the ending port allowed by the rule
  to_port = 443

  # Restricts the rule to TCP traffic
  ip_protocol = "tcp"


}

# Elastic Network Interface (ENI) for the source security group
resource "aws_network_interface" "src_eni" {
  # Places the source ENI in the first public subnet
  subnet_id = aws_subnet.public_subnet_1a.id

  # Describes the purpose and placement of the network interface
  description = "Source network interface in the public subnet"

  # Associates the source security group with the network interface
  security_groups = [aws_security_group.source.id]

  # Applies identifying and management metadata to the network interface
  tags = {
    Name      = "source-eni"
    ManagedBy = "Terraform"
  }
}

# Elastic Network Interface (ENI) for the target security group
resource "aws_network_interface" "target_eni" {
  # Places the target ENI in the first private subnet
  subnet_id = aws_subnet.private_subnet_1a.id

  # Describes the purpose and placement of the network interface
  description = "Target network interface in the private subnet"

  # Associates the target security group with the network interface
  security_groups = [aws_security_group.target.id]

  # Applies identifying and management metadata to the network interface
  tags = {
    Name      = "target-eni"
    ManagedBy = "Terraform"
  }
}
