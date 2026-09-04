# The purpose of this file is to demonstrate and validate 
# that the network module isn't hard-coded to 10.0.0.0/16

# Instantiates the reusable network module with an alternate VPC CIDR to verify
# that the module can support multiple environments without modifying its source code
module "network" {
  # Loads the same reusable network module used by the basic example
  source = "../../modules/network"

  # Overrides the module's default VPC CIDR to validate CIDR configurability and reuse
  vpc_cidr = "10.10.0.0/16"
}
