# Configures the AWS provider used during the Terraform test
provider "aws" {
  # Runs the test against the same AWS region used by the basic example
  region = "us-east-1"
}

# Runs a plan-mode test against the reusable network module
run "network_configuration" {

  # Generates a Terraform plan without creating or modifying real infrastructure
  command = plan

  # Specifies the module configuration that this test evaluates
  module {
    # Loads the reusable network module from the repository
    source = "./modules/network"
  }

  # Verifies that the planned module configuration defines exactly four subnets
  assert {
    # Creates a list of the four subnet resources and confirms the list contains four items
    condition = length([
      aws_subnet.public_subnet_1a,
      aws_subnet.public_subnet_1b,
      aws_subnet.private_subnet_1a,
      aws_subnet.private_subnet_1b
    ]) == 4

    # Displays this message if the subnet-count assertion fails
    error_message = "Expected four subnets to be created."
  }

  # Verifies that neither public subnet automatically assigns public IPv4 addresses
  assert {
    # Requires automatic public IPv4 assignment to remain disabled on both public subnets
    condition = (
      aws_subnet.public_subnet_1a.map_public_ip_on_launch == false &&
      aws_subnet.public_subnet_1b.map_public_ip_on_launch == false
    )

    # Displays this message if either public subnet enables automatic public IPv4 assignment
    error_message = "Public subnets must not automatically assign public IPv4 addresses."
  }

  # Verifies that neither private subnet automatically assigns public IPv4 addresses
  assert {
    # Requires automatic public IPv4 assignment to remain disabled on both private subnets
    condition = (
      aws_subnet.private_subnet_1a.map_public_ip_on_launch == false &&
      aws_subnet.private_subnet_1b.map_public_ip_on_launch == false
    )

    # Displays this message if either private subnet enables automatic public IPv4 assignment
    error_message = "Private subnets must not automatically assign public IPv4 addresses."
  }
}
