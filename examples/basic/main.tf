# Instantiates the reusable network module so this root configuration can deploy its resources
# Terraform loads the module configuration from the specified source path
module "network" {
  source = "../../modules/network"

  # Pass all required module inputs here; optional inputs only need to be passed when overriding their default values
}
