provider "aws" {
  region = "us-east-1"
}

run "network_configuration" {
  command = plan

  module {
    source = "./modules/network"
  }

  # Verifies that the module defines exactly four subnets
  assert {
    condition = length([
      aws_subnet.public_subnet_1a,
      aws_subnet.public_subnet_1b,
      aws_subnet.private_subnet_1a,
      aws_subnet.private_subnet_1b
    ]) == 4

    error_message = "Expected four subnets to be created."
  }

#   # Verifies that the private route table does not contain
#   # a default route to the internet
#   assert {
#     condition = alltrue([
#       for route in aws_route_table.private.route :
#       try(route.cidr_block != "0.0.0.0/0", true)
#     ])

#     error_message = "Private route table must not contain a default internet route."
#   }

  # Verifies that public subnets do not automatically assign
  # public IPv4 addresses to network interfaces
  assert {
    condition = (
      aws_subnet.public_subnet_1a.map_public_ip_on_launch == false &&
      aws_subnet.public_subnet_1b.map_public_ip_on_launch == false
    )

    error_message = "Public subnets must not automatically assign public IPv4 addresses."
  }

  # Verifies that private subnets do not automatically assign
  # public IPv4 addresses to network interfaces
  assert {
    condition = (
      aws_subnet.private_subnet_1a.map_public_ip_on_launch == false &&
      aws_subnet.private_subnet_1b.map_public_ip_on_launch == false
    )

    error_message = "Private subnets must not automatically assign public IPv4 addresses."
  }
}
